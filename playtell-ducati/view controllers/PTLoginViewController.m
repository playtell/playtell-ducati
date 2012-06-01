//
//  PTLoginViewController.m
//  PlayTell
//
//  Created by Ricky Hussmann on 3/13/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

//#import "ASIFormDataRequest.h"
#import "AFNetworking.h"
#import "PTAppDelegate.h"
#import "PTLoginViewController.h"
//#import "PTUser.h"

#import "NSDictionary+Util.h"
#import "NSMutableURLRequest+POSTParameters.h"

#import "UAirship.h"

typedef void (^PTLoginSuccessBlock) (NSDictionary*);
typedef void (^PTLoginFailureBlock) (NSError *);

@interface PTLoginViewController ()
- (NSString*)loginSettingsURL;
- (NSString*)playdateSettingsURL;
- (NSString*)authTokenURL;

- (void)showPasswordErrorArrowIndicators;
- (void)showError:(NSString*)errorMessage;
- (void)showErrorExclamationAndText:(NSString*)errorText;

- (void)activateNicknameField;
- (void)activateEmailField;
- (void)activatePasswordFields;
- (void)deactivateAllFields;

- (void)keyboardWasShown:(NSNotification*)keyboardNotification;
- (void)keyboardWillHide:(NSNotification*)keyboardNotification;

- (void)showConnectionError;
- (void)showArrowIndicatorsForFields:(NSArray*)errorFields;
- (void)resetErrorIndicators;
- (void)hideErrorHeader;
- (void)hideNicknameErrorArrowIndicator;
- (void)hideEmailErrorArrowIndicator;
- (void)hidePasswordErrorArrowIndicators;
- (void)showNicknameErrorArrowIndicator;
- (void)emphasizeNicknameText;
- (void)emphasizeEmailText;
- (void)showEmailErrorArrowIndicator;
- (void)showPasswordErrorArrowIndicators;
- (void)emphasizePasswordText;
- (void)resetFontColors;

- (void)requestSettingsUpdate;

- (void)loginWithUsername:(NSString*)aUsername password:(NSString*)aPassword
                 onSuccess:(PTLoginSuccessBlock)success onFailure:(PTLoginFailureBlock)failure;

@property (nonatomic, retain) UIImage* fieldActive;
@property (nonatomic, retain) UIImage* fieldInactive;
@property (nonatomic, retain) UIImage* doubleFieldActive;
@property (nonatomic, retain) UIImage* doubleFieldInactive;
@property (nonatomic, retain) UITextField* activeTextField;

@property (nonatomic, retain) NSString* tempUsername;
@property (nonatomic, retain) NSString* tempUserId;
@property (nonatomic, retain) NSString* tempToken;

@end

@implementation PTLoginViewController
@synthesize nicknameField, emailField, scrollView;
@synthesize passwordField, confirmPasswordField;
@synthesize passwordFieldBackground;
@synthesize errorHeaderBackground, errorExclamation, errorTextLabel;
@synthesize fieldActive, fieldInactive, doubleFieldActive, doubleFieldInactive;
@synthesize activeTextField;
@synthesize tempUsername, tempUserId, tempToken;

@synthesize nicknameError, emailError, firstPasswordError, secondPasswordError;


- (IBAction)doneButtonPressed:(id)sender {
    BOOL errorOcurred = NO;
    [self resetErrorIndicators];
    
    if (![self.nicknameField.text length]) {
        [self showNicknameErrorArrowIndicator];
        errorOcurred = YES;
    }

    if (![self.emailField.text length]) {
        [self showEmailErrorArrowIndicator];
        errorOcurred = YES;
    }

    if (![self.passwordField.text length]) {
        [self showPasswordErrorArrowIndicators];
        errorOcurred = YES;
    }

    [self.activeTextField resignFirstResponder];
    if (!errorOcurred) {
        [self loginWithUsername:self.emailField.text password:@"rg" onSuccess:^(NSDictionary *response) {
            NSString *authToken = [response valueForKey:@"token"];
            NSNumber *userId = [response valueForKey:@"user_id"];
            self.tempToken = authToken;
            self.tempUserId = [userId stringValue];
            self.tempUsername = self.emailField.text;
            [self requestSettingsUpdate];
        } onFailure:^(NSError *error) {
            [self showError:error.localizedDescription];
        }];
    } else {
        [self showError:@"Required fields missing"];
    }
}

-(void)resetErrorIndicators {
    [self hideErrorHeader];
    [self hideNicknameErrorArrowIndicator];
    [self hideEmailErrorArrowIndicator];
    [self hidePasswordErrorArrowIndicators];
    [self resetFontColors];
}

- (void)showNicknameErrorArrowIndicator {
    self.nicknameError.hidden = NO;
}

- (void)showEmailErrorArrowIndicator {
    self.emailError.hidden = NO;
}

- (void)showPasswordErrorArrowIndicators {
    self.firstPasswordError.hidden = NO;
    self.secondPasswordError.hidden = NO;
}

- (void)emphasizePasswordText {
    self.passwordField.textColor = UIColorFromRGB(0x88331C);
    self.confirmPasswordField.textColor = UIColorFromRGB(0x88331C);
}

- (void)hideErrorHeader {
    self.errorHeaderBackground.hidden = YES;
    self.errorTextLabel.hidden = YES;
    self.errorExclamation.hidden = YES;
}

- (void)hideNicknameErrorArrowIndicator {
    self.nicknameError.hidden = YES;
}

- (void)hideEmailErrorArrowIndicator {
    self.emailError.hidden = YES;
}

- (void)hidePasswordErrorArrowIndicators {
    self.firstPasswordError.hidden = YES;
    self.secondPasswordError.hidden = YES;
}

- (void)requestSettingsUpdate {

    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:self.tempToken, @"authentication_token",
                                    self.emailField.text, @"user[email]",
                                    self.passwordField.text, @"user[password]",
                                    self.confirmPasswordField.text, @"user[password_confirmation]",
                                    nil];

    NSURL* url = [NSURL URLWithString:[self loginSettingsURL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:url];
    [request setPostParameters:postParameters];

    AFJSONRequestOperation* updateSettings;
    updateSettings = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                     success:^(NSURLRequest *request,
                                                                               NSHTTPURLResponse *response,
                                                                               id JSON)
    {
        NSLog(@"Update settings success: %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Update settings failure: %@", error);
    }];
    [updateSettings start];
    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request setPostValue:self.tempToken forKey:@"authentication_token"];
//    [request setPostValue:self.emailField.text forKey:@"user[email]"];
//    [request setPostValue:self.passwordField.text forKey:@"user[password]"];
//    [request setPostValue:self.confirmPasswordField.text forKey:@"user[password_confirmation]"];
//    [request setFailedBlock:^{
//        NSLog(@"Failed response: %@", request.responseString);
//        NSError* failureParseError = nil;
//        NSDictionary* failureResponse = [NSJSONSerialization JSONObjectWithData:request.responseData
//                                                                        options:kNilOptions
//                                                                          error:&failureParseError];
//        if (failureParseError) {
//            NSLog(@"Error parsing failure text into JSON.");
//            [self showError:@"Error connecting to PlayTell for settings_update"];
//        } else {
//            // TODO : should ensure these keys exist before dereferencing them
//            NSLog(@"Parsed update_settings failure JSON: %@", failureResponse);
//            [self showArrowIndicatorsForFields:[failureResponse valueForKey:@"keys"]];
//            [self showErrorsForMessages:[failureResponse valueForKey:@"errors"]];
//        }
//    }];
//    [request setCompletionBlock:^{
//        NSLog(@"Succeeded response: %@", request.responseString);
//        if (request.responseStatusCode == 200) {
//            // TODO: need to guard against bad JSON
//            NSError *jsonDecodeError = nil;
//            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:request.responseData
//                                                                     options:kNilOptions
//                                                                       error:&jsonDecodeError];
//            if ([response containsKey:@"token"]) {
//                [[PTUser currentUser] setToken:[response valueForKey:@"token"]];
//                [[PTUser currentUser] setUserId:self.tempUserId];
//                [[PTUser currentUser] setUsername:self.tempUsername];
//            } else {
//                NSAssert(NO, @"Token not included in sign-in response");
//            }
//
//            [self dismissModalViewControllerAnimated:YES];
//            // TODO : this is hack-y. Need to rework it.
//            PTAppDelegate *appDelegate = (PTAppDelegate*)[[UIApplication sharedApplication] delegate];
//            [appDelegate finishAppLaunch];
//        } else {
//            [self showError:@"Unable to update settings"];
//        }
//    }];
//    [request startAsynchronous];
}

- (NSString*)loginSettingsURL {
    return [NSString stringWithFormat:@"%@/api/update_settings.json",
            ROOT_URL];
}

- (void)showArrowIndicatorsForFields:(NSArray*)errorFields {
    for (NSString* errorField in errorFields) {
        if ([errorField isEqualToString:@"password"]) {
            [self showPasswordErrorArrowIndicators];
            [self emphasizePasswordText];
        } else if ([errorField isEqualToString:@"username"]) {
            [self showNicknameErrorArrowIndicator];
            [self emphasizeNicknameText];
        } else if ([errorField isEqualToString:@"email"]) {
            [self showEmailErrorArrowIndicator];
        }
    }
}

- (void)emphasizeNicknameText {
    self.nicknameField.textColor = UIColorFromRGB(0x88331C);
}

- (void)emphasizeEmailText {
    self.emailField.textColor = UIColorFromRGB(0x88331C);
}

-(void)showErrorsForMessages:(NSArray*)errorMessages {
    NSString* concatendatedString = @"";
    for (NSString* message in errorMessages) {
        if ([concatendatedString length] > 0) {
            concatendatedString = [concatendatedString stringByAppendingString:@" "];
        }
        concatendatedString = [concatendatedString stringByAppendingString:message];
    }
    [self showError:concatendatedString];
}

- (NSString*)playdateSettingsURL {
    return [NSString stringWithFormat:@"%@/api/playdatephotos.json",
            ROOT_URL];
}

- (IBAction)testShowErrors:(id)sender {
    [self.activeTextField resignFirstResponder];
    [self showPasswordErrorArrowIndicators];
    [self showError:@"Test error"];
}

- (void)showError:(NSString*)errorMessage {

    CGRect exclamationRect = self.errorExclamation.frame;
    CGSize textSize = [errorMessage sizeWithFont:self.errorTextLabel.font
                                        forWidth:453.0 - (exclamationRect.size.width*2.0)
                                   lineBreakMode:UILineBreakModeTailTruncation];
    CGRect errorTextRect = self.errorTextLabel.frame;
    errorTextRect.size.width = textSize.width;
    self.errorTextLabel.frame = errorTextRect;

    CGRect bannerFrameOriginal = self.errorHeaderBackground.frame;
    CGRect bannerFrameNoHeight = bannerFrameOriginal;
    bannerFrameNoHeight.size.height = 0.0;

    CGPoint errorTextCenter = self.errorTextLabel.center;
    errorTextCenter.x = CGRectGetMidX(self.view.bounds) + exclamationRect.size.width/2.0;

    self.errorHeaderBackground.hidden = NO;
    self.errorHeaderBackground.frame = bannerFrameNoHeight;
    self.errorTextLabel.center = errorTextCenter;

    exclamationRect.origin.x = self.errorTextLabel.frame.origin.x - exclamationRect.size.width - 5.0;
    self.errorExclamation.frame = exclamationRect;
    [UIView animateWithDuration:0.5 animations:^{
        self.errorHeaderBackground.frame = bannerFrameOriginal;
    } completion:^(BOOL finished) {
        [self showErrorExclamationAndText:errorMessage];
    }];
}

- (void)showErrorExclamationAndText:(NSString*)errorText {
    self.errorExclamation.hidden = NO;
    self.errorExclamation.alpha = 0.0;
    self.errorTextLabel.hidden = NO;
    self.errorTextLabel.alpha = 0.0;
    self.errorTextLabel.text = errorText;

    [UIView animateWithDuration:0.5 animations:^{
        self.errorExclamation.alpha = 1.0;
        self.errorTextLabel.alpha = 1.0;
    }];
}

- (void)loginWithUsername:(NSString*)aUsername
                 password:(NSString*)aPassword
                onSuccess:(PTLoginSuccessBlock)success
                onFailure:(PTLoginFailureBlock)failure {

    NSDictionary* postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    aUsername, @"email",
                                    aPassword, @"password",
                                    [[UAirship shared] deviceToken], @"device_token",
                                    nil];

    NSURL *tokenURL = [NSURL URLWithString:[self authTokenURL]];
    NSMutableURLRequest* request = [NSMutableURLRequest postRequestWithURL:tokenURL];
    [request setPostParameters:postParameters];

    [[AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request,
                                                                              NSHTTPURLResponse *response,
                                                                              id JSON)
    {
        NSLog(@"Login success: %@", JSON);
        if (![JSON containsKey:@"token"]) {
            NSDictionary *errorDict = [NSDictionary dictionaryWithObject:[JSON valueForKey:@"message"]
                                                                  forKey:NSLocalizedDescriptionKey];
            failure([NSError errorWithDomain:@"PTLoginDomain"
                                        code:0
                                    userInfo:errorDict]);
            return;
        } else {
            success(JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Login failure: %@", error);
    }] start];
//    ASIFormDataRequest* loginRequest = [ASIFormDataRequest requestWithURL:tokenURL];
//    [loginRequest setPostValue:aUsername forKey:@"email"];
//    [loginRequest setPostValue:aPassword forKey:@"password"];
//    [loginRequest setPostValue:[[UAirship shared] deviceToken] forKey:@"device_token"];
//
//    [loginRequest setFailedBlock:^{
//        failure(loginRequest.error);
//    }];
//
//    [loginRequest setCompletionBlock:^{
//        NSError* decodingError = nil;
//        NSDictionary* loginDict = [NSJSONSerialization JSONObjectWithData:loginRequest.responseData
//                                                                  options:NSJSONReadingMutableContainers
//                                                                    error:&decodingError];
//
//        // TODO: Need to better handle this error...
//        if (decodingError) {
//            failure(decodingError);
//            return;
//        }
//
//        if (![loginDict containsKey:@"token"]) {
//            NSDictionary *errorDict = [NSDictionary dictionaryWithObject:[loginDict valueForKey:@"message"]
//                                                                  forKey:NSLocalizedDescriptionKey];
//            failure([NSError errorWithDomain:@"PTLoginDomain"
//                                        code:0
//                                    userInfo:errorDict]);
//            return;
//        } else {
//            success(loginDict);
//        }
//
//    }];
//    [loginRequest startAsynchronous];
}

- (NSString*)authTokenURL {
    return [NSString stringWithFormat:@"%@/api/tokens.json",
            ROOT_URL];
}

- (void)showConnectionError {
    [self showError:@"There seems to be a problem connecting..."];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fieldActive = [UIImage imageNamed:@"form-field-depressed.png"];
    self.fieldInactive = [UIImage imageNamed:@"form-field.png"];
    self.doubleFieldActive = [UIImage imageNamed:@"dual-form-field-depressed.png"];
    self.doubleFieldInactive = [UIImage imageNamed:@"dual-form-field.png"];

    self.emailField.textColor = UIColorFromRGB(0x397684);
    self.nicknameField.textColor = UIColorFromRGB(0x397684);
    self.passwordField.textColor = UIColorFromRGB(0x397684);
    self.confirmPasswordField.textColor = UIColorFromRGB(0x397684);
    self.errorTextLabel.textColor = UIColorFromRGB(0x88331C);
}

- (void)resetFontColors {
    self.emailField.textColor = UIColorFromRGB(0x397684);
    self.nicknameField.textColor = UIColorFromRGB(0x397684);
    self.passwordField.textColor = UIColorFromRGB(0x397684);
    self.confirmPasswordField.textColor = UIColorFromRGB(0x397684);
    self.errorTextLabel.textColor = UIColorFromRGB(0x88331C);
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.fieldActive =  nil;
    self.fieldInactive = nil;
    self.doubleFieldActive =  nil;
    self.doubleFieldInactive = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification*)keyboardNotification {
    NSDictionary* info = [keyboardNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = self.activeTextField.frame.origin;
    origin.y -= scrollView.contentOffset.y;
    CGPoint scrollPoint = CGPointMake(0.0, self.nicknameField.frame.origin.y-(aRect.size.height));
    [scrollView setContentOffset:scrollPoint animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)keyboardNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    [self.activeTextField resignFirstResponder];
    self.activeTextField = nil;

    [self deactivateAllFields];
}

#pragma mark - UITextFieldDelegate methods
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
    if (textField == self.nicknameField) {
        [self activateNicknameField];
    } else if (textField == self.emailField) {
        [self activateEmailField];
    } else {
        [self activatePasswordFields];
    }
}

//-(void)textFieldDidEndEditing:(UITextField *)textField {
//    self.activeTextField = nil;
//}

- (void)deactivateAllFields {
    [self.nicknameField setBackground:self.fieldInactive];
    [self.emailField setBackground:self.fieldInactive];
    [self.passwordFieldBackground setImage:self.doubleFieldInactive];
}

- (void)activateNicknameField {
    [self.nicknameField setBackground:self.fieldActive];
    [self.emailField setBackground:self.fieldInactive];
    [self.passwordFieldBackground setImage:self.doubleFieldInactive];
}

- (void)activateEmailField {
    [self.nicknameField setBackground:self.fieldInactive];
    [self.emailField setBackground:self.fieldActive];
    [self.passwordFieldBackground setImage:self.doubleFieldInactive];
}

- (void)activatePasswordFields {
    [self.nicknameField setBackground:self.fieldInactive];
    [self.emailField setBackground:self.fieldInactive];
    [self.passwordFieldBackground setImage:self.doubleFieldActive];
}

@end
