//
//  MyDocument.h
//  DMDAnimator
//
// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.


#import <Cocoa/Cocoa.h>
#import "Frame.h"

@interface Animation : NSDocument
{
	NSMutableArray* frames;
	int frameNumber;
	BOOL playing;
	int height, width;
}
@property (readonly) int height;
@property (readonly) int width;
@property (readonly) NSSize size;

- (id)initWithSize:(NSSize)size;
-(int)frameNumber;
-(int)frameCount;
-(Frame*)frame;
-(void)nextFrame;
-(void)prevFrame;
-(void)insertFrameAfterCurrent;
-(void)play;
-(void)pause;
-(BOOL)togglePlay;
- (void)resize:(NSSize)newSize;
- (void)fillWithFont:(NSFont *)font verticalOffset:(float)verticalOffset;
- (Frame*)frameAtIndex:(int)index;
@end
