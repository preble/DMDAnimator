//
//  DMDAnimatorAppDelegate.h
//  DMDAnimator
//
//  Created by Adam Preble on 6/27/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *DMDDotsPboardType;

@class DMDFontPreviewWindowController;

@interface DMDAnimatorAppDelegate : NSObject {
    DMDFontPreviewWindowController *fontPreviewWindowController;
}
- (IBAction)toggleFontPreview:(id)sender;
@end
