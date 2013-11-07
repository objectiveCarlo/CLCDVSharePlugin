//
//  CLShareCDVPLugin.m
//  CL
//
//  Created by Carlo Luis M. Bation on 11/7/13.
//
//

#include <sys/types.h>
#include <sys/sysctl.h>

#import "CLShareCDVPLugin.h"
#import <Cordova/CDV.h>
#import "AppDelegate.h"
NSString* kCLShareCDVPLuginLinkKey    = @"link";
NSString* kCLShareCDVPLuginImageKey   = @"image";
NSString* kCLShareCDVPLuginMessageKey = @"message";
NSString* kCLShareCDVPLuginTweetKey   = @"tweet";
@implementation CLShareCDVPLugin

/*
 p.SupportedSocialMedia = {
 FACEBOOK  : "shareViaFb",
 TWITTTER  : "shareViaTwitter",
 INSTAGRAM : "shareViaInstagram"
 }
 
 p.SupportedKeys = {
 LINK    : "link",
 IMAGE   : "image",
 MESSAGE : "message",
 TWEET   : "tweet",
 }
 
 */

- (BOOL)isParamValid:(NSString *)param
{
    return (param != nil && ![param isKindOfClass:[NSNull class]]);
}
- (BOOL)validateAndGetParams:(NSMutableDictionary *)params
                 withCommand:(CDVInvokedUrlCommand *)command
               withParamsKey:(NSArray *)paramsKey
           withConcernedKeys:(NSArray *)concernedKeys
{
    BOOL isValid = YES;
    
    NSDictionary* paramsJS = [command argumentAtIndex:0];
    
    if(paramsJS != nil && [paramsJS isKindOfClass:[NSDictionary class]])
    {
        for(int i = 0; i < concernedKeys.count; i++)
        {
            NSString* param = [paramsJS objectForKey: [concernedKeys objectAtIndex:i]];
            
            isValid = [self isParamValid:param];
            
            if(isValid)
            {
                [params setObject:param forKey:[paramsKey objectAtIndex:i]];
            }
            else
            {   isValid = false;
                break;
            }
        }
      
    }
    else
    {
        isValid = NO;
    }
    
    return isValid;
}
- (UIViewController *)controller
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.viewController;
}
- (void)shareViaFb:(CDVInvokedUrlCommand *)command
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    BOOL valid = [self validateAndGetParams:params
                                withCommand:command
                              withParamsKey:[NSArray arrayWithObjects:kFacebookModuleParamsURLKey,kFacebookModuleParamsTextKey,kFacebookModuleParamsImageKey, nil]
                          withConcernedKeys:[NSArray arrayWithObjects:kCLShareCDVPLuginLinkKey,kCLShareCDVPLuginMessageKey,kCLShareCDVPLuginImageKey, nil]];
    
    
    
    if(valid)
    {
        FacebookModule *facebookModule = [FacebookModule shared];
        [facebookModule setDelegate:self];
    
        if([facebookModule canPostInFacebookComposeSheet])
        {
            [facebookModule postForComposeSheet:params withController:[self controller]];
        }else
        {
            NSDictionary *loginStatus = [facebookModule getLoginStatus];
            
            if([loginStatus isKindOfClass:[NSDictionary class]])
            {
                NSString *status = [loginStatus objectForKey:@"status"];
                
                if([status isEqualToString:@"connected"])
                {
                    [facebookModule showDialog:params];
                }else
                {   self.currentPrams = params;
                    [facebookModule login];
                }
            }
        }
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus: valid ? CDVCommandStatus_OK: CDVCommandStatus_ERROR];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)shareViaTwitter:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    BOOL valid = [self validateAndGetParams:params
                                withCommand:command
                              withParamsKey:[NSArray arrayWithObjects:kTwitterModuleURLKey,kTwitterModuleParamsDefaultTweetKey,kTwitterModuleImageKey, nil]
                          withConcernedKeys:[NSArray arrayWithObjects:kCLShareCDVPLuginLinkKey,kCLShareCDVPLuginTweetKey,kCLShareCDVPLuginImageKey, nil]];
    
    
    if(valid)
    {
        TwitterModule *twitter = [[TwitterModule alloc] init];
        [twitter composeTweet:params withController:[self controller]];
    
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus: valid ? CDVCommandStatus_OK: CDVCommandStatus_ERROR];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shareViaInstagram:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    BOOL valid = [self validateAndGetParams:params
                                withCommand:command
                              withParamsKey:[NSArray arrayWithObjects:kFacebookModuleParamsURLKey,kFacebookModuleParamsTextKey,kFacebookModuleParamsImageKey, nil]
                          withConcernedKeys:[NSArray arrayWithObjects:kCLShareCDVPLuginLinkKey,kCLShareCDVPLuginMessageKey,kCLShareCDVPLuginImageKey, nil]];
    
    if(valid)
    {
        InstagramModule *instagram = [[InstagramModule alloc] init];
        [instagram setDelegate:self];
        [instagram shareInstagramWithController:[self controller] withImageName:[params objectForKey:kFacebookModuleParamsImageKey]];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus: valid ? CDVCommandStatus_OK: CDVCommandStatus_ERROR];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)facebookModule:(FacebookModule *)manager sessionStateChanged:(FBSessionState)sessionState
{
     if(sessionState == FBSessionStateOpen)
     {     FacebookModule *facebookModule = [FacebookModule shared];
         [facebookModule showDialog:self.currentPrams];
     }
    
    
}

- (void)instagramModule:(InstagramModule *)module didEndSendingToInstagramApp:(BOOL)success
{
    
}
@end
