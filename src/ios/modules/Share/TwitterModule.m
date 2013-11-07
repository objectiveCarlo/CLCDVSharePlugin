//
//  TwitterModule.m
//  CL
//
//  Created by Carlo Luis M. Bation on secret.
//  Copyright (c) 2013 ISBX. All rights reserved.
//

#import "TwitterModule.h"
NSString* kTwitterModuleParamsDefaultTweetKey  = @"tweet";
NSString* kTwitterModuleURLKey                 = @"link";
NSString* kTwitterModuleImageKey               = @"picture";
@implementation TwitterModule
- (BOOL) isTwitterAvailable
{
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    BOOL twitterSDKAvailable = tweetViewController != nil;
    return twitterSDKAvailable;
}
- (BOOL)canPostInTwitterUsingSL
{
    BOOL result = NO;
    if(NSClassFromString(@"SLComposeViewController")!=nil && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        result = YES;
    }
    return result;
    
}
- (BOOL) isTwitterSetup
{
    return  [TWTweetComposeViewController canSendTweet];
}
- (void) composeTweetSL:(NSDictionary*)arguments  withController:(UIViewController *)parentController
{
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        
        
        SLComposeViewControllerCompletionHandler __block completionHandler=
        ^(SLComposeViewControllerResult result)
        {
            
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                    
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
        
        
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:arguments];
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        NSString *text = [options objectForKey:kTwitterModuleParamsDefaultTweetKey];
        NSString *URL = [options objectForKey:kTwitterModuleURLKey];
        NSString *image = [options objectForKey:kTwitterModuleImageKey];
        if(text != nil)
            [controller setInitialText:[options objectForKey:kTwitterModuleParamsDefaultTweetKey]];
        
        if(image != nil)
        {
            if([image isKindOfClass:[NSString class]])
            {
                [controller addImage:[UIImage imageNamed:[options objectForKey:kTwitterModuleImageKey]]];
            }else
            {
                UIImage *imageT = (UIImage *)image;
                [controller addImage:imageT];
            }
        }
        
        if(URL != nil)
            [controller addURL:[NSURL URLWithString:[options objectForKey:kTwitterModuleURLKey]]];
        [controller setCompletionHandler:completionHandler];
        [parentController presentViewController:controller animated:YES completion:NO];
        recentController = parentController;
    }
    
    
}
- (void) composeTweet:(NSDictionary*)arguments withController:(UIViewController *)controller
{
    
    if([self canPostInTwitterUsingSL])
    {
        [self composeTweetSL:arguments withController:controller];
        return;
    }
    
    if(![self isTwitterAvailable] || ![self isTwitterSetup])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.errorMessageTitle message:self.errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *tweetText   = [arguments objectForKey:kTwitterModuleParamsDefaultTweetKey];
    NSString *urlAttach   = [arguments objectForKey:kTwitterModuleURLKey];
    NSString *imageAttach = [arguments objectForKey:kTwitterModuleImageKey];
    
    TWTweetComposeViewControllerCompletionHandler
    completionHandler =
    ^(TWTweetComposeViewControllerResult result)
    {
        switch (result)
        {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: canceled");
                break;
            case TWTweetComposeViewControllerResultDone:
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
            default:
                NSLog(@"Twitter Result: default");
                break;
        }
        
        if([[recentController presentedViewController] isKindOfClass:[TWTweetComposeViewController class]])
        {
            [recentController dismissViewControllerAnimated:NO completion:nil];
        }
    };
    
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    [tweetViewController setCompletionHandler:completionHandler];
    BOOL ok = YES;
    NSString *errorMessage;
    
    if(tweetText != nil)
    {
        ok = [tweetViewController setInitialText:tweetText];
        if(!ok)
        {
            errorMessage = @"Tweet is too long";
        }
    }
    
    
    
    if(imageAttach != nil)
    {
        
        if([imageAttach isKindOfClass:[NSString class]])
        {
            // Note that the image is loaded syncronously
            if([imageAttach hasPrefix:@"http://"])
            {
                UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageAttach]]];
                ok = [tweetViewController addImage:img];
                
            }
            else
            {
                ok = [tweetViewController addImage:[UIImage imageNamed:imageAttach]];
            }
            if(!ok)
            {
                errorMessage = @"Image could not be added";
            }
        }else
        {
            UIImage *image = (UIImage *)imageAttach;
            ok = [tweetViewController addImage:image];
        }
    }
	
	if(urlAttach != nil)
    {
        ok = [tweetViewController addURL:[NSURL URLWithString:urlAttach]];
        if(!ok)
        {
            errorMessage = @"URL too long";
        }
    }
    
    
    [controller presentViewController:tweetViewController animated:NO completion:nil];
    recentController = controller;
}
@end
