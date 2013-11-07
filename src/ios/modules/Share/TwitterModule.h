//
//  TwitterModule.h
//  CL
//
//  Created by Carlo Luis M. Bation on secret.
//  Copyright (c) 2013 ISBX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

extern NSString* kTwitterModuleParamsDefaultTweetKey;
extern NSString* kTwitterModuleURLKey;
extern NSString* kTwitterModuleImageKey;
/*!
 @class TwitterModule
 @abstract A class that manages sharing in Twitter.
 @discussion This class provides methods that lets the owner to pass parameters needed to be able to share in Twitter. Parameters like image, url and default text. This class maximize the Twitter integration for iOS 6 and above that uses the Social.Framework provided by apple. If the device is iOS 5.1 below this class will use the previous implementation of sharing in Twitter that is using the Twitter.Framework.
 */

@interface TwitterModule : NSObject
{
    UIViewController *recentController;
}
@property (strong, nonatomic) NSString*  successMessage;
@property (strong, nonatomic) NSString*  errorMessage;
@property (strong, nonatomic) NSString*  successMessageTitle;
@property (strong, nonatomic) NSString*  errorMessageTitle;
/*!
 @method
 @abstract Display Twitter compose sheet to the given controller.
 @param arguments
 This dictionary may contain the following keys: "kTwitterModuleParamsDefaultTweetKey", "kTwitterModuleURLKey" and "kTwitterModuleImageKey"
 @param controller
 The UIViewController where will the Twitter compose sheet be displayed.
 */
- (void) composeTweet:(NSDictionary*)arguments withController:(UIViewController *)controller;

@end
