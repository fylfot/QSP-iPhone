/* Copyright (C) 2005-2010 Valeriy Argunov (nporep AT mail DOT ru) */
/*
* This library is free software; you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation; either version 2.1 of the License, or
* (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this library; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
*/

#include "statements.h"
#include "actions.h"
#include "callbacks.h"
#include "common.h"
#include "errors.h"
#include "game.h"
#include "locations.h"
#include "mathops.h"
#include "menu.h"
#include "objects.h"
#include "playlist.h"
#include "text.h"
#include "variables.h"

QSPStatement qspStats[qspStatLast_Statement];
QSPStatName qspStatsNames[QSP_STATSLEVELS][QSP_MAXSTATSNAMES];
int qspStatsNamesCounts[QSP_STATSLEVELS];
int qspStatMaxLen = 0;

static void qspAddStatement(int, int, QSP_STATEMENT, int, int, ...);
static void qspAddStatName(int, QSP_CHAR *, int);
static int qspStatsCompare(const void *, const void *);
static int qspStatStringCompare(const void *, const void *);
static int qspGetStatCode(QSP_CHAR *, QSP_CHAR **);
static int qspSearchElse(QSPLineOfCode *, int, int);
static int qspSearchEnd(QSPLineOfCode *, int, int);
static int qspSearchLabel(QSPLineOfCode *, int, int, QSP_CHAR *);
static QSP_BOOL qspExecString(QSPLineOfCode *, int, int, QSP_CHAR **);
static QSP_BOOL qspStatementIf(QSPLineOfCode *, int, int, QSP_CHAR **);
static QSP_BOOL qspStatementAddText(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementClear(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementExit(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementGoSub(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementGoTo(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementJump(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementWait(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementSetTimer(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementShowWin(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementRefInt(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementView(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementMsg(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementExec(QSPVariant *, int, QSP_CHAR **, int);
static QSP_BOOL qspStatementDynamic(QSPVariant *, int, QSP_CHAR **, int);

static void qspAddStatement(int statCode, int extArg, QSP_STATEMENT func, int minArgs, int maxArgs, ...)
{
	int i;
	va_list marker;
	qspStats[statCode].ExtArg = extArg;
	qspStats[statCode].Func = func;
	qspStats[statCode].MinArgsCount = minArgs;
	qspStats[statCode].MaxArgsCount = maxArgs;
	if (maxArgs > 0)
	{
		va_start(marker, maxArgs);
		for (i = 0; i < maxArgs; ++i)
			qspStats[statCode].ArgsTypes[i] = va_arg(marker, int);
		va_end(marker);
	}
}

static void qspAddStatName(int statCode, QSP_CHAR *statName, int level)
{
	int count, len = qspStrLen(statName);
	count = qspStatsNamesCounts[level];
	qspStatsNames[level][count].Name = statName;
	qspStatsNames[level][count].NameLen = len;
	qspStatsNames[level][count].Code = statCode;
	qspStatsNamesCounts[level] = count + 1;
	/* Max length */
	if (len > qspStatMaxLen) qspStatMaxLen = len;
}

static int qspStatsCompare(const void *statName1, const void *statName2)
{
	return qspStrsComp(((QSPStatName *)statName1)->Name, ((QSPStatName *)statName2)->Name);
}

static int qspStatStringCompare(const void *name, const void *compareTo)
{
	return qspStrsNComp((QSP_CHAR *)name, ((QSPStatName *)compareTo)->Name, ((QSPStatName *)compareTo)->NameLen);
}

void qspInitStats()
{
	/*
	Format:
		qspAddStatement(
			Statement,
			Extended Argument,
			Statement's Function,
			Minimum Arguments' Count,
			Maximum Arguments' Count,
			Arguments' Types [optional]
		);

		"Arguments' Types":
		0 - Unknown / Any
		1 - String
		2 - Number
	*/
	int i;
	for (i = 0; i < QSP_STATSLEVELS; ++i) qspStatsNamesCounts[i] = 0;
	qspStatMaxLen = 0;
	qspAddStatement(qspStatElse, 0, 0, 0, 0);
	qspAddStatement(qspStatElseIf, 0, 0, 1, 1, 2);
	qspAddStatement(qspStatEnd, 0, 0, 0, 0);
	qspAddStatement(qspStatSet, 0, 0, 0, 0);
	qspAddStatement(qspStatIf, 0, 0, 1, 1, 2);
	qspAddStatement(qspStatAct, 0, 0, 1, 2, 1, 1);
	qspAddStatement(qspStatAddObj, 0, qspStatementAddObject, 1, 3, 1, 1, 2);
	qspAddStatement(qspStatAddQst, 1, qspStatementOpenQst, 1, 1, 1);
	qspAddStatement(qspStatClA, 3, qspStatementClear, 0, 0);
	qspAddStatement(qspStatCloseAll, 1, qspStatementCloseFile, 0, 0);
	qspAddStatement(qspStatClose, 0, qspStatementCloseFile, 0, 1, 1);
	qspAddStatement(qspStatClS, 4, qspStatementClear, 0, 0);
	qspAddStatement(qspStatCmdClear, 2, qspStatementClear, 0, 0);
	qspAddStatement(qspStatCopyArr, 0, qspStatementCopyArr, 2, 4, 1, 1, 2, 2);
	qspAddStatement(qspStatDelAct, 0, qspStatementDelAct, 1, 1, 1);
	qspAddStatement(qspStatDelObj, 0, qspStatementDelObj, 1, 1, 1);
	qspAddStatement(qspStatDynamic, 0, qspStatementDynamic, 1, 10, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	qspAddStatement(qspStatExec, 0, qspStatementExec, 1, 1, 1);
	qspAddStatement(qspStatExit, 0, qspStatementExit, 0, 0);
	qspAddStatement(qspStatGoSub, 0, qspStatementGoSub, 1, 10, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	qspAddStatement(qspStatGoTo, 1, qspStatementGoTo, 1, 10, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	qspAddStatement(qspStatJump, 0, qspStatementJump, 1, 1, 1);
	qspAddStatement(qspStatKillAll, 5, qspStatementClear, 0, 0);
	qspAddStatement(qspStatKillObj, 1, qspStatementDelObj, 0, 1, 2);
	qspAddStatement(qspStatKillQst, 6, qspStatementClear, 0, 0);
	qspAddStatement(qspStatKillVar, 0, qspStatementKillVar, 0, 2, 1, 2);
	qspAddStatement(qspStatMenu, 0, qspStatementShowMenu, 1, 3, 1, 2, 2);
	qspAddStatement(qspStatMClear, 1, qspStatementClear, 0, 0);
	qspAddStatement(qspStatMNL, 5, qspStatementAddText, 0, 1, 1);
	qspAddStatement(qspStatMPL, 3, qspStatementAddText, 0, 1, 1);
	qspAddStatement(qspStatMP, 1, qspStatementAddText, 1, 1, 1);
	qspAddStatement(qspStatClear, 0, qspStatementClear, 0, 0);
	qspAddStatement(qspStatNL, 4, qspStatementAddText, 0, 1, 1);
	qspAddStatement(qspStatPL, 2, qspStatementAddText, 0, 1, 1);
	qspAddStatement(qspStatP, 0, qspStatementAddText, 1, 1, 1);
	qspAddStatement(qspStatMsg, 0, qspStatementMsg, 1, 1, 1);
	qspAddStatement(qspStatOpenGame, 0, qspStatementOpenGame, 0, 1, 1);
	qspAddStatement(qspStatOpenQst, 0, qspStatementOpenQst, 1, 1, 1);
	qspAddStatement(qspStatPlay, 0, qspStatementPlayFile, 1, 2, 1, 2);
	qspAddStatement(qspStatRefInt, 0, qspStatementRefInt, 0, 0);
	qspAddStatement(qspStatSaveGame, 0, qspStatementSaveGame, 0, 1, 1);
	qspAddStatement(qspStatSetTimer, 0, qspStatementSetTimer, 1, 1, 2);
	qspAddStatement(qspStatShowActs, 0, qspStatementShowWin, 1, 1, 2);
	qspAddStatement(qspStatShowInput, 3, qspStatementShowWin, 1, 1, 2);
	qspAddStatement(qspStatShowObjs, 1, qspStatementShowWin, 1, 1, 2);
	qspAddStatement(qspStatShowVars, 2, qspStatementShowWin, 1, 1, 2);
	qspAddStatement(qspStatUnSelect, 0, qspStatementUnSelect, 0, 0);
	qspAddStatement(qspStatView, 0, qspStatementView, 0, 1, 1);
	qspAddStatement(qspStatWait, 0, qspStatementWait, 1, 1, 2);
	qspAddStatement(qspStatXGoTo, 0, qspStatementGoTo, 1, 10, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	/* Names */
	qspAddStatName(qspStatElse, QSP_STATELSE, 2);
	qspAddStatName(qspStatElseIf, QSP_FMT("ELSEIF"), 1);
	qspAddStatName(qspStatEnd, QSP_FMT("END"), 2);
	qspAddStatName(qspStatSet, QSP_FMT("SET"), 2);
	qspAddStatName(qspStatSet, QSP_FMT("LET"), 2);
	qspAddStatName(qspStatIf, QSP_FMT("IF"), 2);
	qspAddStatName(qspStatAct, QSP_FMT("ACT"), 2);
	qspAddStatName(qspStatAddObj, QSP_FMT("ADDOBJ"), 2);
	qspAddStatName(qspStatAddObj, QSP_FMT("ADD OBJ"), 2);
	qspAddStatName(qspStatAddQst, QSP_FMT("ADDQST"), 2);
	qspAddStatName(qspStatClA, QSP_FMT("CLA"), 2);
	qspAddStatName(qspStatCloseAll, QSP_FMT("CLOSE ALL"), 1);
	qspAddStatName(qspStatClose, QSP_FMT("CLOSE"), 2);
	qspAddStatName(qspStatClS, QSP_FMT("CLS"), 2);
	qspAddStatName(qspStatCmdClear, QSP_FMT("CMDCLEAR"), 2);
	qspAddStatName(qspStatCmdClear, QSP_FMT("CMDCLR"), 2);
	qspAddStatName(qspStatCopyArr, QSP_FMT("COPYARR"), 2);
	qspAddStatName(qspStatDelAct, QSP_FMT("DELACT"), 2);
	qspAddStatName(qspStatDelAct, QSP_FMT("DEL ACT"), 2);
	qspAddStatName(qspStatDelObj, QSP_FMT("DELOBJ"), 2);
	qspAddStatName(qspStatDelObj, QSP_FMT("DEL OBJ"), 2);
	qspAddStatName(qspStatDynamic, QSP_FMT("DYNAMIC"), 2);
	qspAddStatName(qspStatExec, QSP_FMT("EXEC"), 2);
	qspAddStatName(qspStatExit, QSP_FMT("EXIT"), 2);
	qspAddStatName(qspStatGoSub, QSP_FMT("GOSUB"), 2);
	qspAddStatName(qspStatGoSub, QSP_FMT("GS"), 2);
	qspAddStatName(qspStatGoTo, QSP_FMT("GOTO"), 2);
	qspAddStatName(qspStatGoTo, QSP_FMT("GT"), 2);
	qspAddStatName(qspStatJump, QSP_FMT("JUMP"), 2);
	qspAddStatName(qspStatKillAll, QSP_FMT("KILLALL"), 2);
	qspAddStatName(qspStatKillObj, QSP_FMT("KILLOBJ"), 2);
	qspAddStatName(qspStatKillQst, QSP_FMT("KILLQST"), 2);
	qspAddStatName(qspStatKillVar, QSP_FMT("KILLVAR"), 2);
	qspAddStatName(qspStatMenu, QSP_FMT("MENU"), 2);
	qspAddStatName(qspStatMClear, QSP_FMT("*CLEAR"), 2);
	qspAddStatName(qspStatMClear, QSP_FMT("*CLR"), 2);
	qspAddStatName(qspStatMNL, QSP_FMT("*NL"), 2);
	qspAddStatName(qspStatMPL, QSP_FMT("*PL"), 1);
	qspAddStatName(qspStatMP, QSP_FMT("*P"), 2);
	qspAddStatName(qspStatClear, QSP_FMT("CLEAR"), 2);
	qspAddStatName(qspStatClear, QSP_FMT("CLR"), 2);
	qspAddStatName(qspStatNL, QSP_FMT("NL"), 2);
	qspAddStatName(qspStatPL, QSP_FMT("PL"), 1);
	qspAddStatName(qspStatP, QSP_FMT("P"), 2);
	qspAddStatName(qspStatMsg, QSP_FMT("MSG"), 2);
	qspAddStatName(qspStatOpenGame, QSP_FMT("OPENGAME"), 2);
	qspAddStatName(qspStatOpenQst, QSP_FMT("OPENQST"), 2);
	qspAddStatName(qspStatPlay, QSP_FMT("PLAY"), 0);
	qspAddStatName(qspStatRefInt, QSP_FMT("REFINT"), 2);
	qspAddStatName(qspStatSaveGame, QSP_FMT("SAVEGAME"), 2);
	qspAddStatName(qspStatSetTimer, QSP_FMT("SETTIMER"), 1);
	qspAddStatName(qspStatShowActs, QSP_FMT("SHOWACTS"), 2);
	qspAddStatName(qspStatShowInput, QSP_FMT("SHOWINPUT"), 2);
	qspAddStatName(qspStatShowObjs, QSP_FMT("SHOWOBJS"), 2);
	qspAddStatName(qspStatShowVars, QSP_FMT("SHOWSTAT"), 2);
	qspAddStatName(qspStatUnSelect, QSP_FMT("UNSELECT"), 1);
	qspAddStatName(qspStatUnSelect, QSP_FMT("UNSEL"), 2);
	qspAddStatName(qspStatView, QSP_FMT("VIEW"), 2);
	qspAddStatName(qspStatWait, QSP_FMT("WAIT"), 2);
	qspAddStatName(qspStatXGoTo, QSP_FMT("XGOTO"), 2);
	qspAddStatName(qspStatXGoTo, QSP_FMT("XGT"), 2);
	for (i = 0; i < QSP_STATSLEVELS; ++i)
		qsort(qspStatsNames[i], qspStatsNamesCounts[i], sizeof(QSPStatName), qspStatsCompare);
}

static int qspGetStatCode(QSP_CHAR *s, QSP_CHAR **pos)
{
	int i;
	QSP_CHAR *uStr;
	QSPStatName *name;
	if (!(*s)) return qspStatUnknown;
	if (*s == QSP_LABEL[0]) return qspStatLabel;
	if (*s == QSP_COMMENT[0]) return qspStatComment;
	/* ------------------------------------------------------------------ */
	qspUpperStr(uStr = qspGetNewText(s, qspStatMaxLen));
	for (i = 0; i < QSP_STATSLEVELS; ++i)
	{
		name = (QSPStatName *)bsearch(uStr, qspStatsNames[i], qspStatsNamesCounts[i], sizeof(QSPStatName), qspStatStringCompare);
		if (name && qspIsInListEOL(QSP_DELIMS, s[name->NameLen]))
		{
			*pos = s + name->NameLen;
			free(uStr);
			return name->Code;
		}
	}
	free(uStr);
	return qspStatUnknown;
}

static int qspSearchElse(QSPLineOfCode *s, int start, int end)
{
	int c = 1;
	s += start;
	while (start < end)
	{
		switch (s->Stats->Stat)
		{
		case qspStatAct:
		case qspStatIf:
			if (s->IsMultiline) ++c;
			break;
		case qspStatElse:
		case qspStatElseIf:
			if (c == 1) return start;
			break;
		case qspStatEnd:
			if (!(--c)) return -1;
			break;
		}
		++start;
		++s;
	}
	return -1;
}

static int qspSearchEnd(QSPLineOfCode *s, int start, int end)
{
	int c = 1;
	s += start;
	while (start < end)
	{
		switch (s->Stats->Stat)
		{
		case qspStatAct:
		case qspStatIf:
			if (s->IsMultiline) ++c;
			break;
		case qspStatEnd:
			if (!(--c)) return start;
			break;
		}
		++start;
		++s;
	}
	return -1;
}

static int qspSearchLabel(QSPLineOfCode *s, int start, int end, QSP_CHAR *str)
{
	s += start;
	while (start < end)
	{
		if (s->Label && !qspStrsComp(s->Label, str)) return start;
		++start;
		++s;
	}
	return -1;
}

int qspGetStatArgs(QSP_CHAR *s, int statCode, QSPVariant *args)
{
	int type;
	int oldRefreshCount, count = 0;
	QSP_CHAR *pos, *brack = 0;
	s = qspSkipSpaces(s);
	if (*s == QSP_LRBRACK[0])
	{
		if (!(brack = qspStrPos(s, QSP_RRBRACK, QSP_FALSE)))
		{
			qspSetError(QSP_ERR_BRACKNOTFOUND);
			return 0;
		}
		if (qspIsAnyString(brack + 1))
			brack = 0;
		else
		{
			*brack = 0;
			s = qspSkipSpaces(s + 1);
		}
	}
	if (*s)
	{
		oldRefreshCount = qspRefreshCount;
		while (1)
		{
			if (count == qspStats[statCode].MaxArgsCount)
			{
				qspSetError(QSP_ERR_ARGSCOUNT);
				break;
			}
			pos = qspStrPos(s, QSP_COMMA, QSP_FALSE);
			if (pos)
			{
				*pos = 0;
				args[count] = qspExprValue(s);
				*pos = QSP_COMMA[0];
			}
			else
				args[count] = qspExprValue(s);
			if (qspRefreshCount != oldRefreshCount || qspErrorNum) break;
			type = qspStats[statCode].ArgsTypes[count];
			if (type && qspConvertVariantTo(args + count, type == 1))
			{
				qspSetError(QSP_ERR_TYPEMISMATCH);
				++count;
				break;
			}
			++count;
			if (!pos) break;
			s = qspSkipSpaces(pos + QSP_LEN(QSP_COMMA));
			if (!(*s))
			{
				qspSetError(QSP_ERR_SYNTAX);
				break;
			}
		}
		if (qspRefreshCount != oldRefreshCount || qspErrorNum)
		{
			qspFreeVariants(args, count);
			if (brack) *brack = QSP_RRBRACK[0];
			return 0;
		}
	}
	if (brack) *brack = QSP_RRBRACK[0];
	if (count < qspStats[statCode].MinArgsCount)
	{
		qspSetError(QSP_ERR_ARGSCOUNT);
		qspFreeVariants(args, count);
		return 0;
	}
	return count;
}

static QSP_BOOL qspExecString(QSPLineOfCode *s, int startStat, int endStat, QSP_CHAR **jumpTo)
{
	QSPVariant args[QSP_STATMAXARGS];
	QSP_BOOL isExit;
	QSP_CHAR *pos;
	int i, statCode, count, oldRefreshCount = qspRefreshCount;
	for (i = startStat; i < endStat; ++i)
	{
		statCode = s->Stats[i].Stat;
		switch (statCode)
		{
		case qspStatUnknown:
		case qspStatLabel:
		case qspStatElse:
		case qspStatEnd:
			break;
		case qspStatComment:
		case qspStatElseIf:
			return QSP_FALSE;
		case qspStatAct:
			qspStatementAddAct(s, i, endStat);
			return QSP_FALSE;
		case qspStatIf:
			return qspStatementIf(s, i, endStat, jumpTo);
		case qspStatSet:
			if (i < s->StatsCount - 1)
			{
				pos = s->Str + s->Stats[i].EndPos;
				*pos = 0;
				qspStatementSetVarValue(s->Str + s->Stats[i].ParamPos);
				*pos = QSP_STATDELIM[0];
			}
			else
				qspStatementSetVarValue(s->Str + s->Stats[i].ParamPos);
			break;
		default:
			if (i < s->StatsCount - 1)
			{
				pos = s->Str + s->Stats[i].EndPos;
				*pos = 0;
				count = qspGetStatArgs(s->Str + s->Stats[i].ParamPos, statCode, args);
				*pos = QSP_STATDELIM[0];
			}
			else
				count = qspGetStatArgs(s->Str + s->Stats[i].ParamPos, statCode, args);
			if (qspRefreshCount != oldRefreshCount || qspErrorNum) return QSP_FALSE;
			isExit = qspStats[statCode].Func(args, count, jumpTo, qspStats[statCode].ExtArg);
			qspFreeVariants(args, count);
			if (isExit || qspRefreshCount != oldRefreshCount || qspErrorNum || **jumpTo) return isExit;
			break;
		}
	}
	return QSP_FALSE;
}

QSP_BOOL qspExecCode(QSPLineOfCode *s, int startLine, int endLine, int codeOffset, QSP_CHAR **jumpTo)
{
	QSPVariant args[2];
	QSPLineOfCode *line;
	QSP_CHAR *jumpToFake, *pos, *paramPos;
	int i, statCode, count, endPos, elsePos, oldRefreshCount;
	QSP_BOOL uLevel, isExecuted = QSP_FALSE, isExit = QSP_FALSE;
	oldRefreshCount = qspRefreshCount;
	/* Prepare temporary data */
	if (uLevel = !jumpTo)
	{
		jumpToFake = qspGetNewText(QSP_FMT(""), 0);
		jumpTo = &jumpToFake;
	}
	/* Code execution */
	i = startLine;
	while (i < endLine)
	{
		line = s + i;
		if (codeOffset > 0)
		{
			qspRealLine = line->LineNum + codeOffset;
			if (qspIsDebug && *line->Str)
			{
				qspCallDebug(line->Str);
				if (qspRefreshCount != oldRefreshCount) break;
			}
		}
		statCode = line->Stats->Stat;
		paramPos = line->Str + line->Stats->ParamPos;
		if (line->IsMultiline)
		{
			endPos = qspSearchEnd(s, ++i, endLine);
			if (endPos < 0)
			{
				qspSetError(QSP_ERR_ENDNOTFOUND);
				break;
			}
			pos = line->Str + line->Stats->EndPos;
			*pos = 0;
			count = qspGetStatArgs(paramPos, statCode, args);
			*pos = QSP_COLONDELIM[0];
			if (qspRefreshCount != oldRefreshCount || qspErrorNum) break;
			if (statCode == qspStatIf || statCode == qspStatElseIf)
			{
				elsePos = qspSearchElse(s, i, endLine);
				if (QSP_NUM(args[0]))
				{
					if (elsePos < 0) continue;
					isExit = qspExecCode(s, i, elsePos, codeOffset, jumpTo);
					isExecuted = QSP_TRUE;
				}
				else
				{
					i = (elsePos < 0 ? endPos : elsePos);
					continue;
				}
			}
			else
			{
				qspAddAction(args, count, s, i, endPos, codeOffset > 0);
				qspFreeVariants(args, count);
				if (qspErrorNum) break;
				i = endPos;
				continue;
			}
		}
		else if (statCode == qspStatElseIf)
		{
			pos = line->Str + line->Stats->EndPos;
			if (*pos != QSP_COLONDELIM[0])
			{
				qspSetError(QSP_ERR_COLONNOTFOUND);
				break;
			}
			endPos = qspSearchEnd(s, ++i, endLine);
			if (endPos < 0)
			{
				qspSetError(QSP_ERR_ENDNOTFOUND);
				break;
			}
			*pos = 0;
			qspGetStatArgs(paramPos, qspStatElseIf, args);
			*pos = QSP_COLONDELIM[0];
			if (qspRefreshCount != oldRefreshCount || qspErrorNum) break;
			if (QSP_NUM(args[0]))
			{
				isExit = qspExecString(line, 1, line->StatsCount, jumpTo);
				isExecuted = QSP_TRUE;
			}
			else
			{
				elsePos = qspSearchElse(s, i, endLine);
				i = (elsePos < 0 ? endPos : elsePos);
				continue;
			}
		}
		else if (statCode == qspStatElse)
		{
			endPos = qspSearchEnd(s, ++i, endLine);
			if (endPos < 0)
			{
				qspSetError(QSP_ERR_ENDNOTFOUND);
				break;
			}
			if (line->StatsCount > 1)
				isExit = qspExecString(line, 1, line->StatsCount, jumpTo);
			else
			{
				elsePos = qspSearchElse(s, i, endLine);
				if (elsePos < 0) continue;
				isExit = qspExecCode(s, i, elsePos, codeOffset, jumpTo);
			}
			isExecuted = QSP_TRUE;
		}
		if (isExecuted)
		{
			isExecuted = QSP_FALSE;
			i = endPos;
		}
		else
		{
			isExit = qspExecString(line, 0, line->StatsCount, jumpTo);
			++i;
		}
		if (isExit || qspRefreshCount != oldRefreshCount || qspErrorNum) break;
		if (**jumpTo)
		{
			i = qspSearchLabel(s, startLine, endLine, *jumpTo);
			if (i < 0)
			{
				if (uLevel) qspSetError(QSP_ERR_LABELNOTFOUND);
				break;
			}
			**jumpTo = 0;
		}
	}
	if (uLevel) free(jumpToFake);
	return isExit;
}

void qspExecStringAsCodeWithArgs(QSP_CHAR *s, QSPVariant *args, int count)
{
	QSPLineOfCode *strs;
	QSPVar local, *var;
	int oldRefreshCount;
	if (!(var = qspVarReference(QSP_VARARGS, QSP_TRUE))) return;
	qspMoveVar(&local, var);
	qspSetArgs(var, args, count);
	count = qspPreprocessData(s, &strs);
	oldRefreshCount = qspRefreshCount;
	qspExecCode(strs, 0, count, 0, 0);
	qspFreePrepLines(strs, count);
	if (qspRefreshCount != oldRefreshCount || qspErrorNum)
	{
		qspEmptyVar(&local);
		return;
	}
	if (!(var = qspVarReference(QSP_VARARGS, QSP_TRUE)))
	{
		qspEmptyVar(&local);
		return;
	}
	qspEmptyVar(var);
	qspMoveVar(var, &local);
}

QSP_CHAR *qspGetLineLabel(QSP_CHAR *str)
{
	QSP_CHAR *delimPos;
	str = qspSkipSpaces(str);
	if (*str == QSP_LABEL[0])
	{
		delimPos = qspStrChar(str, QSP_STATDELIM[0]);
		if (delimPos)
		{
			*delimPos = 0;
			str = qspDelSpc(str + 1);
			*delimPos = QSP_STATDELIM[0];
		}
		else
			str = qspDelSpc(str + 1);
		qspUpperStr(str);
		return str;
	}
	return 0;
}

void qspInitLineOfCode(QSPLineOfCode *line, QSP_CHAR *str, int lineNum)
{
	QSP_BOOL isInLoop, isSearchElse;
	int statCode, count = 0;
	QSP_CHAR ch, *uStr, *nextPos, *temp, *buf, *elsePos, *delimPos = 0, *paramPos = 0;
	line->Str = str;
	line->LineNum = lineNum;
	line->StatsCount = 0;
	line->Stats = 0;
	buf = qspSkipSpaces(str);
	statCode = qspGetStatCode(buf, &paramPos);
	if (*buf && statCode != qspStatComment)
	{
		isInLoop = isSearchElse = QSP_TRUE;
		elsePos = 0;
		qspUpperStr(uStr = qspGetNewText(str, -1));
		switch (statCode)
		{
		case qspStatAct:
		case qspStatIf:
		case qspStatElseIf:
			delimPos = qspStrPos(buf, QSP_COLONDELIM, QSP_FALSE);
			if (delimPos)
			{
				nextPos = delimPos + 1;
				if (!(*nextPos)) isInLoop = QSP_FALSE;
			}
			break;
		case qspStatElse:
			nextPos = qspSkipSpaces(paramPos);
			if (*nextPos == QSP_COLONDELIM[0]) ++nextPos;
			delimPos = (*nextPos ? nextPos : 0);
			break;
		default:
			delimPos = qspStrPos(buf, QSP_STATDELIM, QSP_FALSE);
			if (delimPos) nextPos = delimPos + 1;
			elsePos = qspStrPos(uStr + (buf - str), QSP_STATELSE, QSP_TRUE);
			if (elsePos)
				elsePos = str + (elsePos - uStr);
			else
				isSearchElse = QSP_FALSE;
			if (elsePos && (!delimPos || elsePos < delimPos))
			{
				nextPos = delimPos = elsePos;
				elsePos = 0;
			}
			if (statCode == qspStatUnknown && buf != delimPos)
			{
				if (delimPos)
				{
					*delimPos = 0;
					temp = qspStrPos(buf, QSP_EQUAL, QSP_FALSE);
					*delimPos = QSP_STATDELIM[0];
				}
				else
					temp = qspStrPos(buf, QSP_EQUAL, QSP_FALSE);
				statCode = (temp ? qspStatSet : qspStatMPL);
			}
			break;
		}
		while (delimPos && isInLoop)
		{
			line->StatsCount++;
			line->Stats = (QSPCachedStat *)realloc(line->Stats, line->StatsCount * sizeof(QSPCachedStat));
			line->Stats[count].Stat = statCode;
			line->Stats[count].EndPos = (int)(delimPos - str);
			if (paramPos)
				line->Stats[count].ParamPos = (int)(qspSkipSpaces(paramPos) - str);
			else
				line->Stats[count].ParamPos = (int)(buf - str);
			++count;
			buf = qspSkipSpaces(nextPos);
			paramPos = 0;
			statCode = qspGetStatCode(buf, &paramPos);
			if (*buf && statCode != qspStatComment)
			{
				switch (statCode)
				{
				case qspStatAct:
				case qspStatIf:
				case qspStatElseIf:
					delimPos = qspStrPos(buf, QSP_COLONDELIM, QSP_FALSE);
					if (delimPos)
					{
						nextPos = delimPos + 1;
						if (!(*nextPos)) isInLoop = QSP_FALSE;
					}
					break;
				case qspStatElse:
					nextPos = qspSkipSpaces(paramPos);
					if (*nextPos == QSP_COLONDELIM[0]) ++nextPos;
					delimPos = (*nextPos ? nextPos : 0);
					break;
				default:
					delimPos = qspStrPos(buf, QSP_STATDELIM, QSP_FALSE);
					if (delimPos) nextPos = delimPos + 1;
					if (elsePos && buf >= elsePos) elsePos = 0;
					if (!elsePos && isSearchElse)
					{
						elsePos = qspStrPos(uStr + (buf - str), QSP_STATELSE, QSP_TRUE);
						if (elsePos)
							elsePos = str + (elsePos - uStr);
						else
							isSearchElse = QSP_FALSE;
					}
					if (elsePos && (!delimPos || elsePos < delimPos))
					{
						nextPos = delimPos = elsePos;
						elsePos = 0;
					}
					if (statCode == qspStatUnknown && buf != delimPos)
					{
						if (delimPos)
						{
							ch = *delimPos;
							*delimPos = 0;
							temp = qspStrPos(buf, QSP_EQUAL, QSP_FALSE);
							*delimPos = ch;
						}
						else
							temp = qspStrPos(buf, QSP_EQUAL, QSP_FALSE);
						statCode = (temp ? qspStatSet : qspStatMPL);
					}
					break;
				}
			}
			else
				delimPos = 0;
		}
		free(uStr);
	}
	line->StatsCount++;
	line->Stats = (QSPCachedStat *)realloc(line->Stats, line->StatsCount * sizeof(QSPCachedStat));
	line->Stats[count].Stat = statCode;
	if (delimPos)
		line->Stats[count].EndPos = (int)(delimPos - str);
	else
		line->Stats[count].EndPos = (int)(qspStrEnd(buf) - str);
	if (paramPos)
		line->Stats[count].ParamPos = (int)(qspSkipSpaces(paramPos) - str);
	else
		line->Stats[count].ParamPos = (int)(buf - str);
	switch (line->Stats->Stat)
	{
	case qspStatAct:
	case qspStatIf:
	case qspStatElseIf:
		line->IsMultiline = (line->StatsCount == 1 && *(str + line->Stats->EndPos) == QSP_COLONDELIM[0]);
		break;
	default:
		line->IsMultiline = QSP_FALSE;
		break;
	}
	line->Label = qspGetLineLabel(str);
}

static QSP_BOOL qspStatementIf(QSPLineOfCode *s, int startStat, int endStat, QSP_CHAR **jumpTo)
{
	QSPVariant arg;
	int i, c, elseStat, oldRefreshCount;
	QSP_CHAR *pos = s->Str + s->Stats[startStat].EndPos;
	if (*pos != QSP_COLONDELIM[0])
	{
		qspSetError(QSP_ERR_COLONNOTFOUND);
		return QSP_FALSE;
	}
	elseStat = 0;
	c = 1;
	for (i = startStat + 1; i < endStat; ++i)
	{
		switch (s->Stats[i].Stat)
		{
		case qspStatIf:
			++c;
			break;
		case qspStatElse:
			--c;
			break;
		}
		if (!c)
		{
			elseStat = i;
			break;
		}
	}
	if (elseStat)
	{
		if (elseStat == startStat + 1)
		{
			qspSetError(QSP_ERR_CODENOTFOUND);
			return QSP_FALSE;
		}
		if (elseStat == endStat - 1)
		{
			qspSetError(QSP_ERR_CODENOTFOUND);
			return QSP_FALSE;
		}
	}
	else if (startStat == endStat - 1)
	{
		qspSetError(QSP_ERR_CODENOTFOUND);
		return QSP_FALSE;
	}
	oldRefreshCount = qspRefreshCount;
	*pos = 0;
	qspGetStatArgs(s->Str + s->Stats[startStat].ParamPos, qspStatIf, &arg);
	*pos = QSP_COLONDELIM[0];
	if (qspRefreshCount != oldRefreshCount || qspErrorNum) return QSP_FALSE;
	if (QSP_NUM(arg))
	{
		if (elseStat)
			return qspExecString(s, startStat + 1, elseStat, jumpTo);
		else
			return qspExecString(s, startStat + 1, endStat, jumpTo);
	}
	else if (elseStat)
		return qspExecString(s, elseStat + 1, endStat, jumpTo);
	return QSP_FALSE;
}

static QSP_BOOL qspStatementAddText(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	switch (extArg)
	{
	case 0:
		if (*QSP_STR(args[0]))
		{
			qspCurVarsLen = qspAddText(&qspCurVars, QSP_STR(args[0]), qspCurVarsLen, -1, QSP_FALSE);
			qspIsVarsDescChanged = QSP_TRUE;
		}
		break;
	case 1:
		if (*QSP_STR(args[0]))
		{
			qspCurDescLen = qspAddText(&qspCurDesc, QSP_STR(args[0]), qspCurDescLen, -1, QSP_FALSE);
			qspIsMainDescChanged = QSP_TRUE;
		}
		break;
	case 2:
		if (count) qspCurVarsLen = qspAddText(&qspCurVars, QSP_STR(args[0]), qspCurVarsLen, -1, QSP_FALSE);
		qspCurVarsLen = qspAddText(&qspCurVars, QSP_STRSDELIM, qspCurVarsLen, QSP_LEN(QSP_STRSDELIM), QSP_FALSE);
		qspIsVarsDescChanged = QSP_TRUE;
		break;
	case 3:
		if (count) qspCurDescLen = qspAddText(&qspCurDesc, QSP_STR(args[0]), qspCurDescLen, -1, QSP_FALSE);
		qspCurDescLen = qspAddText(&qspCurDesc, QSP_STRSDELIM, qspCurDescLen, QSP_LEN(QSP_STRSDELIM), QSP_FALSE);
		qspIsMainDescChanged = QSP_TRUE;
		break;
	case 4:
		qspCurVarsLen = qspAddText(&qspCurVars, QSP_STRSDELIM, qspCurVarsLen, QSP_LEN(QSP_STRSDELIM), QSP_FALSE);
		if (count) qspCurVarsLen = qspAddText(&qspCurVars, QSP_STR(args[0]), qspCurVarsLen, -1, QSP_FALSE);
		qspIsVarsDescChanged = QSP_TRUE;
		break;
	case 5:
		qspCurDescLen = qspAddText(&qspCurDesc, QSP_STRSDELIM, qspCurDescLen, QSP_LEN(QSP_STRSDELIM), QSP_FALSE);
		if (count) qspCurDescLen = qspAddText(&qspCurDesc, QSP_STR(args[0]), qspCurDescLen, -1, QSP_FALSE);
		qspIsMainDescChanged = QSP_TRUE;
		break;
	}
	return QSP_FALSE;
}

static QSP_BOOL qspStatementClear(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	switch (extArg)
	{
	case 0:
		if (qspClearText(&qspCurVars, &qspCurVarsLen))
			qspIsVarsDescChanged = QSP_TRUE;
		break;
	case 1:
		if (qspClearText(&qspCurDesc, &qspCurDescLen))
			qspIsMainDescChanged = QSP_TRUE;
		break;
	case 2:
		qspClearText(&qspCurInput, &qspCurInputLen);
		qspCallSetInputStrText(0);
		break;
	case 3:
		qspClearActions(QSP_FALSE);
		break;
	case 4:
		if (qspClearText(&qspCurVars, &qspCurVarsLen))
			qspIsVarsDescChanged = QSP_TRUE;
		if (qspClearText(&qspCurDesc, &qspCurDescLen))
			qspIsMainDescChanged = QSP_TRUE;
		qspClearText(&qspCurInput, &qspCurInputLen);
		qspClearActions(QSP_FALSE);
		qspCallSetInputStrText(0);
		break;
	case 5:
		qspClearVars(QSP_FALSE);
		qspClearObjectsWithNotify();
		break;
	case 6:
		qspClearIncludes(QSP_FALSE);
		if (qspCurLoc >= qspLocsCount) qspCurLoc = -1;
		break;
	}
	return QSP_FALSE;
}

static QSP_BOOL qspStatementExit(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	return QSP_TRUE;
}

static QSP_BOOL qspStatementGoSub(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	qspExecLocByNameWithArgs(QSP_STR(args[0]), args + 1, count - 1);
	return QSP_FALSE;
}

static QSP_BOOL qspStatementGoTo(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	int locInd = qspLocIndex(QSP_STR(args[0]));
	if (locInd < 0)
	{
		qspSetError(QSP_ERR_LOCNOTFOUND);
		return QSP_FALSE;
	}
	qspCurLoc = locInd;
	qspRefreshCurLoc(extArg, args + 1, count - 1);
	return QSP_FALSE;
}

static QSP_BOOL qspStatementJump(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	free(*jumpTo);
	qspUpperStr(*jumpTo = qspDelSpc(QSP_STR(args[0])));
	return QSP_FALSE;
}

static QSP_BOOL qspStatementWait(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	int num = QSP_NUM(args[0]);
	qspCallRefreshInt(QSP_TRUE);
	if (num < 0) num = 0;
	qspCallSleep(num);
	return QSP_FALSE;
}

static QSP_BOOL qspStatementSetTimer(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	int num = QSP_NUM(args[0]);
	if (num < 0) num = 0;
	qspTimerInterval = num;
	qspCallSetTimer(num);
	return QSP_FALSE;
}

static QSP_BOOL qspStatementShowWin(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	QSP_BOOL val = QSP_NUM(args[0]) != 0;
	switch (extArg)
	{
	case 0:
		qspCallShowWindow(QSP_WIN_ACTS, qspCurIsShowActs = val);
		break;
	case 1:
		qspCallShowWindow(QSP_WIN_OBJS, qspCurIsShowObjs = val);
		break;
	case 2:
		qspCallShowWindow(QSP_WIN_VARS, qspCurIsShowVars = val);
		break;
	case 3:
		qspCallShowWindow(QSP_WIN_INPUT, qspCurIsShowInput = val);
		break;
	}
	return QSP_FALSE;
}

static QSP_BOOL qspStatementRefInt(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	qspCallRefreshInt(QSP_TRUE);
	return QSP_FALSE;
}

static QSP_BOOL qspStatementView(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	QSP_CHAR *file;
	if (count && qspIsAnyString(QSP_STR(args[0])))
	{
		qspViewPath = qspGetAddText(qspViewPath, QSP_STR(args[0]), 0, -1);
		file = qspGetAbsFromRelPath(qspViewPath);
		qspCallShowPicture(file);
		free(file);
	}
	else
	{
		if (qspViewPath)
		{
			free(qspViewPath);
			qspViewPath = 0;
		}
		qspCallShowPicture(0);
	}
	return QSP_FALSE;
}

static QSP_BOOL qspStatementMsg(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	qspCallShowMessage(QSP_STR(args[0]));
	return QSP_FALSE;
}

static QSP_BOOL qspStatementExec(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	qspCallSystem(QSP_STR(args[0]));
	return QSP_FALSE;
}

static QSP_BOOL qspStatementDynamic(QSPVariant *args, int count, QSP_CHAR **jumpTo, int extArg)
{
	qspExecStringAsCodeWithArgs(QSP_STR(args[0]), args + 1, count - 1);
	return QSP_FALSE;
}
