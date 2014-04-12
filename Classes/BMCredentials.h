//
//  BMCredentials.h
//
//  Created by Adam Iredale on 11/04/2014.
//  Copyright (c) 2014 Bionic Monocle Pty Ltd. All rights reserved.
//

#import <Security/Security.h>

/**
 *  Error domain for any errors. Note that error codes are simply Security framework errors
 *  that have been passed through.
 */
extern NSString *const BMCredentialsErrorDomain;

/**
 *  BMCredentials is a simple username, password and url (i.e. credentials) wrapper around the
 *  iOS keychain. Credentials are stored and retrieved using the kSecAttrLabel attribute. Internally,
 *  it uses password items of class kSecClassInternetPassword, one of two kinds of keychain items that
 *  currently support iCloud Keychain sync.
 */

@interface BMCredentials : NSObject

/**
 *  @name Properties
 */

/**
 *  Username or account name
 */
@property (nonatomic, copy) NSString *username;
/**
 *  Password or token
 */
@property (nonatomic, copy) NSString *password;
/**
 *  Online service URL
 */
@property (nonatomic, copy) NSURL *url;
/**
 *  YES to enable cloud sync via iCloud Keychain (default NO)
 */
@property (nonatomic, assign) BOOL enableCloudSync;
/**
 *  YES to enable background access to the credentials (defaults to NO, which is foreground only - more secure)
 */
@property (nonatomic, assign) BOOL enableBackgroundAccess;

/**
 *  @name Class Methods
 */

/**
 *  @name Keyed Credentials
 */

/**
 *  Returns the credentials for the given key or nil if they don't exist. 
 *
 *  If the method returns nil, the `error`
 *  parameter will be populated.
 *
 *  @param key   A unique key for the desired credentials set
 *  @param error A pointer to an error in cases of non-success
 *
 *  @return An instance of `BMCredentials` or nil
 */
+ (instancetype)credentialsForKey:(NSString *)key error:(NSError * __autoreleasing *)error;
/**
 *  Stores the values from the given credentials object into the keychain with the given key.
 *
 *  @param credentials A pre-populated `BMCredentials` object
 *  @param key         A unique key for the desired credentials set
 *  @param error       A pointer to an error in cases of non-success
 *
 *  @return YES on success, NO on error (will return error)
 */
+ (BOOL)setCredentials:(BMCredentials *)credentials forKey:(NSString *)key error:(NSError * __autoreleasing *)error;
/**
 *  Removes credentials for the given key from the keychain.
 *
 *  If no such credentials exist, this is still considered successful.
 *
 *  @param key   A unique key for the desired credentials set
 *  @param error A pointer to an error in cases of non-success
 *
 *  @return YES on removal of credentials matching the key or on non-existence of such credentials, NO on error (will return error)
 */
+ (BOOL)removeCredentialsForKey:(NSString *)key error:(NSError * __autoreleasing *)error;
/**
 *  Returns the default credentials or nil if they don't exist.
 *
 *  If the method returns nil, the `error`
 *  parameter will be populated.
 *
 *  @param error A pointer to an error in cases of non-success
 *
 *  @return An instance of `BMCredentials` or nil
 */

/**
 *  @name Default Credentials
 */

+ (instancetype)defaultCredentials:(NSError * __autoreleasing *)error;
/**
 *  Stores the values from the given credentials object into the keychain as the default credentials.
 *
 *  @param credentials A pre-populated `BMCredentials` object
 *  @param error       A pointer to an error in cases of non-success
 *
 *  @return YES on success, NO on error (will return error)
 */
+ (BOOL)setDefaultCredentials:(BMCredentials *)credentials error:(NSError * __autoreleasing *)error;
/**
 *  Removes the default credentials from the keychain.
 *
 *  If no such credentials exist, this is still considered successful.
 *
 *  @param error A pointer to an error in cases of non-success
 *
 *  @return YES on removal of credentials matching the key or on non-existence of such credentials, NO on error (will return error)
 */
+ (BOOL)removeDefaultCredentials:(NSError * __autoreleasing *)error;

/**
 *  @name Remove All
 */

/**
 *  Removes all items related to BMCredentials from the keychain
 *
 *  @param error A pointer to an error in cases of non-success
 *
 *  @return YES on removal of all credentials or on non-existence of such credentials, NO on error (will return error)
 */
+ (BOOL)removeAllCredentials:(NSError * __autoreleasing *)error;

@end
