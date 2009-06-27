// DMDView
// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.

#import <Cocoa/Cocoa.h>
#include "Animation.h"

#define DOT_DIAMETER 8

@interface DMDView : NSView
{
    IBOutlet Animation *animation;

	NSColor* colorOff;
	NSColor* colorLow;
	NSColor* colorMed;
	NSColor* colorHigh;
	
	NSTimer* timer;

	int cursorRow, cursorCol;
	bool cursorShown;
	
	bool rectSelected; // YES if a selection has been completed.
	bool rectSelecting; // YES if a selection is in progress.
	NSRect rectSelection; // Rectangle representing what's selected.
	
}
-(NSColor*)dotStateToColor:(DotState)ds;
-(void)tick:(NSTimer*)timer;
- (void)updateWindowTitle;
- (IBAction)frameNext:(id)sender;
- (IBAction)framePrevious:(id)sender;
- (IBAction)frameShiftRight:(id)sender;
- (IBAction)frameShiftLeft:(id)sender;
- (IBAction)frameShiftUp:(id)sender;
- (IBAction)frameShiftDown:(id)sender;
- (IBAction)dotClear:(id)sender;
- (IBAction)dotOff:(id)sender;
- (IBAction)dotLow:(id)sender;
- (IBAction)dotMedium:(id)sender;
- (IBAction)dotHigh:(id)sender;
@end
