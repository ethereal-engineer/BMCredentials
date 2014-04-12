# BMCredentials

[![Version](http://cocoapod-badges.herokuapp.com/v/BMCredentials/badge.png)](http://cocoadocs.org/docsets/BMCredentials)
[![Platform](http://cocoapod-badges.herokuapp.com/p/BMCredentials/badge.png)](http://cocoadocs.org/docsets/BMCredentials)

## About

BMCredentials is a lightweight, secure, user credentials storage method built directly on top of the iOS Keychain. It has flexibility to allow multiple credentials storage and retrieval and simplicity for single credentials use-cases.

With iCloud Keychain support built in, you can have your users sign in to your app just once for all of their devices. 

BMCredentials makes protecting user secrets quick and painless for you and delightful for your users.

## Installation

BMCredentials is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "BMCredentials"

## Usage

### The Credentials Object

The `BMCredentials` object is very basic. Here is the property rundown:

#### Required Properties

- `username`	- The user's username or email address or whatever you use to sign the user in uniquely
- `password` 	- The user's (hopefully strong) password
- `url`			- The URL of the webservice, server or other online entity that these credentials will be used with (*at this stage, only **http** and **https** url schemes are supported, but pull requests are welcome!*)

#### Optional Properties

- `enableCloudSync`			- Automatically synchronise credentials between all devices for this user via iCloud Keychain. For more details on requirements, see [Requirements for use with iCloud Keychain](#RequirementsiCloudKeychain) *(defaults to NO)*
- `enableBackgroundAccess`	- Allow these credentials to be accessed when the app is in the background, provided the device has been unlocked at least once *(defaults to foreground access only, as it's more secure)*

### Requirements for use with iCloud Keychain <a name="RequirementsiCloudKeychain"></a>

In order for `BMCredentials` objects to synchronise automatically across all user devices, there are some pre-requisites:

#### Developers

- Must turn on the Keychain Sharing [entitlement](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html) for their app

#### Users

- Must be signed in to iCloud on their devices
- Must have iCloud Keychain turned on

*Note that BMCredentials will still work if the users are not signed in to iCloud or do not have iCloud Keychain turned on, but cloud sync will be disabled.*

### Default credentials

Default credentials are for most apps out there. Most apps only require a single user account to be retained. If your app requires more than a single user account, see [Keyed credentials](#KeyedCredentials) below.

#### Getting

	NSError *error = nil;
	
	BMCredentials *credentials = [BMCredentials defaultCredentials:&error];
	if (!credentials)
	{
		// All the error codes are passed through directly from the SecItem API
		if (error.code == errSecItemNotFound)
		{
			// None found, but that's probably ok if its the first time
		}
		else
		{
			// This, however, is probably not a good thing
		}
	}

#### Setting

	BMCredentials *credentials = [[BMCredentials alloc] init];
	
	credentials.username 	= @"john.appleseed";
	credentials.password 	= @"heartbleedsucksineedastrongerpassword";
	credentials.url			= [NSURL URLWithString:@"https://somewebservice.com"];
	
	NSError *error = nil;
	if (![BMCredentials setDefaultCredentials:credentials error:&error])
	{
		// If an error occurs, refer to the Security.framework headers for
		// identification (they all begin with errSec). Whilst errors are unlikely,
		// good software handles all errors gracefully
	}

#### Clearing

	NSError *error = nil;
	
	if (![BMCredentials removeDefaultCredentials:&error])
	{
		// If an error occurs, refer to the Security.framework headers for
		// identification (they all begin with errSec). Whilst errors are unlikely,
		// good software handles all errors gracefully
	}

### Keyed credentials <a name="KeyedCredentials"></a>

Default credentials are just keyed credentials using a default key, for ease of broad-case use. Keyed credentials add one more parameter and as many sets of credentials as you need.

#### Getting

	NSError *error = nil;
	NSString *credsKey = @"github";
	
	BMCredentials *credentials = [BMCredentials credentialsForKey:credsKey error:&error];
	if (!credentials)
	{
		// All the error codes are passed through directly from the SecItem API
		if (error.code == errSecItemNotFound)
		{
			// None found, but that's probably ok if its the first time
		}
		else
		{
			// This, however, is probably not a good thing
		}
	}

#### Setting

	BMCredentials *credentials = [[BMCredentials alloc] init];
	
	credentials.username 		= @"john.appleseed";
	credentials.password 		= @"heartbleedsucksineedastrongerpassword";
	credentials.url				= [NSURL URLWithString:@"https://github.com"];
	credentials.enableCloudSync = YES;
	
	NSError *error = nil;
	NSString *credsKey = @"github";
	
	if (![BMCredentials setCredentials:credentials forKey:credsKey error:&error])
	{
		// If an error occurs, refer to the Security.framework headers for
		// identification (they all begin with errSec). Whilst errors are unlikely,
		// good software handles all errors gracefully
	}
	
#### Clearing

	NSError *error = nil;
	NSString *credsKey = @"github";
	
	if (![BMCredentials removeCredentialsForKey:credsKey error:&error])
	{
		// If an error occurs, refer to the Security.framework headers for
		// identification (they all begin with errSec). Whilst errors are unlikely,
		// good software handles all errors gracefully
	}

### Removing all credentials

Often when a user logs out of your app, you'll want to clear out all stored credentials in your system. BMCredentials tracks all of its storage in the iOS Keychain database by adding a tag to each item used. This makes removing all credentials from the Keychain very simple.

	NSError *error = nil;

	if (![BMCredentials removeAllCredentials:&error])
	{
		// If an error occurs, refer to the Security.framework headers for
		// identification (they all begin with errSec). Whilst errors are unlikely,
		// good software handles all errors gracefully
	}

## Example Project

To run the example project; clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Security.framework

## Author

Adam Iredale, [@iosengineer](https://twitter.com/iosengineer)

## License

BMCredentials is available under the MIT license. See the LICENSE file for more info.

