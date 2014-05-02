//
//  CRDViewController.m
//  CredentialsDemo
//
//  Created by Adam Iredale on 11/04/2014.
//  Copyright (c) 2014 Bionic Monocle Pty Ltd. All rights reserved.
//

#import "CRDViewController.h"
#import <BMCredentials/BMCredentials.h>

@interface CRDViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *urlField;

@property (nonatomic, assign) BOOL useCloudSync;

@end

@implementation CRDViewController

- (void)alertWithMessage:(NSString *)message andError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:(error ? [message stringByAppendingFormat:@" - %@", error] : message)
                                                   delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)loadTapped:(id)sender
{
    NSError *error = nil;
    BMCredentials *credentials = [_credentialsManager defaultCredentials:&error];
    if (!credentials)
    {
        if (error.code == errSecItemNotFound)
        {
            [self alertWithMessage:@"No default credentials in the keychain yet" andError:nil];
        }
        else
        {
            [self alertWithMessage:@"Unable to load credentials" andError:error];
        }
    }
    else
    {
        _usernameField.text = credentials.username;
        _passwordField.text = credentials.password;
        _urlField.text = credentials.url.absoluteString;
        [self alertWithMessage:@"Loaded OK" andError:nil];
    }
}

- (IBAction)saveTapped:(id)sender
{
    if (!_usernameField.text.length || !_passwordField.text.length || !_urlField.text.length)
    {
        [self alertWithMessage:@"All fields are required" andError:nil];
        return;
    }
    
    NSError *error = nil;
    BMCredentials *credentials = [[BMCredentials alloc] init];
    credentials.username = _usernameField.text;
    credentials.password = _passwordField.text;
    credentials.url      = [NSURL URLWithString:_urlField.text];
    credentials.enableCloudSync = _useCloudSync;
    
    if (!credentials.url)
    {
        [self alertWithMessage:@"That's not a valid URL" andError:nil];
        return;
    }
    
    if (![_credentialsManager setDefaultCredentials:credentials error:&error])
    {
        [self alertWithMessage:@"Something went wrong saving your credentials" andError:error];
    }
    else
    {
        [self alertWithMessage:@"Saved OK" andError:nil];
    }
}

- (IBAction)removeTapped:(id)sender
{
    NSError *error = nil;
    if (![_credentialsManager removeDefaultCredentials:&error])
    {
        [self alertWithMessage:@"Something went wrong removing your credentials" andError:error];
    }
    else
    {
        [self alertWithMessage:@"All clear" andError:nil];
    }
}

- (IBAction)cloudChanged:(UISwitch *)sender
{
    self.useCloudSync = sender.isOn;
    [self saveTapped:nil];
}

- (IBAction)viewTapped:(id)sender
{
    [_usernameField becomeFirstResponder];
    [_usernameField resignFirstResponder];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _usernameField)
    {
        [_passwordField becomeFirstResponder];
    }
    else if (textField == _passwordField)
    {
        [_urlField becomeFirstResponder];
    }
    else
    {
        [_urlField resignFirstResponder];
    }
    return YES;
}

@end
