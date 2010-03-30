//
//  Frame.h
//
// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.

#import <Cocoa/Cocoa.h>

typedef enum DMDDotState
{
	DMDDotClear = 0,
	DMDDotOff = 0,
	DMDDotLow = 0x5,
	DMDDotMed = 0xa,
	DMDDotHigh = 0xf
} DMDDotState;

@class Animation;

@interface Frame : NSObject <NSCoding>
{
	char *dots;
	int height, width;
	int frameSize;
	Animation *document;
}
- (id)initWithSize:(NSSize)size dots:(const char*)dotData document:(Animation*)document;
// Saving/loading dots
- (NSData*)data;
- (void)setData:(NSData *)data;
- (char *)bytes;

@property (readonly) int height;
@property (readonly) int width;
@property (readonly) NSSize size;

// Dot Accessors
-(DMDDotState)dotAtRow:(int)row column:(int) col;
-(DMDDotState)dotAtPoint:(NSPoint)point;
-(void)setDotAtRow:(int)row column:(int)col toState:(DMDDotState)state;
-(void)setDotAtPoint:(NSPoint)point toState:(DMDDotState)state;
- (void)setDotsInRect:(NSRect)rect toState:(DMDDotState)state;
// Dot Manipulators
-(void)shiftUp;
-(void)shiftDown;
-(void)shiftRight;
-(void)shiftLeft;
-(void)shiftRect:(NSRect)rect vertical:(int)direction;
-(void)shiftRect:(NSRect)rect horizontal:(int)direction;

- (void)resize:(NSSize)newSize;

- (Frame *)frameWithRect:(NSRect)rect;
- (void)setDotsFromFrame:(Frame *)frame sourceOrigin:(NSPoint)source destOrigin:(NSPoint)dest size:(NSSize)size;

@end
