//
//  DMDEditorWindowController.h
//  DMDAnimator
//
//  Created by Adam Preble on 3/19/10.
//  Copyright 2010 Giraffe Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DMDView;
@class DMDResizeWindowController;

@interface DMDEditorWindowController : NSWindowController {
    IBOutlet DMDView *dmdView;
    IBOutlet DMDResizeWindowController *resizeWindowController;
}
- (IBAction)resize:(id)sender;
@end
