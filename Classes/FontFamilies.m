//
//  FontFamilies.m
//  QSP
//
//  Created by Stanislav Cherednichenko on 02.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import "FontFamilies.h"
#import "Settings.h"

@implementation FontFamilies

@synthesize objectsArray;

- (id)initWithStyle:(UITableViewStyle)style {
    
    style = UITableViewStyleGrouped;
	if (self = [super initWithStyle:style]) {
        [[self tableView] setBackgroundColor:[UIColor clearColor]];
        self.title = @"Fonts";
	}
    
    self.objectsArray = [UIFont familyNames];
    self.objectsArray = [self.objectsArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
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
    return [objectsArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FontFamiliesCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    CUSTOM_TABLE_CELL_MACROS(cell);
    
    NSString *value = [objectsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = value;
    cell.textLabel.font = [UIFont fontWithName:value size:17];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    [[Settings sharedSettings] setFontFamily:[self.objectsArray objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
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

