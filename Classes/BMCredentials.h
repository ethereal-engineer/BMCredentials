//
//  BMCredentials.h
//
//  Created by Adam Iredale on 11/04/2014.
//  Copyright (c) 2014 Bionic Monocle Pty Ltd. All rights reserved.
//

#import <Security/Security.h>

/**
 *  Error domain for any errors. Note that any errors are simply Security framework errors
 *  that have been passed through.
 */
extern NSString *const BMCredentialsErrorDomain;

/**
 *  BMCredentials is a simple username, password and url (i.e. credentials) wrapper around the
 *  iOS keychain. Credentials are stored and retrieved using the kSecAttrLabel attribute. Internally,
 *  it uses password items of class kSecClassInternetPassword.
 */

@interface BMCredentials : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, assign) BOOL enableCloudSync;
@property (nonatomic, assign) BOOL enableBackgroundAccess;

+ (instancetype)credentialsForKey:(NSString *)key error:(NSError * __autoreleasing *)error;

+ (BOOL)setCredentials:(BMCredentials *)credentials forKey:(NSString *)key error:(NSError * __autoreleasing *)error;

+ (BOOL)removeCredentialsForKey:(NSString *)key error:(NSError * __autoreleasing *)error;

+ (instancetype)defaultCredentials:(NSError * __autoreleasing *)error;

+ (BOOL)setDefaultCredentials:(BMCredentials *)credentials error:(NSError * __autoreleasing *)error;

+ (BOOL)removeDefaultCredentials:(NSError * __autoreleasing *)error;

+ (BOOL)removeAllCredentials:(NSError * __autoreleasing *)error;

@end
