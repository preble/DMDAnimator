// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.
#import "Frame.h"

@implementation Frame
- (id)init
{
	int i;
	for(i = 0; i < SIZEOF_DOTS; i++) {
		dots[i] = Dot_Clear;
	}
	edited = NO;
	return self;
}

- (id)initWithData:(NSData*)data
{
	[data getBytes:dots length:SIZEOF_DOTS];
	edited = NO;
	return self;
}
-(NSData*)data
{
	return [NSData dataWithBytes:dots length:SIZEOF_DOTS];
}
- (id)mutableCopyWithZone:(NSZone *)zone
{
	return [[[Frame alloc] initWithData:[self data]] retain];
}
-(DotState)dotAtRow:(int)row column:(int) col
{
	return dots[row * COLUMNS + col];
}
-(void)setDotAtRow:(int)row column:(int)col toState:(DotState)state
{
	dots[row * COLUMNS + col] = state;
	edited = YES;
}
-(BOOL)isEdited
{
	return edited;
}
-(void)clearEdited
{
	edited = NO;
}
- (void)shiftUp
{
	memmove(dots, dots + COLUMNS, COLUMNS*(ROWS-1));
	memset(dots + (COLUMNS*ROWS-1), Dot_Clear, COLUMNS);
}
- (void)shiftDown
{
	memmove(dots + COLUMNS, dots, COLUMNS*(ROWS-1));
	memset(dots, Dot_Clear, COLUMNS);
}
- (void)shiftLeft
{
	int row;
	for(row = 0; row < ROWS; row++) {
		char* rowBase = dots + row * COLUMNS;
		memmove(rowBase, rowBase + 1, COLUMNS-1);
		rowBase[COLUMNS-1] = Dot_Clear;
	}
}
- (void)shiftRight
{
	int row;
	for(row = 0; row < ROWS; row++) {
		char* rowBase = dots + row * COLUMNS;
		memmove(rowBase + 1, rowBase, COLUMNS-1);
		rowBase[COLUMNS-1] = Dot_Clear;
	}
}
- (void)shiftRect:(NSRect)rect vertical:(int)direction
{
	int row, col;
	for(col = 0; col < rect.size.width; col++) {
		for(row = 0; row < rect.size.height; row++) {
			if(direction < 0) {
				[self setDotAtRow:rect.origin.y+row+direction column:col+rect.origin.x
					toState:[self dotAtRow:rect.origin.y+row column:col+rect.origin.x]];
			} else {
				[self setDotAtRow:rect.origin.y+(rect.size.height-1-row)+direction column:col+rect.origin.x
					toState:[self dotAtRow:rect.origin.y+(rect.size.height-1-row) column:col+rect.origin.x]];
			}
		}
		if(direction < 0) {
			[self setDotAtRow:rect.origin.y+rect.size.height-1 column:rect.origin.x+col toState:Dot_Clear];
		} else {
			[self setDotAtRow:rect.origin.y column:rect.origin.x+col toState:Dot_Clear];
		}
	}
}
- (void)shiftRect:(NSRect)rect horizontal:(int)direction
{
	int row, col;
	for(row = 0; row < rect.size.height; row++) {
		for(col = 0; col < rect.size.width; col++) {
			if(direction < 0) {
				[self setDotAtRow:rect.origin.y+row column:col+rect.origin.x+direction 
					toState:[self dotAtRow:rect.origin.y+row column:col+rect.origin.x]];
			} else {
				[self setDotAtRow:rect.origin.y+row column:(rect.size.width-1-col)+rect.origin.x+direction 
					toState:[self dotAtRow:rect.origin.y+row column:(rect.size.width-1-col)+rect.origin.x]];
			}
		}
		if(direction < 0) {
			[self setDotAtRow:rect.origin.y+row column:rect.origin.x+rect.size.width-1 toState:Dot_Clear];
		} else {
			[self setDotAtRow:rect.origin.y+row column:rect.origin.x toState:Dot_Clear];
		}
	}
}
@end

