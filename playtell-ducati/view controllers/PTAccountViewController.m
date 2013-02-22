//
//  PTAccountViewController.m
//  playtell-ducati
//
//  Created by Adam Horne on 2/4/13.
//  Copyright (c) 2013 PlayTell. All rights reserved.
//

#import "PTAccountViewController.h"
#import "PTSettingsTitleView.h"
#import "PTUpdateSettingsRequest.h"
#import "PTUser.h"

#import "UIColor+ColorFromHex.h"

@interface PTAccountViewController ()

@end

@implementation PTAccountViewController

@synthesize name;
@synthesize email;
@synthesize birthday;

@synthesize datePopoverController;

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
        UILabel *lblBirthday = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 130.0f, tableContainer.frame.size.width / 3 - 20, 22.0f)];
        lblBirthday.text = @"Birthday";
        lblBirthday.textAlignment = UITextAlignmentRight;
        lblBirthday.textColor = [UIColor colorFromHex:@"#2E4957"];
        lblBirthday.backgroundColor = [UIColor clearColor];
        lblBirthday.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [tableContainer addSubview:lblBirthday];
                
        // Text fields
        txtName = [[UITextField alloc] init];
        txtEmail = [[UITextField alloc] init];
        txtBirthday = [[UITextField alloc] init];
        
        // Error images
        errorName = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text-error"]];
        errorName.hidden = YES;
        errorEmail = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text-error"]];
        errorEmail.hidden = YES;
        errorBirthday = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text-error"]];
        errorBirthday.hidden = YES;
        
        // Date picker popover
        float popoverWidth = 320.0f;
        float popoverHeight = 160.0f;
        datePickerView = [[UIDatePicker alloc] init];
        datePickerView.datePickerMode = UIDatePickerModeDate;
        datePickerView.frame = CGRectMake(datePickerView.frame.origin.x, datePickerView.frame.origin.y, popoverWidth, popoverHeight);
        UIViewController *popoverContent = [[UIViewController alloc] init];
        popoverContent.view = datePickerView;
        self.datePopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.datePopoverController.delegate = self;
        [self.datePopoverController setPopoverContentSize:CGSizeMake(popoverWidth, popoverHeight) animated:NO];
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

- (BOOL)isAbove13:(NSDate *)compareDate {
    NSTimeInterval diff = [compareDate timeIntervalSinceNow];
    
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:diff sinceDate:date1];
    NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:NSYearCalendarUnit
                                                                       fromDate:date1
                                                                         toDate:date2
                                                                        options:0];
    
    NSInteger years = conversionInfo.year * -1;
    return (years >= 13);
}

- (void)updateBirthdayLabelUsingDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    txtBirthday.text = [dateFormatter stringFromDate:date];
}

- (void)accountHasNoBirthday {
    self.birthday = [NSDate date];
    [self showErrors:[NSMutableArray arrayWithObject:@"Please set your birthday"]];
    errorBirthday.hidden = NO;
}

#pragma mark - Tableview delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: // account info
            return 2;
            break;
        case 1: // birthday
            return 1;
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
            break;
        }
        case 1: {
            // Birthday
            UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0.0f, tableView.frame.size.width - margin, 21.0f)];
            txtBirthday.frame = cellView.bounds;
            txtBirthday.font = [UIFont systemFontOfSize:16.0f];
            txtBirthday.autocorrectionType = UITextAutocorrectionTypeNo;
            [txtBirthday setClearButtonMode:UITextFieldViewModeNever];
            txtBirthday.returnKeyType = UIReturnKeyDone;
            txtBirthday.autocapitalizationType = UITextAutocapitalizationTypeNone;
            txtBirthday.tag = kBirthdayTag;
            txtBirthday.delegate = self;
            [cellView addSubview:txtBirthday];
            errorBirthday.frame = CGRectMake(cellView.frame.size.width - errorBirthday.frame.size.width, 2.0f, errorBirthday.frame.size.width, errorBirthday.frame.size.height);
            [cellView addSubview:errorBirthday];
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
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    if (textField.tag == kNameTag) {
        // Validate first & last name presence
        NSArray *nameParts = [txtName.text componentsSeparatedByString:@" "];
        if ([nameParts count] < 2) {
            [errors addObject:@"Please enter both first and last names"];
        }
        [self showErrors:errors];
        
        if (errors.count == 0) {
            [txtName resignFirstResponder];
            errorName.hidden = YES;
            PTUpdateSettingsRequest *updateSettings = [[PTUpdateSettingsRequest alloc] init];
            [updateSettings updateSettingsWithUserId:[PTUser currentUser].userID
                                               email:nil
                                            username:txtName.text
                                            birthday:nil
                                           authToken:[PTUser currentUser].authToken
                                           onSuccess:^(NSDictionary *result)
             {
                 NSLog(@"User name successfully updated");
             }
                                           onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
             {
                 NSLog(@"User name was not updated: %@", error);
             }];
        } else {
            errorName.hidden = NO;
        }
    } else if (textField.tag == kEmailTag) {
        // Verify email string
        NSString *emailRegEx =
        @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
        @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
        @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
        @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
        @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
        @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
        @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        if (![emailTest evaluateWithObject:txtEmail.text]) {
            [errors addObject:@"Email is invalid, must have an \"@\" and a \".\""];
        }
        [self showErrors:errors];
        
        if (errors.count == 0) {
            [txtEmail resignFirstResponder];
            errorEmail.hidden = YES;
            PTUpdateSettingsRequest *updateSettings = [[PTUpdateSettingsRequest alloc] init];
            [updateSettings updateSettingsWithUserId:[PTUser currentUser].userID
                                               email:txtEmail.text
                                            username:nil
                                            birthday:nil
                                           authToken:[PTUser currentUser].authToken
                                           onSuccess:^(NSDictionary *result)
             {
                 NSLog(@"Email successfully updated");
             }
                                           onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
             {
                 NSLog(@"Email was not updated: %@", error);
             }];
        } else {
            errorEmail.hidden = NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == kBirthdayTag) {
        // Show the popover date picker control
        datePickerView.date = birthday;
        [datePopoverController presentPopoverFromRect:txtBirthday.frame inView:txtBirthday.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        return NO;
    }
    
    return YES;
}

#pragma mark - UIPopoverControllerDelegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    if (![self isAbove13:datePickerView.date]) {
        [errors addObject:@"The birthday should be at least thirteen years ago"];
    }
    [self showErrors:errors];
    
    if (errors.count == 0) {
        errorBirthday.hidden = YES;
        PTUpdateSettingsRequest *updateSettings = [[PTUpdateSettingsRequest alloc] init];
        [updateSettings updateSettingsWithUserId:[PTUser currentUser].userID
                                           email:nil
                                        username:nil
                                        birthday:datePickerView.date
                                       authToken:[PTUser currentUser].authToken
                                       onSuccess:^(NSDictionary *result)
         {
             NSLog(@"Birthday successfully updated");
             self.birthday = datePickerView.date;
         }
                                       onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
         {
             NSLog(@"Birthday was not updated: %@", error);
         }];
    } else {
        errorBirthday.hidden = NO;
    }
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

- (void)setBirthday:(NSDate *)aBirthday {
    birthday = aBirthday;
    [self updateBirthdayLabelUsingDate:aBirthday];
}

@end
