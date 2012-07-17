//
//  PTContactImportViewController.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/11/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "PTContactImportViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "PTAppDelegate.h"
#import "TransitionController.h"
#import "GTMHTTPFetcher.h"
#import "PTContactsCreateListRequest.h"
#import "PTContactsGetListRequest.h"
#import "PTUser.h"
#import <AddressBook/AddressBook.h>

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
        
        // Load current contacts
        PTContactsGetListRequest *contactsGetListRequest = [[PTContactsGetListRequest alloc] init];
        [contactsGetListRequest getListWithAuthToken:[PTUser currentUser].authToken
                                             success:^(NSArray *contacts, NSInteger total) {
                                                 NSLog(@"Contacts: %@", contacts);
                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                 NSLog(@"Contacts error: %@, %@", error, JSON);
                                             }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date_bg"]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
                NSMutableDictionary *contacts = [NSMutableDictionary dictionary];
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
                    NSMutableArray *emails = [NSMutableArray arrayWithCapacity:[entryEmails count]];
                    for (NSDictionary *entryEmail in entryEmails) {
                        [emails addObject:[[entryEmail objectForKey:@"address"] copy]];
                    }
                    
                    // Save this contact
                    [contacts setObject:emails forKey:title];
                }
                NSLog(@"All: %@", contacts);
                NSLog(@"Total: %i", [[contacts allKeys] count]);
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
	return YES;
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
                                         [fullName copy],      @"name",
                                         [email copy],         @"email",
                                         @"iPad Address Book", @"source",
                                         nil];
                [contacts addObject:contact];
            }
        }
        
        // Cleanup
        CFRelease(ref);
    }

    NSLog(@"---> Saving contacts: %i", [contacts count]);
    
    // Save contacts to server
    PTContactsCreateListRequest *contactsCreateListRequest = [[PTContactsCreateListRequest alloc] init];
    [contactsCreateListRequest createList:contacts
                                authToken:[PTUser currentUser].authToken
                                  success:^(NSDictionary *result) {
                                      NSLog(@"Contacts result: %@", result);
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                      NSLog(@"Contacts error: %@, %@", error, JSON);
                                  }];
}

@end