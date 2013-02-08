//
//  PTErrorTableView.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/7/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTErrorTableCell.h"
#import "PTErrorTableView.h"

#import "UIColor+ColorFromHex.h"

@implementation PTErrorTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        errorTable = [[UITableView alloc] initWithFrame:self.bounds];
        errorTable.backgroundColor = [UIColor colorFromHex:@"#EAB5AC"];
        errorTable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        errorTable.delegate = self;
        errorTable.dataSource = self;
        errorTable.separatorColor = [UIColor clearColor];
        errorTable.scrollEnabled = NO;
        errorTable.allowsSelection = NO;
        [self addSubview:errorTable];
        
        errors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)reloadWithErrors:(NSMutableArray *)theErrors {
    errors = theErrors;
    [errorTable reloadData];
}

#pragma mark - Tableview delegate and data source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [errors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PTErrorTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTErrorTableCell"];
    if (cell == nil) {
        cell = [[PTErrorTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PTErrorTableCell"];
    }
    
    cell.textLabel.text = [errors objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 24.0f;
}

@end
