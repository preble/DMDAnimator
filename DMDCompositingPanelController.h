//
//  DMDCompositingPanelController.h
//  DMDAnimator
//
//  Created by Adam Preble on 8/21/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Frame;

@interface DMDCompositingPanelController : NSWindowController {
	IBOutlet NSView *preview;
	IBOutlet NSTableView *layersTable;
	NSMutableArray *layers;
	Frame *buffer;

}
+ (DMDCompositingPanelController *)sharedController;
- (void)toggleVisible;
@end
