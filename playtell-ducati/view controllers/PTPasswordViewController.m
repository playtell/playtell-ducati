//
//  PTPasswordViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/4/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTPasswordViewController.h"
#import "PTSettingsTitleView.h"

#import "UIColor+ColorFromHex.h"

@interface PTPasswordViewController ()

@end

@implementation PTPasswordViewController
@synthesize currentPassword, password, confirmationPassword;

- (id)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 500.0f, 500.0f)];
        self.view.autoresizesSubviews = YES;
        self.view.backgroundColor = [UIColor colorFromHex:@"#E4ECEF"];
        
        PTSettingsTitleView *topTitle = [[PTSettingsTitleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 30.0f)];
        topTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topTitle.textLabel.text = @"Change Your Password";
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
        UILabel *lblCurrent = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 20.0f, tableContainer.frame.size.width / 3 - 20, 22.0f)];
        lblCurrent.text = @"Current Password";
        lblCurrent.textAlignment = UITextAlignmentRight;
        lblCurrent.textColor = [UIColor colorFromHex:@"#2E4957"];
        lblCurrent.backgroundColor = [UIColor clearColor];
        lblCurrent.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [tableContainer addSubview:lblCurrent];
        UILabel *lblNew = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 86.0f, tableContainer.frame.size.width / 3 - 20, 22.0f)];
        lblNew.text = @"New Password";
        lblNew.textAlignment = UITextAlignmentRight;
        lblNew.textColor = [UIColor colorFromHex:@"#2E4957"];
        lblNew.backgroundColor = [UIColor clearColor];
        lblNew.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [tableContainer addSubview:lblNew];
        UILabel *lblConfirm = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 130.0f, tableContainer.frame.size.width / 3 - 20, 22.0f)];
        lblConfirm.text = @"Verify Password";
        lblConfirm.textAlignment = UITextAlignmentRight;
        lblConfirm.textColor = [UIColor colorFromHex:@"#2E4957"];
        lblConfirm.backgroundColor = [UIColor clearColor];
        lblConfirm.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [tableContainer addSubview:lblConfirm];
        
        // Reset button
        resetButton = [[UIButton alloc] initWithFrame:CGRectMake(tableContainer.frame.size.width / 4, inputTable.frame.size.height + 20, tableContainer.frame.size.width / 2, 50.0f)];
        resetButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [resetButton setBackgroundImage:[UIImage imageNamed:@"buttonSendInviteNormal.png"] forState:UIControlStateNormal];
        [resetButton setTitle:@"Change Password" forState:UIControlStateNormal];
        [resetButton addTarget:self action:@selector(resetButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [tableContainer addSubview:resetButton];
        
        // Text fields
        txtCurrent = [[UITextField alloc] init];
        txtNew = [[UITextField alloc] init];
        txtConfirm = [[UITextField alloc] init];
        
        // Error images
        errorCurrent = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text-error"]];
        errorCurrent.hidden = YES;
        errorNew = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text-error"]];
        errorNew.hidden = YES;
        errorConfirm = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text-error"]];
        errorConfirm.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetButtonPressed {
    errorCurrent.hidden = YES;
    errorNew.hidden = YES;
    errorConfirm.hidden = YES;
    
    // Close the keyboard
    [txtCurrent resignFirstResponder];
    [txtNew resignFirstResponder];
    [txtConfirm resignFirstResponder];
    
    NSMutableArray *errors = [self compareNewPasswordWithConfirmation];
    if (self.currentPassword == nil || [self.currentPassword isEqualToString:@""]) {
        [errors insertObject:@"Please enter your current password" atIndex:0];
        errorCurrent.hidden = NO;
    }
    
    [self showErrors:errors];
}

- (NSMutableArray *)compareNewPasswordWithConfirmation {
    txtNew.textColor = [UIColor blackColor];
    txtConfirm.textColor = [UIColor blackColor];
    
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    bool passwordEmpty = NO;
    bool confirmEmpty = NO;
    
    if (self.password == nil || [self.password isEqualToString:@""]) {
        passwordEmpty = YES;
    }
    if (self.confirmationPassword == nil || [self.confirmationPassword isEqualToString:@""]) {
        confirmEmpty = YES;
    }
    
    if (!(passwordEmpty && confirmEmpty)) {
        if (passwordEmpty) {
            [errors addObject:@"A new password must be entered"];
            errorNew.hidden = NO;
        } else if (confirmEmpty) {
            [errors addObject:@"Please verify the new password"];
            errorConfirm.hidden = NO;
        } else if (![self.password isEqualToString:self.confirmationPassword]) {
            [errors addObject:@"The new passwords do not match"];
            errorNew.hidden = NO;
            errorConfirm.hidden = NO;
            txtNew.textColor = [UIColor redColor];
            txtConfirm.textColor = [UIColor redColor];
        }
    } else {
        [errors addObject:@"A new password must be entered"];
        errorNew.hidden = NO;
        errorConfirm.hidden = NO;
    }
    
    return errors;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PasswordTextFieldCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PasswordTextFieldCell"];
    }
    
    float margin = 40.0f;
    
    switch (indexPath.section) {
        case 0: {
            // Current password section
            UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0.0f, tableView.frame.size.width - margin, 21.0f)];
            txtCurrent.frame = cellView.bounds;
            txtCurrent.font = [UIFont boldSystemFontOfSize:16.0f];
            txtCurrent.secureTextEntry = YES;
            txtCurrent.autocorrectionType = UITextAutocorrectionTypeNo;
            [txtCurrent setClearButtonMode:UITextFieldViewModeNever];
            txtCurrent.returnKeyType = UIReturnKeyDone;
            txtCurrent.autocapitalizationType = UITextAutocapitalizationTypeNone;
            txtCurrent.tag = kCurrentTag;
            txtCurrent.delegate = self;
            [cellView addSubview:txtCurrent];
            errorCurrent.frame = CGRectMake(cellView.frame.size.width - errorCurrent.frame.size.width, 2.0f, errorCurrent.frame.size.width, errorCurrent.frame.size.height);
            [cellView addSubview:errorCurrent];
            cell.accessoryView = cellView;
            break;
        }
        case 1: {
            // New password section
            switch (indexPath.row) {
                case 0: {
                    // New password
                    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0.0f, tableView.frame.size.width - margin, 21.0f)];
                    txtNew.frame = cellView.bounds;
                    txtNew.font = [UIFont boldSystemFontOfSize:16.0f];
                    txtNew.secureTextEntry = YES;
                    txtNew.autocorrectionType = UITextAutocorrectionTypeNo;
                    [txtNew setClearButtonMode:UITextFieldViewModeNever];
                    txtNew.returnKeyType = UIReturnKeyDone;
                    txtNew.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    txtNew.tag = kNewTag;
                    txtNew.delegate = self;
                    [cellView addSubview:txtNew];
                    errorNew.frame = CGRectMake(cellView.frame.size.width - errorNew.frame.size.width, 2.0f, errorNew.frame.size.width, errorNew.frame.size.height);
                    [cellView addSubview:errorNew];
                    cell.accessoryView = cellView;
                    break;
                }
                case 1: {
                    // Confirmation password
                    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0.0f, tableView.frame.size.width - margin, 21.0f)];
                    txtConfirm.frame = cellView.bounds;
                    txtConfirm.font = [UIFont boldSystemFontOfSize:16.0f];
                    txtConfirm.secureTextEntry = YES;
                    txtConfirm.autocorrectionType = UITextAutocorrectionTypeNo;
                    [txtConfirm setClearButtonMode:UITextFieldViewModeNever];
                    txtConfirm.returnKeyType = UIReturnKeyDone;
                    txtConfirm.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    txtConfirm.tag = kConfirmTag;
                    txtConfirm.delegate = self;
                    [cellView addSubview:txtConfirm];
                    errorConfirm.frame = CGRectMake(cellView.frame.size.width - errorConfirm.frame.size.width, 2.0f, errorConfirm.frame.size.width, errorConfirm.frame.size.height);
                    [cellView addSubview:errorConfirm];
                    cell.accessoryView = cellView;
                    break;
                }
            }
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
        case kCurrentTag:
            [txtNew becomeFirstResponder];
            break;
        case kNewTag:
            [txtConfirm becomeFirstResponder];
            break;
        case kConfirmTag:
            [txtConfirm resignFirstResponder];
            break;
    }
    
    return YES;
}

#pragma mark - Text field accessors

- (NSString *)currentPassword {
    if (txtCurrent) {
        return txtCurrent.text;
    } else {
        return nil;
    }
}

- (NSString *)password {
    if (txtNew) {
        return txtNew.text;
    } else {
        return nil;
    }
}

- (NSString *)confirmationPassword {
    if (txtConfirm) {
        return txtConfirm.text;
    } else {
        return nil;
    }
}

@end
