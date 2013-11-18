//
//  CLShareCDVPLugin.h
//  CL
//
//  Created by Carlo Luis M. Bation on 11/7/13.
//
//


#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import "FacebookModule.h"
#import "InstagramModule.h"
#import "TwitterModule.h"
@interface CLShareCDVPLugin : CDVPlugin<FacebookModuleDelegate,InstagramModuleDelegate>
@property(nonatomic, strong) InstagramModule *instagram;
- (void)shareViaFb:(CDVInvokedUrlCommand*)command;
- (void)shareViaTwitter:(CDVInvokedUrlCommand*)command;
- (void)shareViaInstagram:(CDVInvokedUrlCommand*)command;
@property(nonatomic, strong)NSDictionary* currentPrams;
@end
