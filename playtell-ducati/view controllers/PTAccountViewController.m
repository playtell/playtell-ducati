//
//  PTAccountViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/4/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTAccountViewController.h"
#import "PTSettingsTitleView.h"
#import "PTUser.h"

#import "UIColor+ColorFromHex.h"

@interface PTAccountViewController ()

@end

@implementation PTAccountViewController

@synthesize name;
@synthesize email;

- (id)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 500.0f, 500.0f)];
        self.view.autoresizesSubviews = YES;
        self.view.backgroundColor = [UIColor colorFromHex:@"#E4ECEF"];
        
        PTSettingsTitleView *topTitle = [[PTSettingsTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 30.0f)];
        topTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topTitle.textLabel.text = @"Contact Info";
        [self.view addSubview:topTitle];
        
        // Error table view
        errorTable = [[PTErrorTableView alloc] initWithFrame:CGRectMake(0.0f, topTitle.frame.size.height + 1, self.view.frame.size.width, 1.0f)];
        errorTable.hidden = YES;
        errorTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:errorTable];
        
        // Table view
        tableContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, topTitle.frame.size.height + 20, self.view.frame.size.width, 242.0f)];
        tableContainer.autoresizesSubviews = YES;
        tableContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        tableContainer.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tableContainer];
        
        inputTable = [[UITableView alloc] initWithFrame:CGRectMake(tableContainer.frame.size.width / 3, 0.0f, tableContainer.frame.size.width * 2 / 3 - 20, 172.0f) style:UITableViewStyleGrouped];
        inputTable.autoresizesSubviews = YES;
        inputTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        inputTable.delegate = self;
        inputTable.dataSource = self;
        inputTable.scrollEnabled = NO;
        inputTable.backgroundView = nil;
        [tableContainer addSubview:inputTable];
        
        // Labels for input text boxes
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 20.0f, tableContainer.frame.size.width / 3 - 20, 22.0f)];
        lblName.text = @"Full Name";
        lblName.textAlignment = UITextAlignmentRight;
        lblName.textColor = [UIColor colorFromHex:@"#2E4957"];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [tableContainer addSubview:lblName];
        UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 64.0f, tableContainer.frame.size.width / 3 - 20, 22.0f)];
        lblEmail.text = @"Email";
        lblEmail.textAlignment = UITextAlignmentRight;
        lblEmail.textColor = [UIColor colorFromHex:@"#2E4957"];
        lblEmail.backgroundColor = [UIColor clearColor];
        lblEmail.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [tableContainer addSubview:lblEmail];
                
        // Text fields
        txtName = [[UITextField alloc] init];
        txtEmail = [[UITextField alloc] init];
        
        // Error images
        errorName = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text-error"]];
        errorName.hidden = YES;
        errorEmail = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text-error"]];
        errorEmail.hidden = YES;
    }
    return self;
}

- (void)showErrors:(NSMutableArray *)errorsToShow {
    if ([errorsToShow count] == 0) {
        // Hide the error table
        [UIView animateWithDuration:0.2f animations:^{
            errorTable.frame = CGRectMake(errorTable.frame.origin.x, errorTable.frame.origin.y, errorTable.frame.size.width, 1.0f);
            tableContainer.frame = CGRectMake(tableContainer.frame.origin.x, errorTable.frame.origin.y + errorTable.frame.size.height + 20, tableContainer.frame.size.width, tableContainer.frame.size.height);
        } completion:^(BOOL finished) {
            errorTable.hidden = YES;
        }];
    } else {
        // Show the error table and change it to its new size
        [errorTable reloadWithErrors:errorsToShow];
        errorTable.hidden = NO;
        [UIView animateWithDuration:0.2f animations:^{
            errorTable.frame = CGRectMake(errorTable.frame.origin.x, errorTable.frame.origin.y, errorTable.frame.size.width, [errorsToShow count] * 24 + errorsToShow.count);
            tableContainer.frame = CGRectMake(tableContainer.frame.origin.x, errorTable.frame.origin.y + errorTable.frame.size.height + 20, tableContainer.frame.size.width, tableContainer.frame.size.height);
        }];
    }
}

#pragma mark - Tableview delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PasswordTextFieldCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PasswordTextFieldCell"];
    }
    
    float margin = 40.0f;
    
    switch (indexPath.row) {
        case 0: {
            // Name
            UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0.0f, tableView.frame.size.width - margin, 21.0f)];
            txtName.frame = cellView.bounds;
            txtName.font = [UIFont systemFontOfSize:16.0f];
            txtName.autocorrectionType = UITextAutocorrectionTypeNo;
            [txtName setClearButtonMode:UITextFieldViewModeNever];
            txtName.returnKeyType = UIReturnKeyDone;
            txtName.autocapitalizationType = UITextAutocapitalizationTypeWords;
            txtName.tag = kNameTag;
            txtName.delegate = self;
            [cellView addSubview:txtName];
            errorName.frame = CGRectMake(cellView.frame.size.width - errorName.frame.size.width, 2.0f, errorName.frame.size.width, errorName.frame.size.height);
            [cellView addSubview:errorName];
            cell.accessoryView = cellView;
            break;
        }
        case 1: {
            // Email
            UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0.0f, tableView.frame.size.width - margin, 21.0f)];
            txtEmail.frame = cellView.bounds;
            txtEmail.font = [UIFont systemFontOfSize:16.0f];
            txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
            [txtEmail setClearButtonMode:UITextFieldViewModeNever];
            txtEmail.returnKeyType = UIReturnKeyDone;
            txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
            txtEmail.tag = kEmailTag;
            txtEmail.delegate = self;
            [cellView addSubview:txtEmail];
            errorEmail.frame = CGRectMake(cellView.frame.size.width - errorEmail.frame.size.width, 2.0f, errorEmail.frame.size.width, errorEmail.frame.size.height);
            [cellView addSubview:errorEmail];
            cell.accessoryView = cellView;
            break;
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

#pragma mark - Textfield delegates & notification handler

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case kNameTag:
            [txtEmail becomeFirstResponder];
            break;
        case kEmailTag:
            [txtEmail resignFirstResponder];
            break;
    }
    
    return YES;
}

#pragma mark - Text field accessors

- (NSString *)name {
    if (txtName) {
        return txtName.text;
    } else {
        return nil;
    }
}

- (void)setName:(NSString *)aName {
    if (!txtName) {
        txtName = [[UITextField alloc] init];
    }
    txtName.text = aName;
}

- (NSString *)email {
    if (txtEmail) {
        return txtEmail.text;
    } else {
        return nil;
    }
}

- (void)setEmail:(NSString *)aEmail {
    if (!txtEmail) {
        txtEmail = [[UITextField alloc] init];
    }
    txtEmail.text = aEmail;
}

@end
