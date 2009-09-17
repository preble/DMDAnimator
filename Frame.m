// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.
#import "Frame.h"

@implementation Frame
@synthesize rows, columns=cols;

- (id)initWithRows:(int)theRows columns:(int)theCols dots:(const char*)dotData
{
	if (self = [super init])
	{
		dots = NULL;
		[self resize:NSMakeSize(theCols, theRows)];
		if (dotData == NULL)
		{
			int i;
			for(i = 0; i < frameSize; i++) {
				dots[i] = Dot_Clear;
			}
		}
		else
		{
			memcpy(dots, dotData, frameSize);
		}
		edited = NO;
	}
	return self;
}
- (void)dealloc
{
	free(dots);
	dots = NULL;
	[super dealloc];
}

#define kFrameArchiveKeyDots @"dots"
#define kFrameArchiveKeyWidth @"width"
#define kFrameArchiveKeyHeight @"height"

- (void)encodeWithCoder:(NSCoder *)coder {
    //[super encodeWithCoder:coder];
    [coder encodeObject:[NSData dataWithBytes:dots length:frameSize] forKey:kFrameArchiveKeyDots];
    [coder encodeInt:rows forKey:kFrameArchiveKeyHeight];
    [coder encodeInt:cols forKey:kFrameArchiveKeyWidth];
}
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) //self = [super initWithCoder:coder];
    {
        rows = [coder decodeIntForKey:kFrameArchiveKeyHeight];
        cols = [coder decodeIntForKey:kFrameArchiveKeyWidth];
        NSData *dotData = [coder decodeObjectForKey:kFrameArchiveKeyDots];
        self = [self initWithRows:rows columns:cols dots:[dotData bytes]];
    }
    return self;
}

-(NSData*)data
{
	return [NSData dataWithBytes:dots length:frameSize];
}
- (char *)bytes
{
    return dots;
}
- (id)mutableCopyWithZone:(NSZone *)zone
{
	return [[Frame alloc] initWithRows:rows 
                               columns:cols 
                                  dots:dots];
}
-(DotState)dotAtRow:(int)row column:(int) col
{
	return dots[row * cols + col];
}
-(void)setDotAtRow:(int)row column:(int)col toState:(DotState)state
{
	dots[row * cols + col] = state;
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
	memmove(dots, dots + cols, cols*(rows-1));
	memset(dots + (cols*rows-1), Dot_Clear, cols);
}
- (void)shiftDown
{
	memmove(dots + cols, dots, cols*(rows-1));
	memset(dots, Dot_Clear, cols);
}
- (void)shiftLeft
{
	int row;
	for(row = 0; row < rows; row++) {
		char* rowBase = dots + row * cols;
		memmove(rowBase, rowBase + 1, cols-1);
		rowBase[cols-1] = Dot_Clear;
	}
}
- (void)shiftRight
{
	int row;
	for(row = 0; row < rows; row++) {
		char* rowBase = dots + row * cols;
		memmove(rowBase + 1, rowBase, cols-1);
		rowBase[cols-1] = Dot_Clear;
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

- (void)resize:(NSSize)newSize
{
	if (dots)
		free(dots);
	rows = newSize.height;
	cols = newSize.width;
	frameSize = rows * cols;
	dots = (char*)malloc(frameSize);

	int i;
	for(i = 0; i < frameSize; i++) {
		dots[i] = Dot_Off;
	}
}

- (Frame *)frameWithRect:(NSRect)rect
{
    Frame *frame = [[[Frame alloc] initWithRows:rect.size.height columns:rect.size.width dots:NULL] autorelease];
    for(int x = 0; x < rect.size.width; x++)
        for (int y = 0; y < rect.size.height; y++)
            [frame setDotAtRow:y column:x toState:[self dotAtRow:y+rect.origin.y column:x+rect.origin.x]];
    return frame;
}

- (void)setDotsFromFrame:(Frame *)frame sourceOrigin:(NSPoint)source destOrigin:(NSPoint)dest size:(NSSize)size
{
    for(int x = 0; x < size.width; x++)
        for (int y = 0; y < size.height; y++)
            [self setDotAtRow:dest.y+y column:dest.x+x toState:[frame dotAtRow:y+source.y column:x+source.x]];
}

@end

