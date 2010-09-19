//
//  SelectView.m
//  QSP
//
//  Created by Stanislav Cherednichenko on 19.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import "SelectView.h"


@implementation SelectView

@synthesize tableView;

- (id)init {
    self = [super init];
    
    if (self) {
        
        UIImageView *left = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 216)];
        left.image = [UIImage imageNamed:@"left_part.png"];
        
        UIImageView *right = [[UIImageView alloc] initWithFrame:CGRectMake(310, 0, 10, 216)];
        right.image = [UIImage imageNamed:@"right_part.png"];
        
        UIImageView *top = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, 294, 26)];
        top.image = [UIImage imageNamed:@"top_part.png"];
        
        UIImageView *bottom = [[UIImageView alloc] initWithFrame:CGRectMake(16, 190, 294, 26)];
        bottom.image = [UIImage imageNamed:@"bottom_part.png"];
        
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
        
        [self addSubview:tableView];
        [self addSubview:left];
        [self addSubview:right];
        [self addSubview:top];
        [self addSubview:bottom];
    }
    
    return self;
}

- (void)update {
    
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
