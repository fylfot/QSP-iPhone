//
//  Worlds.m
//  QSP
//
//  Created by Stanislav Cherednichenko on 02.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import "Worlds.h"
#import "World.h"
#import "QSPAdapter.h"
#import "PlayerMainMenu.h"

@implementation Worlds


#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    
    style = UITableViewStyleGrouped;
	if (self = [super initWithStyle:style]) {
        [[self tableView] setBackgroundColor:[UIColor clearColor]];
        self.title = @"Avalaible Worlds";
	}
    
	return self;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[World allObjects] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WorldsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        tableView.rowHeight = 40.0f;
    }
    CUSTOM_TABLE_CELL_MACROS(cell);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@.qsp", [[[World allObjects] objectAtIndex:indexPath.row] name]];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = [[[World allObjects] objectAtIndex:indexPath.row] description];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[QSPAdapter sharedQSPAdapter] loadGameWorld:[[[World allObjects] objectAtIndex:indexPath.row] relativePath]];
    [[QSPAdapter sharedQSPAdapter] restartGame:YES];
    [[PlayerMainMenu sharedPlayerMainMenu] update];
    [self.navigationController popToRootViewControllerAnimated:YES];
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

