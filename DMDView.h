// DMDView
// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.

#import <Cocoa/Cocoa.h>
#include "Animation.h"

#define dotSize 8

@class DMDViewSettingsController, DMDResizeWindowController, DMDFontmapperController;

@interface DMDView : NSView
{
    IBOutlet Animation *animation;
	IBOutlet DMDResizeWindowController *resizeWindowController;
    IBOutlet DMDViewSettingsController *viewSettingsController;
    IBOutlet DMDFontmapperController *fontmapperController;

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
    
    BOOL guidesEnabled;
    int guidesX;
    int guidesY;
}
-(NSColor*)dotStateToColor:(DotState)ds;
-(void)tick:(NSTimer*)timer;
- (void)updateWindowTitle;
- (void)setGuidelinesEnabled:(BOOL)enable horizontal:(int)x vertical:(int)y;
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
- (IBAction)resize:(id)sender;
- (IBAction)showViewSettings:(id)sender;
- (IBAction)fontize:(id)sender;
@end
