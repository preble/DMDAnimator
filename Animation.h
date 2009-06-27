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
}
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
@end
