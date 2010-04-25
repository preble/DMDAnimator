//
//  MyDocument.h
//  DMDAnimator
//
// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.


#import <Cocoa/Cocoa.h>
#import "Frame.h"
#import "DMDView.h"

@interface Animation : NSDocument <DMDViewDataSource>
{
	NSMutableArray* frames;
	int height, width;
}
@property (readonly) int height;
@property (readonly) int width;
@property (readonly) NSSize size; // KV-observable.

- (id)initWithSize:(NSSize)size;
- (int)frameCount;
- (void)resize:(NSSize)newSize;
- (void)fillWithFont:(NSFont *)font verticalOffset:(float)verticalOffset;
- (Frame*)frameAtIndex:(int)index;
@end
