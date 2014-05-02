//
//  CRDViewController.h
//  CredentialsDemo
//
//  Created by Adam Iredale on 11/04/2014.
//  Copyright (c) 2014 Bionic Monocle Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMCredentialsManager;

@interface CRDViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) BMCredentialsManager *credentialsManager;

@end
