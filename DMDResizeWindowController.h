//
//  DMDDocumentController.h
//  DMDAnimator
//
//  Created by Adam Preble on 6/27/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Animation;

@interface DMDResizeWindowController : NSWindowController {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *resizeSheet;
	IBOutlet NSView *documentView;
	NSNumber *width;
	NSNumber *height;
	IBOutlet Animation *animation;
}
@property (nonatomic, copy) NSNumber *width;
@property (nonatomic, copy) NSNumber *height;
- (void)show;
- (IBAction)okButton:(id)sender;
- (IBAction)cancelButton:(id)sender;
@end
