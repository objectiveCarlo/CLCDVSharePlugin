//
//  InstagramModule.m
//  CL
//
//  Created by Carlo Luis M. Bation on secret.
//  Copyright (c) 2013 ISBX. All rights reserved.
//

#import "InstagramModule.h"
NSString* kInstagramModuleFileName     = @"15717.ig";
NSString* kInstagramModuleErrorTitle   = @"Instagram  application unavailable" ;
NSString* kInstagramModuleErrorMessage = @"You need to install Instagram in your device in order to share this image" ;
NSString* kInstagramModuleUTI          = @"com.instagram.photo";
NSString* kInstagramModuleURLScheme    = @"instagram://app";

@implementation InstagramModule
@synthesize delegate;

- (void)shareInstagramWithController:(UIViewController *)controller withImageName:(NSString *)imageName
{
    [self storeImage:imageName];
    NSURL *instagramURL = [NSURL URLWithString:kInstagramModuleURLScheme];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        
        CGRect rect = CGRectMake(0 ,0 , 612, 612);
        
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", kInstagramModuleFileName]];
        
        NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
        self.dic = [self setupControllerWithURL:igImageHookFile usingDelegate:self];

        self.dic.UTI = kInstagramModuleUTI;
        self.dic.delegate=self;
        [self.dic presentOpenInMenuFromRect: rect    inView: controller.view animated: YES ];
      
        //  [[UIApplication sharedApplication] openURL:instagramURL];
    }
    else
    {
        //   //NSLog(@"instagramImageShare");
        UIAlertView *errorToShare = [[UIAlertView alloc] initWithTitle:kInstagramModuleErrorTitle message:kInstagramModuleErrorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        errorToShare.tag=3010;
        [errorToShare show];
    }
}


- (void) storeImage:(NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:kInstagramModuleFileName];
    UIImage *NewImg=[UIImage imageNamed:imageName];
    NSData *imageData = UIImagePNGRepresentation(NewImg);
    [imageData writeToFile:savedImagePath atomically:NO];
}

- (UIImage*) resizedImage:(UIImage *)inImage withRect:(CGRect) thumbRect
{
    CGImageRef imageRef = [inImage CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    

    if (alphaInfo == kCGImageAlphaNone)
        alphaInfo = kCGImageAlphaNoneSkipLast;
    
    // Build a bitmap context that's the size of the thumbRect
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                thumbRect.size.width,       // width
                                                thumbRect.size.height,      // height
                                                CGImageGetBitsPerComponent(imageRef),   // really needs to always be 8
                                                4 * thumbRect.size.width,   // rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo
                                                );
    
    // Draw into the context, this scales the image
    CGContextDrawImage(bitmap, thumbRect, imageRef);
    
    // Get an image from the context and a UIImage
    CGImageRef  ref = CGBitmapContextCreateImage(bitmap);
    UIImage*    result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);   // ok if NULL
    CGImageRelease(ref);
    
    return result;
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    
    
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    interactionController.delegate = self;
    
    return interactionController;
}

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    
}

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller canPerformAction:(SEL)action
{
    
    return YES;
}

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller performAction:(SEL)action
{
 
    return YES;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
   if(delegate !=nil)
       [delegate instagramModule:self didEndSendingToInstagramApp:YES];
}

@end
