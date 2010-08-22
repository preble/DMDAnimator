// DMDView
// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.

#import <Cocoa/Cocoa.h>
#import "Frame+Drawing.h"

@class DMDViewSettingsController, DMDResizeWindowController, DMDFontmapperController;
@class DMDView, Animation, Frame;

extern NSString * const DMDNotificationDotCursorMoved;
extern NSString * const DMDNotificationRefreshedDots;

@protocol DMDViewDataSource<NSObject>
- (int)numberOfFramesInDmdView:(DMDView *)dmdView;
- (Frame *)dmdView:(DMDView *)dmdView frameAtIndex:(int)frameIndex;
- (NSSize)sizeOfFrameInDmdView:(DMDView *)dmdView;
@optional
- (void)dmdView:(DMDView *)dmdView insertFrame:(Frame *)frame atIndex:(int)frameIndex;
@end

@interface DMDView : NSView
{
    IBOutlet id<DMDViewDataSource> dataSource;
    IBOutlet DMDViewSettingsController *viewSettingsController;
    IBOutlet DMDFontmapperController *fontmapperController;
	
	int frameIndex;
	
	int dotSize;

    DMDDisplayMode displayMode;
	
	NSTimer* timer;
	int framesPerSecond;

    NSPoint cursor;
	BOOL cursorShown;
	
	BOOL rectSelected; // YES if a selection has been completed.
	BOOL rectSelecting; // YES if a selection is in progress.
	NSPoint pinnedCursor; // Initial cursor position that describes the selected rectangle along with the current cursor.
    
    BOOL guidesEnabled;
    int guidesX;
    int guidesY;
    
    BOOL viewFontTools;
    
    BOOL refreshDots; // YES if the dots should be refreshed on the next -drawRect.
    NSImage *cachedDots;
}
@property (nonatomic, assign) id<DMDViewDataSource> dataSource;
- (void)tick:(NSTimer*)timer;
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
- (IBAction)showViewSettings:(id)sender;

- (IBAction)toggleFontTools:(id)sender;
- (IBAction)increaseCharWidth:(id)sender;
- (IBAction)decreaseCharWidth:(id)sender;

@property (nonatomic, assign) BOOL viewFontTools;
@property (nonatomic, assign) int framesPerSecond;
@property (nonatomic, assign) int frameIndex;
@property (nonatomic, readonly) NSPoint cursor;
@property (nonatomic, readonly) BOOL rectSelecting;

- (NSRect)selectionRect;

@end
