//
//  GameViewController.m
//  QSP
//
//  Created by Stanislav Cherednichenko on 03.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import "GameViewController.h"
#import "Settings.h"
#import "SelectView.h"
#import "ObjectData.h"
#import "PlayerMainMenu.h"

#define SCENE_VIEW_TAG 120
#define INVENTORY_VIEW_TAG 130
#define DESCRIPTION_VIEW_TAG 140
#define ACTION_VIEW_TAG 150
#define RETURN_TO_MAINMENU 900

#define INPUTBOX_VIEW_TAG 1200

#define MAX_CHARS_IN_CELL 24



@implementation GameViewController

@synthesize sceneView, inventoryView, descriptionView, actionView, layoutView, descriptionButton, inventoryButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)back {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure to return to main menu?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, I sure", nil];
    alert.tag = RETURN_TO_MAINMENU;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case RETURN_TO_MAINMENU:
            if (buttonIndex == 1) {
                self.navigationController.navigationBarHidden = NO;
                [[PlayerMainMenu sharedPlayerMainMenu] update];
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        case INPUTBOX_VIEW_TAG:
            break;

        default:
            break;
    }
    [alertView release];
}

- (void)needModalWindow:(NSNotification *)notification {
    
    UIAlertView *alert = nil;
    UITextField *entry = nil;
    
    if ([[notification name] isEqualToString:@"QSP_CALL_INPUTBOX"]) {
        alert = [[UIAlertView alloc] initWithTitle:[[notification userInfo] objectForKey:@"text"] message:@" " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        CGRect frame = CGRectMake(14, (alert.frame.size.height - 45) + alert.frame.origin.y, 255, 29);
        entry = [[UITextField alloc] initWithFrame:CGRectZero];
        entry.borderStyle = UITextBorderStyleRoundedRect;
        
        entry.delegate = self;
        entry.textColor = [UIColor blackColor];
        entry.textAlignment = UITextAlignmentLeft;
        entry.font = [UIFont systemFontOfSize:14.0];
        entry.placeholder = @"";
        
        entry.autocorrectionType = UITextAutocorrectionTypeNo;
        entry.returnKeyType = UIReturnKeyDone;
        entry.clearButtonMode = UITextFieldViewModeWhileEditing;
        [alert addSubview:entry];
        alert.tag = INPUTBOX_VIEW_TAG;
    } else if ([[notification name] isEqualToString:@"QSP_CALL_SHOWWINDOW"]) {
        
    } else if ([[notification name] isEqualToString:@"QSP_CALL_SHOWMSGSTR"]) {
        
    }
    
    [alert show];
    entry.frame = CGRectMake(14, (alert.frame.size.height - 116), 255, 29);
    [entry becomeFirstResponder];
    
    // TODO: make it
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[QSPAdapter sharedQSPAdapter] beginGame];
    self.navigationController.navigationBarHidden = YES;
    fontRowWeight = ([[[Settings sharedSettings] fontWeight] floatValue] + 16);
    
    [self update];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    resultForActions = [[NSMutableArray alloc] initWithCapacity:1];
    resultForInventory = [[NSMutableArray alloc] initWithCapacity:1];
    
    self.actionView = [[SelectView alloc] init];
    actionView.tableView.delegate = self;
    actionView.tableView.dataSource = self;
    actionView.tableView.frame = CGRectMake(10, 10, 300, 196);
    actionView.frame = CGRectMake(0, 264, 320, 216);
    [self.sceneView.superview addSubview:actionView];
    for (id subview in self.sceneView.subviews) {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            ((UIScrollView *)subview).bounces = NO;
        }
    }
    for (id subview in self.descriptionView.subviews) {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            ((UIScrollView *)subview).bounces = NO;
        }
    }
    
    sceneView.tag = SCENE_VIEW_TAG;
    inventoryView.tag = INVENTORY_VIEW_TAG;
    descriptionView.tag = DESCRIPTION_VIEW_TAG;
    actionView.tableView.tag = ACTION_VIEW_TAG;
    
    inventoryButton.alpha = 0.5f;
    descriptionButton.alpha = 0.5f;
    
    [self bindObservers];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result = 30.0f;
    CGFloat lines = 1;
    
    switch (tableView.tag) {
        case ACTION_VIEW_TAG:
            lines = (float)[[[resultForActions objectAtIndex:indexPath.row] description] length] / MAX_CHARS_IN_CELL;
            break;
        case INVENTORY_VIEW_TAG:
            lines = (float)[[[resultForInventory objectAtIndex:indexPath.row] description] length] / MAX_CHARS_IN_CELL;
            break;
        default:
            break;
    }
    result = MAX(floorf(lines + 0.5f), 1.0f) * fontRowWeight;
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
    }
    
    ActionData *object = nil;
    switch (tableView.tag) {
        case ACTION_VIEW_TAG:
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.font = [[Settings sharedSettings] prefferedFont];
            cell.textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            object = [resultForActions objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageWithContentsOfFile:[object imagePath]];
            cell.textLabel.text = [object description];
            CGFloat lines = (float)[cell.textLabel.text length] / MAX_CHARS_IN_CELL;
            cell.textLabel.numberOfLines = MAX(floorf(lines + 0.5f), 1);
            break;
        case INVENTORY_VIEW_TAG:
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.font = [[Settings sharedSettings] prefferedFont];
            cell.detailTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            object = [resultForInventory objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageWithContentsOfFile:[object imagePath]];
            cell.detailTextLabel.text = [object description];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)localTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[localTableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    switch (localTableView.tag) {
        case ACTION_VIEW_TAG:
            [[QSPAdapter sharedQSPAdapter] setSelectedActionIndex:indexPath.row isRefresh:NO];
            [[QSPAdapter sharedQSPAdapter] executeSelectedActionCode:YES];
            break;
        case INVENTORY_VIEW_TAG:
            [[QSPAdapter sharedQSPAdapter] setSelectedObjectIndex:indexPath.row isRefresh:YES];
            break;
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    switch (table.tag) {
        case ACTION_VIEW_TAG:
            return [resultForActions count];
        case INVENTORY_VIEW_TAG:
            return [resultForInventory count];
        default:
            break;
    }
    return 0;
}

- (IBAction)descriptionButtonClicked:(id)sender {
    inventoryView.hidden = YES;
    descriptionView.hidden = !descriptionView.hidden;
    if (countOfFastClicking == 2) {
        [self back];
    } else if (countOfFastClicking == 0) {
        [self performSelector:@selector(resetBack) withObject:nil afterDelay:3];
    }
    countOfFastClicking++;
}

- (void)resetBack {
    countOfFastClicking = 0;
}

- (IBAction)inventoryButtonClicked:(id)sender {
    descriptionView.hidden = YES;
    inventoryView.hidden = !inventoryView.hidden;
    [self resetBack];
}

//

- (void)bindObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestOfRefresh:) name:@"QSP_CALL_REFRESHINT" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needModalWindow:) name:@"QSP_CALL_INPUTBOX" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needModalWindow:) name:@"QSP_CALL_SHOWWINDOW" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needModalWindow:) name:@"QSP_CALL_SHOWMSGSTR" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needModalWindow:) name:@"QSP_CALL_SETINPUTSTRTEXT" object:nil];
}

- (void)requestOfRefresh:(NSNotification *)notification {
    [self update];
}

- (void)update {
    if ([[QSPAdapter sharedQSPAdapter] isMainDescChanged]) {
        
        NSString *text = [[[QSPAdapter sharedQSPAdapter] getMainDesc] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br \\>"];
        if (![text isBlank]) {
            descriptionView.hidden = YES;
            inventoryView.hidden = YES;
        }
        [sceneView loadHTMLString:[NSString stringWithFormat:@"<div id='__iphone_size_hack' style='font-family:\"%@\";font-size:%@;'>%@</div>", [[Settings sharedSettings] fontFamily], [[Settings sharedSettings] fontWeight], text] baseURL:[NSURL URLWithString:nil]];   
        [layoutView scrollsToTop];
    }
    
    if ([[QSPAdapter sharedQSPAdapter] isActionsChanged]) {
        [resultForActions release];
        resultForActions = [[NSMutableArray alloc] initWithCapacity:[[QSPAdapter sharedQSPAdapter] getActionsCount]];
        
        for (NSInteger i = 0;i < [[QSPAdapter sharedQSPAdapter] getActionsCount]; i++) {
            [(NSMutableArray *)resultForActions addObject:[[QSPAdapter sharedQSPAdapter] getActionData:i]];
        }
        
        [actionView.tableView reloadData];
    }
    
    if ([[QSPAdapter sharedQSPAdapter] isObjectsChanged]) {
        [resultForInventory release];
        resultForInventory = [[NSMutableArray alloc] initWithCapacity:[[QSPAdapter sharedQSPAdapter] getObjectsCount]];
        
        for (NSInteger i = 0;i < [[QSPAdapter sharedQSPAdapter] getObjectsCount]; i++) {
            [(NSMutableArray *)resultForInventory addObject:[[QSPAdapter sharedQSPAdapter] getObjectData:i]];
        }
        
        [inventoryView reloadData];
    }
    
    if ([[QSPAdapter sharedQSPAdapter] isVarsDescChanged]) {
        [descriptionView loadHTMLString:[NSString stringWithFormat:@"<div style='font-family:\"%@\";font-size:%@;'>%@</div>", [[Settings sharedSettings] fontFamily], [[Settings sharedSettings] fontWeight], [[[QSPAdapter sharedQSPAdapter] getVarsDesc] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br \\>"]] baseURL:nil];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", [[request URL] absoluteString]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *output = nil;
    CGFloat result = 0;
    switch (webView.tag) {
        case SCENE_VIEW_TAG: // See XIB
            output = [sceneView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"__iphone_size_hack\").offsetHeight;"];
            result = MAX([output floatValue] + 16, 264);
            
            sceneView.frame = CGRectMake(0, 0, 320, result);
            layoutView.contentSize = CGSizeMake(0, result + 216);
            actionView.frame = CGRectMake(0, sceneView.frame.size.height, 320, 216);
            [layoutView scrollsToTop];
            break;
        case INVENTORY_VIEW_TAG: // See XIB
            break;
        case DESCRIPTION_VIEW_TAG: // See XIB
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
