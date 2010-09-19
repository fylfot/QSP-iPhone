//
//  PlayerMainMenu.m
//  QSP
//
//  Created by Stanislav Cherednichenko on 02.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import "PlayerMainMenu.h"
#import "PlayerSettings.h"
#import "Worlds.h"
#import "World.h"
#import "GameViewController.h"

@implementation PlayerMainMenu

SYNTHESIZE_SINGLETON_FOR_CLASS(PlayerMainMenu);

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"QSP Menu";
    [self.tableView reloadData];
}

- (void)update {
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style {
    
    style = UITableViewStyleGrouped;
	if (self = [super initWithStyle:style]) {
        [[self tableView] setBackgroundColor:[UIColor clearColor]];
        self.tableView.rowHeight = 40.0f;
	}
    
	return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        if ([[QSPAdapter sharedQSPAdapter] isWorldLoaded]) {
            if ([[QSPAdapter sharedQSPAdapter] isGameInProgress]) {
                return 4;
            }
            return 2;
        }
    }
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PlayerMainMenuCell";
    
    UITableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        CUSTOM_TABLE_CELL_MACROS(cell);
        tableView.rowHeight = 40.0f;
    }
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Select World";
                if ([[QSPAdapter sharedQSPAdapter] isWorldLoaded]) {
                    cell.detailTextLabel.text = [[World selected] description];
                    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
                    cell.detailTextLabel.minimumFontSize = 12;
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 1:
                cell.textLabel.text = @"Configuration";
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        
        switch (indexPath.row) {
            case 0:
                
                if (![[QSPAdapter sharedQSPAdapter] isGameInProgress]) {
                    cell.textLabel.text = @"Start Game";
                } else {
                    cell.textLabel.text = @"Resume Game";
                }

                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 1:
                cell.textLabel.text = @"Load Game";
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 2:
                cell.textLabel.text = @"Save Game";
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 3:
                cell.textLabel.text = @"Restart Game";
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [[(QSPAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController] pushViewController:[[[Worlds alloc] init] autorelease] animated:YES];
                break;

            case 1:
                [[(QSPAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController] pushViewController:[PlayerSettings sharedPlayerSettings] animated:YES];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                if (![[QSPAdapter sharedQSPAdapter] isGameInProgress]) {
                    [[(QSPAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController] pushViewController:[[[GameViewController alloc] init] autorelease] animated:YES];
                } else {
                    [[QSPAdapter sharedQSPAdapter] restartGame:YES];
                    [[(QSPAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController] pushViewController:[[[GameViewController alloc] init] autorelease] animated:YES];
                }
                break;
            case 1:
                [[QSPAdapter sharedQSPAdapter] saveGame:[NSString stringWithFormat:@"%@/temp.sav", [[UIApplication sharedApplication] documentsDirectory]] isRefresh:YES];
                if ([[QSPAdapter sharedQSPAdapter] openSavedGame:[NSString stringWithFormat:@"%@/%@.sav", [[UIApplication sharedApplication] documentsDirectory], [[World selected] name]] isRefresh:NO]) {
                    [[(QSPAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController] pushViewController:[[[GameViewController alloc] init] autorelease] animated:YES];
                } else {
                    UIAlertViewQuick(@"Savegame", @"Savegame loading error", @"Ok");
                    [[QSPAdapter sharedQSPAdapter] openSavedGame:[NSString stringWithFormat:@"%@/temp.sav", [[UIApplication sharedApplication] documentsDirectory]] isRefresh:YES];
                }

                break;
                
            case 2:
                if ([[QSPAdapter sharedQSPAdapter] saveGame:[NSString stringWithFormat:@"%@/%@.sav", [[UIApplication sharedApplication] documentsDirectory], [[World selected] name]] isRefresh:NO]) {
                    UIAlertViewQuick(@"Savegame", @"Savegame saving complete", @"Ok");
                } else {
                    UIAlertViewQuick(@"Savegame", @"Savegame saving error", @"Ok");
                }
                
                break;
            case 3:
                [[QSPAdapter sharedQSPAdapter] restartGame:YES];
                [[(QSPAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController] pushViewController:[[[GameViewController alloc] init] autorelease] animated:YES];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

