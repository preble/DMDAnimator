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
	int rows, cols;
}
@property (readonly) int rows;
@property (readonly) int columns;

- (id)initWithRows:(int)theRows columns:(int)theCols;
-(int)frameNumber;
-(int)frameCount;
-(Frame*)frame;
-(BOOL)isEdited;
-(void)nextFrame;
-(void)prevFrame;
-(void)insertFrameAfterCurrent;
-(void)play;
-(void)pause;
-(BOOL)togglePlay;
- (void)resize:(NSSize)newSize;
@end
