//
//  PTContactImportViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactImportViewController.h"
#import "PTContactsNavBackButton.h"
#import "PTContactSelectViewController.h"
#import "PTContactMessageViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "GTMHTTPFetcher.h"
#import "PTUser.h"
#import "UIColor+HexColor.h"
#import "PTContactsNavCancelButton.h"
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import "PTUserEmailCheckRequest.h"
#import "PTUsersCreateFriendshipRequest.h"

@interface PTContactImportViewController ()

@end

@implementation PTContactImportViewController

@synthesize contacts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Grab google auth if available
        GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:@"PlayTellGoogleOAuth"
                                                                                              clientID:@"359489599578-aob6572j2g5v9s7agvn1u9hnj8vfnr56.apps.googleusercontent.com"
                                                                                          clientSecret:@"ht9PM-jZXhMgWD_4coOUyEcS"];
        if ([auth canAuthorize]) {
            googleAuth = auth;
        }
        
        // Keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
        isKeyboardShown = NO;

        // Contacts array
        self.contacts = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg"]];
    
    // Navigation controller setup
    self.title = @"Invite A Buddy By Email";
    
    // Nav buttons
    PTContactsNavBackButton *buttonBackView = [PTContactsNavBackButton buttonWithType:UIButtonTypeCustom];
    buttonBackView.frame = CGRectMake(0.0f, 0.0f, 75.0f, 33.0f);
    [buttonBackView addTarget:self action:@selector(navigateBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonBack = [[UIBarButtonItem alloc] initWithCustomView:buttonBackView];
    [self.navigationItem setLeftBarButtonItem:buttonBack];
    
    // View style
    inviteNavigationBar.tintColor = [UIColor colorFromHex:@"#3FA9F5"];
    inviteNavigationBar.topItem.title = @"Manual Invitation";
    inviteContainer.backgroundColor = [UIColor colorFromHex:@"#e4ecef"];
    inviteContainer.layer.cornerRadius = 5.0f;
    inviteContainer.layer.masksToBounds = YES;
    inviteContainerOuter.layer.shadowColor = [UIColor blackColor].CGColor;
    inviteContainerOuter.layer.shadowOffset = CGSizeZero;
    inviteContainerOuter.layer.shadowOpacity = 0.3f;
    inviteContainerOuter.layer.shadowRadius = 4.0f;
    
    inviteContainerTexts.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"inviteTextGroup"]];

    // External sources style
    inviteExternal.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"inviteExternalBg"]];
//    inviteExternal.layer.cornerRadius = 5.0f;
//    inviteExternal.layer.masksToBounds = YES;
    inviteExternalOuter.layer.shadowColor = [UIColor blackColor].CGColor;
    inviteExternalOuter.layer.shadowOffset = CGSizeZero;
    inviteExternalOuter.layer.shadowOpacity = 0.3f;
    inviteExternalOuter.layer.shadowRadius = 4.0f;
    
    // Textfield delegates
    textName.delegate = self;
    textEmail.delegate = self;
    textEmail.tag = 1;
    
    // Button styles
    [buttonSendInvite setBackgroundImage:[UIImage imageNamed:@"buttonSendInviteNormal"] forState:UIControlStateNormal];
    [buttonSendInvite setBackgroundImage:[UIImage imageNamed:@"buttonSendInviteHighlighted"] forState:UIControlStateHighlighted];
    [buttonSendInvite setTitleColor:[UIColor colorFromHex:@"#2e4957"] forState:(UIControlStateNormal|UIControlStateHighlighted)];
    [buttonSendInvite setTitleShadowColor:[UIColor colorFromHex:@"#ffffff" alpha:0.4f] forState:UIControlStateNormal];
    buttonSendInvite.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    
    [buttonGoogle setBackgroundImage:[UIImage imageNamed:@"buttonInviteGoogleNormal"] forState:UIControlStateNormal];
    [buttonGoogle setBackgroundImage:[UIImage imageNamed:@"buttonInviteGoogleHighlighted"] forState:UIControlStateHighlighted];
    [buttonGoogle setTitleColor:[UIColor colorFromHex:@"#ffffff"] forState:UIControlStateNormal];
    [buttonGoogle setTitleShadowColor:[UIColor colorFromHex:@"#26678f"] forState:UIControlStateNormal];
    buttonGoogle.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    
    [buttonAddressBook setBackgroundImage:[UIImage imageNamed:@"buttonInviteContactsNormal"] forState:UIControlStateNormal];
    [buttonAddressBook setBackgroundImage:[UIImage imageNamed:@"buttonInviteContactsHighlighted"] forState:UIControlStateHighlighted];
    [buttonAddressBook setTitleColor:[UIColor colorFromHex:@"#ffffff"] forState:UIControlStateNormal];
    [buttonAddressBook setTitleShadowColor:[UIColor colorFromHex:@"#26678f"] forState:UIControlStateNormal];
    buttonAddressBook.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
}

- (void)viewWillAppear:(BOOL)animated {
    // Reset fields
    textEmail.text = @"";
    textName.text = @"";
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    // Keyboard notifications cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)navigateBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelContactImport:(id)sender {
    PTAppDelegate* appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.transitionController transitionToViewController:(UIViewController *)appDelegate.dialpadController
                                                     withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (void)keyboardWillShow {
    isKeyboardShown = YES;
    [UIView animateWithDuration:0.3f animations:^{
        inviteContainerOuter.frame = CGRectOffset(inviteContainerOuter.frame, 0.0f, -120.0f);
        inviteExternalOuter.frame = CGRectOffset(inviteExternalOuter.frame, 0.0f, -300.0f);
        inviteExternalOuter.alpha = 0.0f;
    }];
}

- (void)keyboardWillHide {
    isKeyboardShown = NO;
    [UIView animateWithDuration:0.3f animations:^{
        inviteContainerOuter.frame = CGRectOffset(inviteContainerOuter.frame, 0.0f, 120.0f);
        inviteExternalOuter.frame = CGRectOffset(inviteExternalOuter.frame, 0.0f, 300.0f);
        inviteExternalOuter.alpha = 1.0f;
    }];
}

- (IBAction)googleContactsStart:(id)sender {
    if (googleAuth == nil) {
        NSLog(@"Need auth");
        [self googleContactsAuth];
    } else {
        NSLog(@"HAVE auth!");
        [self getGoogleContacts];
    }
}

- (void)googleContactsAuth {
    static NSString *const kKeychainItemName = @"PlayTellGoogleOAuth";
    
    NSString *kMyClientID = @"359489599578-aob6572j2g5v9s7agvn1u9hnj8vfnr56.apps.googleusercontent.com";
    NSString *kMyClientSecret = @"ht9PM-jZXhMgWD_4coOUyEcS";
    NSString *scope = @"https://www.google.com/m8/feeds";
    
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                clientID:kMyClientID
                                                            clientSecret:kMyClientSecret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    if (error != nil) {
        NSLog(@"Error occurred: %@", error.userInfo);
    } else {
        NSLog(@"Google Contacts success!");
        googleAuth = auth;
        
        // Get contacts
        [self getGoogleContacts];
    }
}

- (void)getGoogleContacts {
    PTContactSelectViewController *contactSelectViewController = [[PTContactSelectViewController alloc] initWithNibName:@"PTContactSelectViewController"
                                                                                                                 bundle:nil
                                                                                                        usingGoogleAuth:googleAuth];
    contactSelectViewController.sourceType = @"Google Contacts";
    [self.navigationController pushViewController:contactSelectViewController animated:YES];
}

- (IBAction)googleLogout:(id)sender {
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:@"PlayTellGoogleOAuth"];
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:googleAuth];
    googleAuth = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)localAddressBook:(id)sender {
    ABAddressBookRef addressBook;
    // iOS 6 and up
    if (ABAddressBookGetAuthorizationStatus != NULL) {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        
        // Check address book permission
        if (status != kABAuthorizationStatusAuthorized) {
            CFErrorRef error = nil;
            addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
    //                if (error) {
    //                    NSError* nsError = (__bridge NSError*)error;
    //                    NSLog(@"nsError: %@", nsError.localizedDescription);
    //                }
                    // Permission granted?
                    if (granted && !error) {
                        [self getContactsFromAddressBook:addressBook];
                    }
                });
            });
        } else {
            addressBook = ABAddressBookCreate();
            [self getContactsFromAddressBook:addressBook];
        }
    } else {
        // Pre-iOS 6
        addressBook = ABAddressBookCreate();
        [self getContactsFromAddressBook:addressBook];
    }
}

- (void)getContactsFromAddressBook:(ABAddressBookRef)addressBook {
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableArray *abContacts = [NSMutableArray array];
    for (int i=0; i<nPeople; i++) {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        // Get emails
        ABMultiValueRef emailsRef = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if (emailsRef) {
            for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
                NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailsRef, i);
                
                // Save the contact
                NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [fullName copy],                @"name",
                                         [[email copy] lowercaseString], @"email",
                                         @"iPad Address Book",           @"source",
                                         nil];
                [abContacts addObject:contact];
            }
        }
        
        // Cleanup
        CFRelease(ref);
    }
    
    NSLog(@"---> Got contacts: %i", [abContacts count]);
    
    // Load select controller
    PTContactSelectViewController *contactSelectViewController = [[PTContactSelectViewController alloc] initWithNibName:@"PTContactSelectViewController"
                                                                                                                 bundle:nil
                                                                                                           withContacts:abContacts];
    contactSelectViewController.sourceType = @"Address Book";
    [self.navigationController pushViewController:contactSelectViewController animated:YES];
}

- (IBAction)manualInvite:(id)sender {
    self.contacts = [[NSMutableArray alloc] init];
    // Validate name
    NSArray *nameParts = [textName.text componentsSeparatedByString:@" "];
    if ([nameParts count] < 2) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invite error"
                              message:@"Please enter a full name"
                              delegate:self
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Validate email
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if (![emailTest evaluateWithObject:textEmail.text]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invite error"
                              message:@"Please enter an email"
                              delegate:self
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Temporarily disable the button
    buttonSendInvite.enabled = NO;
    
    // Check if the email belongs to an existing user
    PTUserEmailCheckRequest *apiRequest = [[PTUserEmailCheckRequest alloc] init];
    [apiRequest checkEmail:textEmail.text
                returnUser:YES
                   success:^(NSDictionary *result) {
                       BOOL isEmailAvailable = [[result objectForKey:@"available"] boolValue];
                       if (isEmailAvailable == NO) {
                           // If email is taken, it must belong to a user -> find their user id
                           NSInteger userId = [[result objectForKey:@"user_id"] integerValue];

                           // Create friendship
                           [self createFriendshipWithUserId:userId];
                       } else {
                           // If email is available, it doesn't belong to an existing user -> send manual invitation
                           dispatch_async(dispatch_get_main_queue(), ^{
                               // Show compose msg view controller
                               NSMutableDictionary *contact = [NSMutableDictionary dictionaryWithObjectsAndKeys:textName.text, @"name", textEmail.text, @"email", nil];
                               [self.contacts addObject:contact];
                               
                               PTContactMessageViewController *contactMessageViewController = [[PTContactMessageViewController alloc] initWithNibName:@"PTContactMessageViewController" bundle:nil withContacts:self.contacts];
                               [self.navigationController pushViewController:contactMessageViewController animated:YES];
                           });
                       }

                       // Enable the button
                       dispatch_async(dispatch_get_main_queue(), ^{
                           buttonSendInvite.enabled = YES;
                       });
                   }
                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                       NSLog(@"EMAIL FAILURE: %@", error);
                       NSLog(@"EMAIL FAILURE: %@", JSON);
                       // Enable the button
                       dispatch_async(dispatch_get_main_queue(), ^{
                           buttonSendInvite.enabled = YES;
                       });
                   }];
}

#pragma mark - Friending

- (void)createFriendshipWithUserId:(NSInteger)userId {
    // API call to create friendship
    PTUsersCreateFriendshipRequest *usersCreateFriendshipRequest = [[PTUsersCreateFriendshipRequest alloc] init];
    [usersCreateFriendshipRequest userCreateFriendship:userId
                                             authToken:[[PTUser currentUser] authToken]
                                               success:^(NSDictionary *result) {
                                                   // Created friendship request, now go to Dialpad
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self cancelContactImport:nil];
                                                   });
                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                   // Failed creating friendship request, now go to Dialpad
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self cancelContactImport:nil];
                                                   });
                                               }];
}

#pragma mark - Textfield delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0) {
        [textEmail becomeFirstResponder];
    } else {
        [textEmail resignFirstResponder];
        [self manualInvite:textField];
    }
    return YES;
}

@end