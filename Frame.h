//
//  Frame.h
//
// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.

#import <Cocoa/Cocoa.h>

#define ROWS 32
#define COLUMNS 128
#define SIZEOF_DOTS (ROWS * COLUMNS)

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
	char dots[SIZEOF_DOTS];
	bool edited;
}
// Saving/loading dots
-(NSData*)data;
- (id)initWithData:(NSData*)data;

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
@end
