//
//  BMCredentials.m
//
//  Created by Adam Iredale on 11/04/2014.
//  Copyright (c) 2014 Bionic Monocle Pty Ltd. All rights reserved.
//

#import "BMCredentials.h"

/**
 *  Error domain
 */
NSString *const BMCredentialsErrorDomain = @"BMCredentialsErrorDomain";
/**
 *  Label used to store and retrieve default credentials
 */
static NSString *const kDefaultCredentialsKey = @"com.bionicmonocle.credentials.default";
/**
 *  Comment used to keep track of all BMCredentials items in the keychain
 */
static NSString *const kBMCredentialsTag = @"com.bionicmonocle.credentials.item";

/**
 *  WWDC 2013's Session 709 was relied on heavily for creating this, as well as the dev forums
 */

@implementation BMCredentials

#pragma mark - NSObject

/**
 *  Basic equality testing
 */

- (BOOL)isEqual:(id)object
{
    if (object == self)
    {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    
    BMCredentials *obj = object;
    
    return
    [_username isEqual:obj.username] &&
    [_password isEqual:obj.password] &&
    [_url isEqual:obj.url];
}

#pragma mark - Public

/**
 *  Write the credentials to the iOS Keychain. If a duplicate item already exists, update it using the
 *  correct forward-compatible methods
 *
 *  @param key   A unique key for storing this credentials set
 *  @param error Pointer to an error variable. All errors return error codes found in Security.framework
 *
 *  @return YES if successful. NO if not - an error will be present if NO
 */

- (BOOL)storeWithKey:(NSString *)key error:(NSError * __autoreleasing *)error
{
    NSParameterAssert(_username);
    NSParameterAssert(_password);
    NSParameterAssert(_url);
    NSParameterAssert(key);
    
    // Break down the URL
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:_url resolvingAgainstBaseURL:NO];
    
    // Default to HTTP
    CFTypeRef protocol = kSecAttrProtocolHTTP;
    
    if ([urlComponents.scheme isEqualToString:@"https"])
    {
        protocol = kSecAttrProtocolHTTPS;
    }
    else if (urlComponents.scheme && ![urlComponents.scheme isEqualToString:@"http"])
    {
        NSAssert(NO, @"Only http and https are supported at the moment. Sorry.");
    }
    
    NSData *secret = [_password dataUsingEncoding:NSUTF8StringEncoding];
   
    // If we have one already, grab it so we can update it
    
    NSDictionary *query =
    @{
      (__bridge id)kSecClass                : (__bridge id)kSecClassInternetPassword,
      (__bridge id)kSecAttrComment          : kBMCredentialsTag,
      (__bridge id)kSecAttrLabel            : key,
      (__bridge id)kSecReturnData           : @NO,
      (__bridge id)kSecAttrSynchronizable   : (__bridge id)kSecAttrSynchronizableAny
      };
    
    NSDictionary *prepayload =
    @{
      (__bridge id)kSecAttrAccessible       : (__bridge id)(_enableBackgroundAccess ?
                                                            kSecAttrAccessibleAfterFirstUnlock :
                                                            kSecAttrAccessibleWhenUnlocked),
      (__bridge id)kSecAttrComment          : kBMCredentialsTag,
      (__bridge id)kSecAttrAccount          : _username,
      (__bridge id)kSecValueData            : secret,
      (__bridge id)kSecAttrSynchronizable   : (_enableCloudSync ? @YES : @NO)
      };
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:prepayload];
    
    if (protocol)
    {
        payload[(__bridge id)kSecAttrProtocol] = (__bridge id)protocol;
    }
    
    if (urlComponents.port)
    {
        payload[(__bridge id)kSecAttrPort] = urlComponents.port;
    }
    
    if (urlComponents.path)
    {
        payload[(__bridge id)kSecAttrPath] = urlComponents.path;
    }
    
    if (urlComponents.host)
    {
        payload[(__bridge id)kSecAttrServer] = urlComponents.host;
    }
    
    OSStatus findStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    
    if (findStatus == errSecItemNotFound)
    {
        // None found. Add a new one
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes addEntriesFromDictionary:query];
        [attributes addEntriesFromDictionary:payload];
        
        [attributes removeObjectForKey:(__bridge id)kSecReturnData];
        
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
        
        if (status != errSecSuccess)
        {
            if (error)
            {
                *error = [NSError errorWithDomain:BMCredentialsErrorDomain code:status userInfo:nil];
            }
            return NO;
        }
        
    }
    else if (findStatus == errSecSuccess)
    {
        // Existing one found. Update it
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)payload);
        
        if (status != errSecSuccess)
        {
            // We have a problem
            if (error)
            {
                *error = [NSError errorWithDomain:BMCredentialsErrorDomain code:status userInfo:nil];
            }
            return NO;
        }
    }
    else
    {
        // Errrk! Error.
        if (error)
        {
            *error = [NSError errorWithDomain:BMCredentialsErrorDomain code:findStatus userInfo:nil];
        }
        return NO;
    }
    return YES;
}

/**
 *  Retrieve and load the credentials from the iOS Keychain into the BMCredentials object
 *
 *  @param key   A unique key for retrieving this credentials set
 *  @param error Pointer to an error variable. All errors return error codes found in Security.framework
 *
 *  @return YES if successful, NO if not - an error will be present if NO
 */

- (BOOL)loadWithKey:(NSString *)key error:(NSError * __autoreleasing *)error
{
    NSDictionary *query =
    @{
      (__bridge id)kSecClass                : (__bridge id)kSecClassInternetPassword,
      (__bridge id)kSecAttrComment          : kBMCredentialsTag,
      (__bridge id)kSecAttrLabel            : key,
      (__bridge id)kSecReturnData           : @YES,
      (__bridge id)kSecReturnAttributes     : @YES,
      (__bridge id)kSecAttrSynchronizable   : (__bridge id)kSecAttrSynchronizableAny
      };
    
    CFTypeRef outTypeRef;
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &outTypeRef);
    
    if (status == errSecSuccess)
    {
        // Load up!
        
        NSDictionary *itemInfo = (__bridge NSDictionary *)(outTypeRef);
        
        self.url =
        ({
            NSNumber *port = itemInfo[(__bridge id)kSecAttrPort];
            if (port.unsignedIntegerValue == 0)
            {
                port = nil;
            }
            
            NSString *scheme;
            if ([itemInfo[(__bridge id)kSecAttrProtocol] isEqual:(__bridge id)kSecAttrProtocolHTTP])
            {
                scheme = @"http";
            }
            else if ([itemInfo[(__bridge id)kSecAttrProtocol] isEqual:(__bridge id)kSecAttrProtocolHTTPS])
            {
                scheme = @"https";
            }
            
            NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
            
            urlComponents.scheme    = scheme;
            urlComponents.host      = itemInfo[(__bridge id)kSecAttrServer];
            urlComponents.port      = port;
            urlComponents.path      = itemInfo[(__bridge id)kSecAttrPath];
            urlComponents.URL;
        });
        
        self.username = itemInfo[(__bridge id)kSecAttrAccount];
        self.password = [[NSString alloc] initWithData:itemInfo[(__bridge id)kSecValueData]
                                              encoding:NSUTF8StringEncoding];
      
        if (outTypeRef != NULL)
        {
          CFRelease(outTypeRef);
        }
      
        return YES;
    }
    else
    {
        // Either not found or error
        if (error)
        {
            *error = [NSError errorWithDomain:BMCredentialsErrorDomain code:status userInfo:nil];
        }
      
        if (outTypeRef != NULL)
        {
          CFRelease(outTypeRef);
        }
      
        return NO;
    }
}

#pragma mark - Class Methods

+ (instancetype)credentialsForKey:(NSString *)key error:(NSError * __autoreleasing *)error
{
    return [[BMCredentialsManager sharedInstance] credentialsForKey:key error:error];
}

+ (BOOL)setCredentials:(BMCredentials *)credentials forKey:(NSString *)key error:(NSError * __autoreleasing *)error
{
    return [[BMCredentialsManager sharedInstance] setCredentials:credentials forKey:key error:error];
}

+ (instancetype)defaultCredentials:(NSError * __autoreleasing *)error
{
    return [[BMCredentialsManager sharedInstance] defaultCredentials:error];
}

+ (BOOL)setDefaultCredentials:(BMCredentials *)credentials error:(NSError * __autoreleasing *)error
{
    return [[BMCredentialsManager sharedInstance] setDefaultCredentials:credentials error:error];
}

+ (BOOL)removeCredentialsForKey:(NSString *)key error:(NSError * __autoreleasing *)error
{
    return [[BMCredentialsManager sharedInstance] removeCredentialsForKey:key error:error];
}

+ (BOOL)removeAllCredentials:(NSError * __autoreleasing *)error
{
    return [[BMCredentialsManager sharedInstance] removeAllCredentials:error];
}

+ (BOOL)removeDefaultCredentials:(NSError * __autoreleasing *)error
{
    return [[BMCredentialsManager sharedInstance] removeCredentialsForKey:kDefaultCredentialsKey error:error];
}

@end

/**
 *  @name BMCredentialsManager
 */

/**
 *  Shared Instance Variable
 */
static const BMCredentialsManager *_gBMCredentialsManager = nil;

@implementation BMCredentialsManager

#pragma mark - Helpers

#pragma mark - Public Methods

- (BMCredentials *)credentialsForKey:(NSString *)key error:(NSError * __autoreleasing *)error
{
    BMCredentials *credentials = [[BMCredentials alloc] init];
    if ([credentials loadWithKey:key error:error])
    {
        return credentials;
    }
    else
    {
        return nil;
    }
}

- (BOOL)setCredentials:(BMCredentials *)credentials forKey:(NSString *)key error:(NSError * __autoreleasing *)error
{
    return [credentials storeWithKey:key error:error];
}

- (BMCredentials *)defaultCredentials:(NSError * __autoreleasing *)error
{
    return [self credentialsForKey:kDefaultCredentialsKey error:error];
}

- (BOOL)setDefaultCredentials:(BMCredentials *)credentials error:(NSError * __autoreleasing *)error
{
    return [credentials storeWithKey:kDefaultCredentialsKey error:error];
}

- (BOOL)removeCredentialsForKey:(NSString *)key error:(NSError * __autoreleasing *)error
{
    NSDictionary *query =
    @{
      (__bridge id)kSecClass                : (__bridge id)kSecClassInternetPassword,
      (__bridge id)kSecAttrComment          : kBMCredentialsTag,
      (__bridge id)kSecAttrLabel            : key,
      (__bridge id)kSecReturnData           : @NO,
      (__bridge id)kSecAttrSynchronizable   : (__bridge id)kSecAttrSynchronizableAny
      };
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status == errSecSuccess || status == errSecItemNotFound)
    {
        // Deleted or never existed anyway
        return YES;
    }
    else
    {
        // A real error
        if (error)
        {
            *error = [NSError errorWithDomain:BMCredentialsErrorDomain code:status userInfo:nil];
        }
        return NO;
    }
}

- (BOOL)removeAllCredentials:(NSError * __autoreleasing *)error
{
    
    // Remove all matching keychain items that have the BMCredentials tag
    
    NSDictionary *query =
    @{
      (__bridge id)kSecClass                : (__bridge id)kSecClassInternetPassword,
      (__bridge id)kSecAttrComment          : kBMCredentialsTag,
      (__bridge id)kSecReturnData           : @NO,
      (__bridge id)kSecAttrSynchronizable   : (__bridge id)kSecAttrSynchronizableAny
      };
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status == errSecSuccess || status == errSecItemNotFound)
    {
        // Deleted or didn't exist
        return YES;
    }
    else
    {
        // A real error
        if (error)
        {
            *error = [NSError errorWithDomain:BMCredentialsErrorDomain code:status userInfo:nil];
        }
        return NO;
    }
}

- (BOOL)removeDefaultCredentials:(NSError * __autoreleasing *)error
{
    return [self removeCredentialsForKey:kDefaultCredentialsKey error:error];
}

#pragma mark - Class Methods

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _gBMCredentialsManager = [[BMCredentialsManager alloc] init];
    });
    return (BMCredentialsManager *)_gBMCredentialsManager;
}

@end
