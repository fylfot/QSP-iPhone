
#define CUSTOM_TABLE_CELL_MACROS(cell) \
if (indexPath.row == 0 && [tableView numberOfRowsInSection:indexPath.section] == 1) { \
[cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_single.png"]] autorelease]]; \
[cell setSelectedBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_single_selected.png"]] autorelease]]; \
} else if (indexPath.row == 0) { \
[cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_nosingle_first.png"]] autorelease]]; \
[cell setSelectedBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_nosingle_first_selected.png"]] autorelease]]; \
} else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) { \
[cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_nosingle_last.png"]] autorelease]]; \
[cell setSelectedBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_nosingle_last_selected.png"]] autorelease]]; \
} else { \
[cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_nosingle_any.png"]] autorelease]]; \
[cell setSelectedBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_view_cell_nosingle_any_selected.png"]] autorelease]]; \
} \
[[cell textLabel] setBackgroundColor:[UIColor clearColor]]; \
[[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]]

