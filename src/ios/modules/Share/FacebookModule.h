//
//  FacebookModule.h
//  CL
//
//  Created by Carlo Luis M. Bation on secret.
//  Copyright (c) 2013 ISBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>

extern NSString* kFacebookModuleParamsTextKey;
extern NSString* kFacebookModuleParamsURLKey;
extern NSString* kFacebookModuleParamsImageKey;
extern NSString* kFacebookModuleParamsFeedKey;
extern NSString* kFacebookModuleParamsNameKey;

@protocol FacebookModuleDelegate;
@interface FacebookModule : NSObject{
    UIViewController *recentController;
}

@property (strong, nonatomic) NSString*  userid;
@property (strong, nonatomic) NSString*  loginCallbackId;
@property (strong, nonatomic) NSString*  dialogCallbackId;
@property (strong, nonatomic) NSString*  successMessage;
@property (strong, nonatomic) NSString*  errorMessage;
@property (strong, nonatomic) NSString*  successMessageTitle;
@property (strong, nonatomic) NSString*  errorMessageTitle;
@property(nonatomic,assign)id<FacebookModuleDelegate>delegate;
/*!
 @method
 @abstract Presents the SLComposeViewController if is available.
 @discussion This method presents the SLComposeViewController for Facebook to the given controller with predetermined parameters.
 
 @param params
 The dictionary of the paramters. ("URL","text","image")
 */
- (void)postForComposeSheet:(NSDictionary*)params withController:(UIViewController *)parentController;

/*!
 @method
 @abstract Determines if handler can post in SLComposeViewController.
 @discussion Returns YES or NO to the handler.
 */
- (BOOL)canPostInFacebookComposeSheet;
/*!
 @method
 @abstract Shows Facebook dialog fo sharing.
 @param
 paramsGlobal
 Please refer to https://developers.facebook.com/docs/reference/dialogs/feed/
 */
- (void) showDialog:(NSDictionary *)paramsGlobal;
/*!
 @method
 @abstract Get login status of user in Facebook.
 @param
 paramsGlobal
 Please refer to FBSessionState
 */
- (NSDictionary *) getLoginStatus;
/*!
 @method
 @abstract Login the current user to facebook.
 */
- (void) login;
/*!
 @method
 @abstract Returns the Share FacebookManager object.
 */
+ (FacebookModule *) shared;
@end
/*!
 @protocol FacebookModuleDelegate
 @abstract A protocol that handles delegate methods for FacebookManager class.
 */
@protocol FacebookModuleDelegate <NSObject>
@optional
/*!
 @method
 @abstract Triggered when a FBSessionState is changed.
 @param sessionState
 Please refer to FBSessionState
 @param manager
 The owner of the event
 */
- (void)facebookModule:(FacebookModule *)manager sessionStateChanged:(FBSessionState )sessionState;
@end
