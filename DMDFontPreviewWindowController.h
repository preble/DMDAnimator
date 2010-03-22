//
//  DMDFontPreviewWindowController.h
//  DMDAnimator
//
//  Created by Adam Preble on 3/21/10.
//  Copyright 2010 Giraffe Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMDView.h"

@class Frame;

@interface DMDFontPreviewWindowController : NSWindowController <DMDViewDataSource> {
    IBOutlet DMDView *dmdView;
    IBOutlet NSTextField *textField;
    Frame *frame;
}

@end
