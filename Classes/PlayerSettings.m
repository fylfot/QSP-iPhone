//
//  PlayerSettings.m
//  QSP
//
//  Created by Stanislav Cherednichenko on 02.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import "PlayerSettings.h"
#import "Settings.h"
#import "FontFamilies.h"

@implementation PlayerSettings

SYNTHESIZE_SINGLETON_FOR_CLASS(PlayerSettings);

#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    
    style = UITableViewStyleGrouped;
	if (self = [super initWithStyle:style]) {
        [[self tableView] setBackgroundColor:[UIColor clearColor]];
        self.title = @"Settings";
	}
    
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[Settings sharedSettings] save];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PlayerSettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        CUSTOM_TABLE_CELL_MACROS(cell);
        tableView.rowHeight = 40.0f;
        if (indexPath.row == 1) {
            
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(150, 11, 100, 23)];
            [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            slider.minimumValue = 9;
            slider.maximumValue = 72;
            [slider setTag:1];
            [cell addSubview:slider];
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Font family";
        if (![[[Settings sharedSettings] fontFamily] isBlank]) {
            cell.detailTextLabel.text = [[Settings sharedSettings] fontFamily];
        } else {
            cell.detailTextLabel.text = @"Helvetica";
        }
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.font = [UIFont fontWithName:cell.detailTextLabel.text size:17];
    } else {
        cell.textLabel.text = @"Font weight";
        if (![[[Settings sharedSettings] fontWeight] isBlank]) {
            cell.detailTextLabel.text = [[Settings sharedSettings] fontWeight];
            [(UISlider *)[cell viewWithTag:1] setValue:[[[Settings sharedSettings] fontWeight] floatValue]];
        } else {
            cell.detailTextLabel.text = @"17";
            [(UISlider *)[cell viewWithTag:1] setValue:17];
        }
    }

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (IBAction)sliderValueChanged:(id)sender {
    NSString *value = [NSString stringWithFormat:@"%3.0f", [(UISlider *)sender value]];
    [[Settings sharedSettings] setFontWeight:value];
    [[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] detailTextLabel] setText:value];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[[[FontFamilies alloc] init] autorelease] animated:YES];
    }
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
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

