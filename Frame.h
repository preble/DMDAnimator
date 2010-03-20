//
//  Frame.h
//
// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.

#import <Cocoa/Cocoa.h>

typedef enum DotState
{
	Dot_Clear = 0,
	Dot_Off = 0,
	Dot_Low = 0x5,
	Dot_Med = 0xa,
	Dot_High = 0xf
} DotState;

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
-(DotState)dotAtRow:(int)row column:(int) col;
-(void)setDotAtRow:(int)row column:(int)col toState:(DotState)state;
- (void)setDotsInRect:(NSRect)rect toState:(DotState)state;
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
