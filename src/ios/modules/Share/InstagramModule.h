//
//  InstagramModule.h
//  CL
//
//  Created by Carlo Luis M. Bation on secret.
//  Copyright (c) 2013 ISBX. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol InstagramModuleDelegate;

@interface InstagramModule : NSObject<UIDocumentInteractionControllerDelegate>

- (void)shareInstagramWithController:(UIViewController *)controller withImageName:(NSString *)imageName;

@property(nonatomic, assign)id<InstagramModuleDelegate>delegate;

@end

@protocol InstagramModuleDelegate <NSObject>

- (void)instagramModule:(InstagramModule *)module didEndSendingToInstagramApp:(BOOL)success;

@end
