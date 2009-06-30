//
//  Frame.h
//
// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.

#import <Cocoa/Cocoa.h>

typedef enum DotState
{
	Dot_Clear = 0,
	Dot_Off = 0,
	Dot_Low = 1,
	Dot_Med = 2,
	Dot_High = 3
} DotState;


@interface Frame : NSObject
{
	char *dots;
	bool edited;
	int rows, cols;
	int frameSize;
}
- (id)initWithRows:(int)theRows columns:(int)theCols dots:(char*)dotData;
// Saving/loading dots
- (NSData*)data;
- (char *)bytes;

@property (readonly) int rows;
@property (readonly) int columns;

-(BOOL)isEdited;
-(void)clearEdited;

// Dot Accessors
-(DotState)dotAtRow:(int)row column:(int) col;
-(void)setDotAtRow:(int)row column:(int)col toState:(DotState)state;
// Dot Manipulators
-(void)shiftUp;
-(void)shiftDown;
-(void)shiftRight;
-(void)shiftLeft;
-(void)shiftRect:(NSRect)rect vertical:(int)direction;
-(void)shiftRect:(NSRect)rect horizontal:(int)direction;

- (void)resize:(NSSize)newSize;
@end
