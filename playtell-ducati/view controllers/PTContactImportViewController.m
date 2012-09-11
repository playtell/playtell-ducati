//
//  PTContactImportViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactImportViewController.h"
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

@interface PTContactImportViewController ()

@end

@implementation PTContactImportViewController

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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg"]];
    
    // Navigation controller setup
    self.title = @"Add Contacts";
    self.navigationController.navigationBar.alpha = 0.0f;
    self.navigationController.navigationBar.tintColor = [UIColor colorFromHex:@"#2e4857"];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorFromHex:@"#E3F1FF"], UITextAttributeTextColor, nil];
    
    // View style
    inviteNavigationBar.tintColor = [UIColor colorFromHex:@"#2e4857"];
    inviteNavigationBar.topItem.title = @"Invite";
    inviteContainer.backgroundColor = [UIColor colorFromHex:@"#e4ecef"];
    inviteContainer.layer.cornerRadius = 5.0f;
    inviteContainer.layer.masksToBounds = YES;
    inviteContainerOuter.layer.shadowColor = [UIColor blackColor].CGColor;
    inviteContainerOuter.layer.shadowOffset = CGSizeZero;
    inviteContainerOuter.layer.shadowOpacity = 0.3f;
    inviteContainerOuter.layer.shadowRadius = 4.0f;
    
    PTContactsNavCancelButton *buttonCancelView = [PTContactsNavCancelButton buttonWithType:UIButtonTypeCustom];
    buttonCancelView.frame = CGRectMake(0.0f, 0.0f, 65.0f, 33.0f);
    [buttonCancelView addTarget:self action:@selector(cancelContactImport:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:buttonCancelView];
    [inviteNavigationBar.topItem setLeftBarButtonItem:cancelButton];
    
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

    // Hide navbar
    [UIView animateWithDuration:0.2f animations:^{
        self.navigationController.navigationBar.alpha = 0.0f;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Show navbar
    [UIView animateWithDuration:0.2f animations:^{
        self.navigationController.navigationBar.alpha = 1.0f;
    }];
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
    NSURL *url = [NSURL URLWithString:@"https://www.google.com/m8/feeds/contacts/default/full?alt=json&max-results=2000"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher setAuthorizer:googleAuth];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
//            NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"------> Got contacts: %@", dataStr);
            NSError *jsonError;
            NSDictionary *contactsJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError == nil) {
                NSArray *entries = [[contactsJSON objectForKey:@"feed"] objectForKey:@"entry"];
                NSMutableArray *contacts = [NSMutableArray array];
                for (NSDictionary *entry in entries) {
                    // Verify name exists
                    if ([entry objectForKey:@"title"] == nil || [[[entry objectForKey:@"title"] objectForKey:@"$t"] length] == 0) {
                        continue;
                    }
                    NSString *title = [[[entry objectForKey:@"title"] objectForKey:@"$t"] copy];
                    
                    // Verify at least one email exists
                    if ([entry objectForKey:@"gd$email"] == nil) {
                        continue;
                    }
                    NSArray *entryEmails = [entry objectForKey:@"gd$email"];
                    for (NSDictionary *entryEmail in entryEmails) {
                        // Save this contact
                        NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 title,                                                  @"name",
                                                 [[entryEmail objectForKey:@"address"] lowercaseString], @"email",
                                                 @"Google Contacts",                                     @"source",
                                                 nil];
                        [contacts addObject:contact];
                    }
                    
                }

                NSLog(@"---> Contacts: %i", [contacts count]);
                
                // Load select controller
                PTContactSelectViewController *contactSelectViewController = [[PTContactSelectViewController alloc] initWithNibName:@"PTContactSelectViewController"
                                                                                                                             bundle:nil
                                                                                                                       withContacts:contacts];
                contactSelectViewController.sourceType = @"Google Contacts";
                [self.navigationController pushViewController:contactSelectViewController animated:YES];
            } else {
                // TODO: Handle error
                NSLog(@"JSON ERROR: %@", jsonError);
            }
        } else {
            // TODO: Handle error
            NSLog(@"ERROR: %@", error);
        }
    }];
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
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);

    NSMutableArray *contacts = [NSMutableArray array];
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
                [contacts addObject:contact];
            }
        }
        
        // Cleanup
        CFRelease(ref);
    }

    NSLog(@"---> Got contacts: %i", [contacts count]);
    
    // Load select controller
    PTContactSelectViewController *contactSelectViewController = [[PTContactSelectViewController alloc] initWithNibName:@"PTContactSelectViewController"
                                                                                                                 bundle:nil
                                                                                                           withContacts:contacts];
    contactSelectViewController.sourceType = @"Address Book";
    [self.navigationController pushViewController:contactSelectViewController animated:YES];
}

- (IBAction)manualInvite:(id)sender {
    if ([textName.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invite error"
                              message:@"Please enter a full name"
                              delegate:self
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil];
        [alert show];
        return;
    } else if ([textEmail.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invite error"
                              message:@"Please enter an email"
                              delegate:self
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSMutableDictionary *contact = [NSMutableDictionary dictionaryWithObjectsAndKeys:textName.text, @"name", textEmail.text, @"email", nil];
    NSMutableArray *contacts = [NSMutableArray arrayWithObjects:contact, nil];
    PTContactMessageViewController *contactMessageViewController = [[PTContactMessageViewController alloc] initWithNibName:@"PTContactMessageViewController" bundle:nil withContacts:contacts];
    [self.navigationController pushViewController:contactMessageViewController animated:YES];
}

#pragma make - Textfield delegates

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