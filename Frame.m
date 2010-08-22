// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.
#import "Frame.h"
#import "Animation.h"

@implementation Frame
@synthesize height, width=width;

- (id)initWithSize:(NSSize)size dots:(const char*)dotData document:(Animation*)theDocument
{
	if (self = [super init])
	{
		dots = NULL;
		[self resize:size];
		if (dotData == NULL)
		{
			int i;
			for(i = 0; i < frameSize; i++) {
				dots[i] = DMDDotClear;
			}
		}
		else
		{
			memcpy(dots, dotData, frameSize);
		}
		document = theDocument;
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
    [coder encodeInt:height forKey:kFrameArchiveKeyHeight];
    [coder encodeInt:width forKey:kFrameArchiveKeyWidth];
}
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) //self = [super initWithCoder:coder];
    {
        height = [coder decodeIntForKey:kFrameArchiveKeyHeight];
        width = [coder decodeIntForKey:kFrameArchiveKeyWidth];
        NSData *dotData = [coder decodeObjectForKey:kFrameArchiveKeyDots];
        self = [self initWithSize:NSMakeSize(width, height) dots:[dotData bytes] document:nil];
    }
    return self;
}

-(NSData*)data
{
	return [NSData dataWithBytes:dots length:frameSize];
}
- (void)setData:(NSData *)data
{
	if ([data length] != frameSize)
	{
		NSLog(@"%@ ignored; data length %d != frame size %d", NSStringFromSelector(_cmd), [data length], frameSize);
		return;
	}
	memcpy(dots, [data bytes], frameSize);
}
- (char *)bytes
{
    return dots;
}
- (id)mutableCopyWithZone:(NSZone *)zone
{
	return [[Frame alloc] initWithSize:[self size]
                                  dots:dots
							  document:document];
}
- (NSSize)size
{
    return NSMakeSize(width, height);
}
-(DMDDotState)dotAtRow:(int)row column:(int) col
{
	return dots[row * width + col];
}
-(DMDDotState)dotAtPoint:(NSPoint)point
{
    return dots[((int)point.y)*width + ((int)point.x)];
}
-(void)setDotAtRow:(int)row column:(int)col toState:(DMDDotState)state
{
    [self setDotAtPoint:NSMakePoint(col, row) toState:state];
}
- (void)setDotAtPoint:(NSPoint)point toState:(DMDDotState)state
{
	[[[document undoManager] prepareWithInvocationTarget:self] setDotAtPoint:point toState:[self dotAtPoint:point]];
	[[document undoManager] setActionName:@"Set Dot"];
	dots[((int)point.y)*width + ((int)point.x)] = state;
}
- (void)setDotsInRect:(NSRect)rect toState:(DMDDotState)state
{
	if (NSEqualRects(rect, NSZeroRect))
		rect = NSMakeRect(0, 0, [self width], [self height]);
	[[[document undoManager] prepareWithInvocationTarget:self] setData:[self data]];
	[[document undoManager] setActionName:@"Set Dots"];
	int x, y;
	for(x = 0; x < rect.size.width; x++) {
		for(y = 0; y < rect.size.height; y++) {
            dots[((int)rect.origin.y + y) * width + ((int)rect.origin.x + x)] = state;
		}
	}
}
- (void)shiftUp
{
	[[[document undoManager] prepareWithInvocationTarget:self] setData:[self data]];
	memmove(dots, dots + width, width*(height-1));
	memset(dots + (width*height-1), DMDDotClear, width);
}
- (void)shiftDown
{
	[[[document undoManager] prepareWithInvocationTarget:self] setData:[self data]];
	memmove(dots + width, dots, width*(height-1));
	memset(dots, DMDDotClear, width);
}
- (void)shiftLeft
{
	[[[document undoManager] prepareWithInvocationTarget:self] setData:[self data]];
	int row;
	for(row = 0; row < height; row++) {
		char* rowBase = dots + row * width;
		memmove(rowBase, rowBase + 1, width-1);
		rowBase[width-1] = DMDDotClear;
	}
}
- (void)shiftRight
{
	[[[document undoManager] prepareWithInvocationTarget:self] setData:[self data]];
	int row;
	for(row = 0; row < height; row++) {
		char* rowBase = dots + row * width;
		memmove(rowBase + 1, rowBase, width-1);
		rowBase[width-1] = DMDDotClear;
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
			[self setDotAtRow:rect.origin.y+rect.size.height-1 column:rect.origin.x+col toState:DMDDotClear];
		} else {
			[self setDotAtRow:rect.origin.y column:rect.origin.x+col toState:DMDDotClear];
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
			[self setDotAtRow:rect.origin.y+row column:rect.origin.x+rect.size.width-1 toState:DMDDotClear];
		} else {
			[self setDotAtRow:rect.origin.y+row column:rect.origin.x toState:DMDDotClear];
		}
	}
}

- (void)resize:(NSSize)newSize
{
	if (dots)
		free(dots);
	height = newSize.height;
	width = newSize.width;
	frameSize = height * width;
	dots = (char*)malloc(frameSize);

	int i;
	for(i = 0; i < frameSize; i++) {
		dots[i] = DMDDotOff;
	}
}

- (Frame *)frameWithRect:(NSRect)rect
{
    Frame *frame = [[[Frame alloc] initWithSize:rect.size dots:NULL document:nil] autorelease];
    for(int x = 0; x < rect.size.width; x++)
        for (int y = 0; y < rect.size.height; y++)
            [frame setDotAtPoint:NSMakePoint(x,y) toState:[self dotAtPoint:NSMakePoint(x+rect.origin.x, y+rect.origin.y)]];
    return frame;
}

- (void)setDotsFromFrame:(Frame *)frame sourceOrigin:(NSPoint)source destOrigin:(NSPoint)dest size:(NSSize)size
{
	[[[document undoManager] prepareWithInvocationTarget:self] setData:[self data]];
	[[document undoManager] setActionName:@"Paste Dots"];
    for(int x = 0; x < size.width; x++)
        for (int y = 0; y < size.height; y++)
            dots[((int)dest.y + y) * width + ((int)dest.x + x)] = [frame dotAtPoint:NSMakePoint(x+source.x, y+source.y)];
}

#pragma mark -
#pragma mark Compositing

- (void)compositeRect:(NSRect)srcRect ontoFrame:(Frame *)dst atPoint:(NSPoint)destPoint withMode:(DMDCompositeMode)mode
{
	if (NSEqualRects(srcRect, NSZeroRect))
		srcRect = NSMakeRect(0, 0, [self width], [self height]);
	
	// Constrain 'rect' to the source size:
	srcRect = NSUnionRect(NSMakeRect(0, 0, width, height), srcRect);
	// Constrain 'rect's size to the destination
	NSRect destRect = NSMakeRect(destPoint.x, destPoint.y, NSWidth(srcRect), NSHeight(srcRect));
	destRect = NSUnionRect(NSMakeRect(0, 0, [dst width], [dst height]), destRect);
	srcRect.size.width  = MIN(NSWidth(srcRect),  NSWidth(destRect));
	srcRect.size.height = MIN(NSHeight(srcRect), NSHeight(destRect));
	
	char *srcBytes = [self bytes];
	char *dstBytes = [dst bytes];
	
	if (mode == DMDCompositeModeCopy)
	{
		[dst setDotsFromFrame:self sourceOrigin:srcRect.origin destOrigin:destPoint size:srcRect.size];
	}
	else
	{
		char (^dotTransform)(char, char) = nil;
		switch (mode)
		{
			case DMDCompositeModeAdd:
				dotTransform = ^(char srcDot, char dstDot) { return (char)MIN(srcDot + dstDot, 0xF); };
				break;
			case DMDCompositeModeSubtract:
				dotTransform = ^(char srcDot, char dstDot) { return (char)MAX(dstDot - srcDot, 0x0); };
				break;
			case DMDCompositeModeBlackSrc:
				dotTransform = ^(char srcDot, char dstDot) {
					if ((srcDot & 0xf) != 0)
						return (char)((dstDot & 0xf0) | (srcDot & 0xf));
					else
						return dstDot;
				};
				break;
			default:
				return;
		}
		for (int y = 0; y < NSHeight(srcRect); y++)
		{
			char *src_ptr = &srcBytes[((int)NSMinY(srcRect) + y) * [self width] + (int)NSMinX(srcRect)];
			char *dst_ptr = &dstBytes[((int)destPoint.y + y) * [dst width] + (int)destPoint.x];
			for (int x = 0; x < NSWidth(srcRect); x++)
			{
				dst_ptr[x] = dotTransform(src_ptr[x], dst_ptr[x]);
			}
		}
		
	}
}

@end

