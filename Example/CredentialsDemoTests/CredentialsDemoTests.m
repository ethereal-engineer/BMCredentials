//
//  CredentialsDemoTests.m
//  CredentialsDemoTests
//
//  Created by Adam Iredale on 11/04/2014.
//  Copyright (c) 2014 Bionic Monocle Pty Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Specta/Specta.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <BMCredentials/BMCredentials.h>

static NSString *const kTestCredentialsKey = @"com.bionicmonocle.testcredentialskey";

SpecBegin(BMCredentials)

describe(@"BMCredentials", ^
{
    beforeEach(^{
        
    });
    
    afterEach(^{
        [BMCredentials removeAllCredentials:nil];
    });
    
    it(@"should exist",^{
        BMCredentials *credentials = [[BMCredentials alloc] init];
        assertThat(credentials, isNot(nilValue()));
    });
    
    it(@"should be able to set credentials by key", ^{
        BMCredentials *credentials = [[BMCredentials alloc] init];
        credentials.username = @"admin";
        credentials.password = @"changeit";
        credentials.url      = [NSURL URLWithString:@"http://www.bionicmonocle.com"];
        [BMCredentials setCredentials:credentials forKey:kTestCredentialsKey error:nil];
    });
    
    it(@"should be able to remove credentials by key", ^{
        [BMCredentials removeCredentialsForKey:kTestCredentialsKey error:nil];
    });
    
    it(@"stores and retrieves matching credentials", ^{
        BMCredentials *credentials = [[BMCredentials alloc] init];
        credentials.username = @"admin";
        credentials.password = @"changeit";
        credentials.url      = [NSURL URLWithString:@"http://www.bionicmonocle.com"];
        [BMCredentials setCredentials:credentials forKey:kTestCredentialsKey error:nil];
        BMCredentials *loaded = [BMCredentials credentialsForKey:kTestCredentialsKey error:nil];
        assertThat(loaded, equalTo(credentials));
    });
    
    it(@"can update credentials without issue", ^{
        BMCredentials *credentials = [[BMCredentials alloc] init];
        credentials.username = @"admin";
        credentials.password = @"changeit";
        credentials.url      = [NSURL URLWithString:@"http://www.bionicmonocle.com"];
        [BMCredentials setCredentials:credentials forKey:kTestCredentialsKey error:nil];
        BMCredentials *loaded = [BMCredentials credentialsForKey:kTestCredentialsKey error:nil];
        loaded.username = @"admin2";
        [BMCredentials setCredentials:loaded forKey:kTestCredentialsKey error:nil];
        credentials = [BMCredentials credentialsForKey:kTestCredentialsKey error:nil];
        assertThat(loaded, equalTo(credentials));
    });
    
    it(@"removes single credentials", ^{
        BMCredentials *credentials = [[BMCredentials alloc] init];
        credentials.username = @"admin";
        credentials.password = @"changeit";
        credentials.url      = [NSURL URLWithString:@"http://www.bionicmonocle.com"];
        [BMCredentials setCredentials:credentials forKey:kTestCredentialsKey error:nil];
        [BMCredentials removeCredentialsForKey:kTestCredentialsKey error:nil];
        BMCredentials *loaded = [BMCredentials credentialsForKey:kTestCredentialsKey error:nil];
        assertThat(loaded, is(nilValue()));
    });
    
    it(@"removes all credentials", ^{
        BMCredentials *credentials = [[BMCredentials alloc] init];
        credentials.username = @"admin";
        credentials.password = @"changeit";
        credentials.url      = [NSURL URLWithString:@"http://www.bionicmonocle.com"];
        NSArray *credKeys = @[@"cred1", @"cred2", @"cred3"];
        for (NSString *key in credKeys)
        {
            [BMCredentials setCredentials:credentials forKey:key error:nil];
        }
        [BMCredentials removeAllCredentials:nil];
        for (NSString *key in credKeys)
        {
            BMCredentials *loaded = [BMCredentials credentialsForKey:key error:nil];
            assertThat(loaded, is(nilValue()));
        }
    });
});

SpecEnd