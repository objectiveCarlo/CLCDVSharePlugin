//
//  FacebookModule.m
//  CL
//
//  Created by Carlo Luis M. Bation on secret.
//  Copyright (c) 2013 ISBX. All rights reserved.
//

#import "FacebookModule.h"

NSString* kFacebookModuleParamsTextKey  = @"description";
NSString* kFacebookModuleParamsURLKey   = @"link";
NSString* kFacebookModuleParamsImageKey = @"picture";
NSString* kFacebookModuleParamsFeedKey  = @"feed";
NSString* kFacebookModuleParamsNameKey  = @"name";
@implementation FacebookModule
static FacebookModule *_kShared = nil;
@synthesize delegate;

+ (FacebookModule *) shared
{
    static dispatch_once_t sharedOnceToken;
    dispatch_once(&sharedOnceToken, ^{
        _kShared = [[FacebookModule alloc] init];
    });
    return _kShared;
}
-(id)init{
    self = [super init];
    if(self){
        if(![self canPostInFacebookComposeSheet])
        {
            
            [FBSession openActiveSessionWithReadPermissions:nil
                                               allowLoginUI:NO
                                          completionHandler:^(FBSession *session,
                                                              FBSessionState state,
                                                              NSError *error)
                                        {
                                              [self sessionStateChanged:session
                                                                  state:state
                                                                  error:error];
                                          }];
        }
    }
    return self;
}

- (BOOL)canPostInFacebookComposeSheet
{
    BOOL result = NO;
    if(NSClassFromString(@"SLComposeViewController")!=nil && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        result = YES;
    }
    return result;
    
}
- (void)postForComposeSheet:(NSDictionary*)params withController:(UIViewController *)parentController
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        
        SLComposeViewControllerCompletionHandler __block completionHandler=
        ^(SLComposeViewControllerResult result)
        {
            
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled...");
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSString *title = self.successMessageTitle;
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                                     message:self.successMessage
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles: nil];
                    [alert show];
                }
                    break;
            }
            
            if([[recentController presentedViewController] isKindOfClass:[SLComposeViewController class]])
            {
                [recentController dismissViewControllerAnimated:NO completion:nil];
            }
        };
        
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:params];
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        NSString *text = [options objectForKey:kFacebookModuleParamsTextKey];
        NSString *URL = [options objectForKey:kFacebookModuleParamsURLKey];
        
        NSObject *image = [options objectForKey:kFacebookModuleParamsImageKey];
        
        
        if(text != nil)
            [controller setInitialText:[options objectForKey:kFacebookModuleParamsTextKey]];
        
        if(image != nil)
        {
            
            if([image isKindOfClass:[NSString class]])
            {
                [controller addImage:[UIImage imageNamed:[options objectForKey:kFacebookModuleParamsImageKey]]];
            }else
            {
                [controller addImage:(UIImage *)image];
                
            }
        }
        
        if(URL != nil)
            [controller addURL:[NSURL URLWithString:[options objectForKey:kFacebookModuleParamsURLKey]]];
        
        [controller setCompletionHandler:(SLComposeViewControllerCompletionHandler)completionHandler];
        [parentController presentViewController:controller animated:YES completion:NO];
        recentController = parentController;
        
    }
}

- (NSDictionary *) getLoginStatus
{
    return [self responseObject];
    //    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
    //                                                  messageAsDictionary:[self responseObject]];
    //    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (BOOL)isPublishPermission:(NSString*)permission
{
    return [permission hasPrefix:@"publish"] ||
    [permission hasPrefix:@"manage"] ||
    [permission isEqualToString:@"ads_management"] ||
    [permission isEqualToString:@"create_event"] ||
    [permission isEqualToString:@"rsvp_event"];
}
- (BOOL)areAllPermissionsReadPermissions:(NSArray*)permissions
{
    for (NSString *permission in permissions)
    {
        if ([self isPublishPermission:permission])
        {
            return NO;
        }
    }
    return YES;
}
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state)
    {
        case FBSessionStateOpen:
        case FBSessionStateOpenTokenExtended:
            if (!error) {
                // We have a valid session
                
                if (state == FBSessionStateOpen)
                {
                    // Get the user's info
                    [FBRequestConnection startForMeWithCompletionHandler:
                     ^(FBRequestConnection *connection, id <FBGraphUser>user, NSError *error)
                    {
                         if (!error)
                         {
                             self.userid = user.id;
                             
                             if(delegate != nil && [delegate respondsToSelector:@selector(facebookModule:sessionStateChanged:)])
                             {
                                 [delegate facebookModule:self sessionStateChanged:state];
                             }
                         } else
                         {
                             self.userid = @"";
                             
                         }
                     }];
                }
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            self.userid = @"";
            break;
        default:
            break;
    }
    
    if (error)
    {
        NSString *alertMessage = nil;
        
        if (error.fberrorShouldNotifyUser)
        {
            // If the SDK has a message for the user, surface it.
            alertMessage = error.fberrorUserMessage;
        } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession)
        {
            // Handles session closures that can happen outside of the app.
            // Here, the error is inspected to see if it is due to the app
            // being uninstalled. If so, this is surfaced. Otherwise, a
            // generic session error message is displayed.
            NSInteger underlyingSubCode = [[error userInfo]
                                           [@"com.facebook.sdk:ParsedJSONResponseKey"]
                                           [@"body"]
                                           [@"error"]
                                           [@"error_subcode"] integerValue];
            if (underlyingSubCode == 458) {
                alertMessage = @"The app was removed. Please log in again.";
            } else {
                alertMessage = @"Your current session is no longer valid. Please log in again.";
            }
        } else if (error.fberrorCategory == FBErrorCategoryUserCancelled)
        {
          
            alertMessage = @"You cancelled.";
        } else
        {
            // For simplicity, this sample treats other errors blindly.
            alertMessage = @"Error. Please try again later.";
        }
        if (alertMessage)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        
    }
}


- (void) login
{
    NSArray *permissions = [NSArray arrayWithObjects: @"publish_stream", @"publish_actions", nil];
    //    if ([command.arguments count] > 0) {
    //        permissions = command.arguments;
    //    }
    //
    // save the callbackId for the login callback
    //    self.loginCallbackId = command.callbackId;
    
    // Check if the session is open or not
    if (FBSession.activeSession.isOpen)
    {
        // Reauthorize if the session is already open.
        // In this instance we can ask for publish type
        // or read type only if taking advantage of iOS6.
        // To mix both, we'll use deprecated methods
        BOOL publishPermissionFound = NO;
        BOOL readPermissionFound = NO;
        for (NSString *p in permissions)
        {
            if ([self isPublishPermission:p])
            {
                publishPermissionFound = YES;
            } else {
                readPermissionFound = YES;
            }
            
            // If we've found one of each we can stop looking.
            if (publishPermissionFound && readPermissionFound)
            {
                break;
            }
        }
        if (publishPermissionFound && readPermissionFound)
        {
            // Mix of permissions, use deprecated method
            [FBSession.activeSession
             reauthorizeWithPermissions:permissions
             behavior:FBSessionLoginBehaviorWithFallbackToWebView
             completionHandler:^(FBSession *session, NSError *error)
            {
                 [self sessionStateChanged:session
                                     state:session.state
                                     error:error];
             }];
        } else if (publishPermissionFound)
        {
            // Only publish permissions
            [FBSession.activeSession
             requestNewPublishPermissions:permissions
             defaultAudience:FBSessionDefaultAudienceFriends
             completionHandler:^(FBSession *session, NSError *error)
            {
                 [self sessionStateChanged:session
                                     state:session.state
                                     error:error];
             }];
        } else
        {
            // Only read permissions
            [FBSession.activeSession
             requestNewReadPermissions:permissions
             completionHandler:^(FBSession *session, NSError *error)
             {
                 [self sessionStateChanged:session
                                     state:session.state
                                     error:error];
             }];
        }
    } else
    {
        // Initial log in, can only ask to read
        // type permissions if one wants to use the
        // non-deprecated open session methods and
        // take advantage of iOS6 integration
        if ([self areAllPermissionsReadPermissions:permissions])
        {
            [FBSession
             openActiveSessionWithReadPermissions:permissions
             allowLoginUI:YES
             completionHandler:^(FBSession *session,
                                 FBSessionState state,
                                 NSError *error) {
                 [self sessionStateChanged:session
                                     state:state
                                     error:error];
             }];
        } else
        {
            // Use deprecated methods for backward compatibility
            [FBSession
             openActiveSessionWithPermissions:permissions
             allowLoginUI:YES completionHandler:^(FBSession *session,
                                                  FBSessionState state,
                                                  NSError *error)
            {
                 [self sessionStateChanged:session
                                     state:state
                                     error:error];
             }];
        }
        
        
        
    }
    
}

- (void) logout
{
    if (!FBSession.activeSession.isOpen)
    {
        return;
    }
    
    // Close the session and clear the cache
    [FBSession.activeSession closeAndClearTokenInformation];
    
}

- (void) showDialog:(NSDictionary *)paramsGlobal
{
  
    NSMutableDictionary *options = [paramsGlobal mutableCopy];
    NSLog(@"%@",options == nil?@"nil":options);
    NSString* method = [[NSString alloc] initWithString:[options objectForKey:@"method"]];
    if (options&&[options objectForKey:@"method"]) {
        [options removeObjectForKey:@"method"];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        if ([obj isKindOfClass:[NSString class]])
        {
            params[key] = obj;
        } else
        {
            
            NSObject *object = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:nil];
            NSString *imageName = (NSString *)object;
            if(![object isKindOfClass:[NSString class]])
            {
                imageName = [NSString stringWithFormat:@"%@",object];
            }
            if([key isEqualToString:kFacebookModuleParamsImageKey]&&![key hasPrefix:@"http:"])
            {
                
                UIImage *image = [UIImage imageNamed: imageName];
                if([key hasSuffix:@".png"])
                {
                    params[key] = UIImagePNGRepresentation(image);
                }else
                {
                    params[key] = UIImageJPEGRepresentation(image,1);
                }
            }else
            {
                params[key] = imageName;
            }
        }
    }];
    
    // Show the web dialog
    [FBWebDialogs
     presentDialogModallyWithSession:FBSession.activeSession
     dialog:method parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
    {
         if (error)
         {
             
         } else
         {
             if (result == FBWebDialogResultDialogNotCompleted)
             {
                 // User clicked the "x" icon to Cancel
                 
             } else
             {
                 if(FBWebDialogResultDialogCompleted == result)
                 {
                     NSString *title = self.successMessage;
                     UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                                      message:nil
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Ok"
                                                            otherButtonTitles: nil];
                     [alert show];
                     
                 }
                 // Send the URL parameters back, for a requests dialog, the "request" parameter
                 // will include the resutling request id. For a feed dialog, the "post_id"
                 // parameter will include the resulting post id.
                 
             }
         }
         
     }];
    
}

- (NSDictionary*) responseObject
{
    NSString* status = @"unknown";
    NSDictionary* sessionDict = nil;
    
    NSTimeInterval expiresTimeInterval = [FBSession.activeSession.accessTokenData.expirationDate timeIntervalSinceNow];
    NSString* expiresIn = @"0";
    if (expiresTimeInterval > 0)
    {
        expiresIn = [NSString stringWithFormat:@"%0.0f", expiresTimeInterval];
    }
    
    if (FBSession.activeSession.isOpen
        && self.userid != nil
        && ![self.userid isKindOfClass:[NSNull class]]) {
        
        status = @"connected";
        sessionDict = @{
                        @"accessToken" : FBSession.activeSession.accessTokenData.accessToken,
                        @"expiresIn" : expiresIn,
                        @"secret" : @"...",
                        @"session_key" : [NSNumber numberWithBool:YES],
                        @"sig" : @"...",
                        @"userID" : self.userid,
                        };
    }
    
    NSMutableDictionary *statusDict = [NSMutableDictionary dictionaryWithObject:status forKey:@"status"];
    if (nil != sessionDict)
    {
        [statusDict setObject:sessionDict forKey:@"authResponse"];
    }
    
    return statusDict;
}

/**
 * A method for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [pairs enumerateObjectsUsingBlock:
     ^(NSString *pair, NSUInteger idx, BOOL *stop)
    {
         NSArray *kv = [pair componentsSeparatedByString:@"="];
         NSString *val = [kv[1]
                          stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         params[kv[0]] = val;
     }];
    return params;
}
@end
