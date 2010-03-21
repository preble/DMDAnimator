//
//  Animation.m
//  DMDAnimator
//
// Created by Adam Preble on 5/19/07.
// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.

#import "Animation.h"
#import "DMDEditorWindowController.h"

@implementation Animation
@synthesize height, width=width;

- (id)init
{
	return [self initWithSize:NSMakeSize(128, 32)];
}

- (id)initWithSize:(NSSize)size
{
    if (self = [super init]) 
	{
		height = size.height;
		width = size.width;
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		frames = [[NSMutableArray arrayWithCapacity:1] retain];
		[frames addObject:[[[Frame alloc] initWithSize:size dots:NULL document:self] autorelease]];
		frameNumber = 0;
		playing = NO;
    }
    return self;
}
- (NSSize)size
{
    return NSMakeSize(width, height);
}
- (int)frameNumber
{
	return frameNumber;
}
-(int)frameCount
{
	return [frames count];
}
- (Frame *)frame
{
	//NSLog(@"frameNumber = %d", frameNumber );
	Frame * frameOut = nil;
	if(frameNumber < [frames count]) {
		frameOut = [frames objectAtIndex:frameNumber];
	}
	if(playing) {
		frameNumber = (frameNumber + 1) % [frames count];
		//NSLog(@"frameNumber advanced to %d", frameNumber );
	}
	return frameOut;
}
- (Frame*)frameAtIndex:(int)index
{
    return [frames objectAtIndex:index];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Animation";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)aType error:(NSError**)error
{
	NSMutableData* data = nil;
	
	if (YES)
	{
		// New file format:
		int32_t format = 0x00646D64;
		int32_t frameCount = [frames count];
		data = [NSMutableData dataWithCapacity:4 * 4 + height * width * frameCount];
		[data appendBytes:&format length:4];
		[data appendBytes:&frameCount length:4];
		[data appendBytes:&width length:4];
		[data appendBytes:&height length:4];
		for (Frame *frame in frames)
		{
			[data appendData:[frame data]];
		}
	}
	else
	{
		 // Legacy file format:
		data = [NSMutableData dataWithCapacity:1 + (height * width) * [frames count]];
		char frameCount = (char)[frames count];
		[data appendBytes:&frameCount length:1];
		
		int frame;
		for(frame = 0; frame < frameCount; frame++) {
			Frame* frameObj = [frames objectAtIndex:frame];
			[data appendData:[frameObj data]];
		}
	}
	
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	[frames removeAllObjects];
	
	char* buffer = (char*)[data bytes];
	int32_t *wordPtr = (int32_t*)[data bytes];
	
	if ([data length] == (128 * 32 * buffer[0] + 1))
	{
		// This is a legacy format file: one byte (frame count) followed by frameCount 128x32 frames:
		int frameCount = buffer[0];
		while([frames count] < frameCount) 
		{
			[frames addObject:[[[Frame alloc] initWithSize:[self size] 
                                                      dots:buffer + 1 + ([frames count] * (height * width))
												  document:self] autorelease]];
		}
	}
	else if(wordPtr[0] == 0x00646D64) // DMD0 format
	{
		int frameCount = wordPtr[1];
		width = wordPtr[2];
		height = wordPtr[3];
		buffer = ((char*)[data bytes]) + 4 * 4;
		int expectedLength = 4 * 4 + height * width * frameCount;
		if ([data length] != expectedLength)
		{
			NSLog(@"Actual file length %d != %d (expected).", (int)[data length], expectedLength);
			return NO;
		}
		while ([frames count] < frameCount)
		{
			[frames addObject:[[[Frame alloc] initWithSize:[self size]
                                                      dots:buffer
												  document:self] autorelease]];
			buffer += height * width;
		}
	}
	frameNumber = 0;
	buffer = NULL;
    
    return YES;
}

-(void)nextFrame
{
	if(frameNumber + 1 < [frames count]) {
		frameNumber++;
	}
}
-(void)prevFrame
{
	if(frameNumber != 0) {
		frameNumber--;
	}
}
-(void)insertFrameAfterCurrent
{
	Frame* currentFrame = [frames objectAtIndex:frameNumber];
	[frames insertObject:[[currentFrame mutableCopy] autorelease] atIndex:frameNumber+1];
}
-(void)play
{
	playing = YES;
}
-(void)pause
{
	playing = NO;
}
-(BOOL)togglePlay
{
	playing = !playing;
	NSLog(@"playing = %d", playing);
	return playing;
}

- (void)resize:(NSSize)newSize
{
	height = newSize.height;
	width = newSize.width;
	for (Frame *frame in frames)
		[frame resize:newSize];
}

- (void)fillWithFont:(NSFont *)font verticalOffset:(float)verticalOffset
{
    [frames removeAllObjects];
    frameNumber = 0;
    [frames addObject:[[Frame alloc] initWithSize:[self size] dots:NULL document:self]];
    [self insertFrameAfterCurrent];
    // Now we have two frames.
    Frame *bitmapFrame = [self frame];
    Frame *widthsFrame = [frames objectAtIndex:1];

	const int stride = 10; // chars per line
	const float charSize = width / (float)stride;
	NSRect bitmapRect = NSMakeRect(0.0, 0.0, width, height);
	NSBitmapImageRep* bitmapRep = nil;
	
	bitmapRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
                                                        pixelsWide:bitmapRect.size.width
                                                        pixelsHigh:bitmapRect.size.height
                                                     bitsPerSample:8
                                                   samplesPerPixel:1
                                                          hasAlpha:NO
                                                          isPlanar:NO
                                                    colorSpaceName:NSCalibratedWhiteColorSpace
                                                      bitmapFormat:0
                                                       bytesPerRow:(1 * bitmapRect.size.width)
                                                      bitsPerPixel:8];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext
										  graphicsContextWithBitmapImageRep:bitmapRep]];
    [[NSColor blackColor] setFill];
	NSRectFill(bitmapRect);
    
	// Draw your content...
	//NSFont *font = [NSFont fontWithName:@"Futura" size:charSize];
	//NSFont *font = [NSFont fontWithName:@"Andale Mono" size:charSize];
	[font set];
    
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSColor whiteColor], NSForegroundColorAttributeName,
								font, NSFontAttributeName,
								nil];
	
    int i;
	for (i = 0; i < 96; i++)
	{
		unichar ch = (unichar)(i+32);
		NSString *str = [NSString stringWithCharacters:&ch length:1];
        float x = (i % stride) * charSize;
        float y = (i / stride) * charSize;
        y += verticalOffset; //1.6f * charSize;
		NSRect rect = NSMakeRect(x, height - y, charSize, charSize * 2.0);
		//NSLog(@"Drawing %@ at %d, %d", str, (int)rect.origin.x, (int)rect.origin.y);
		[str drawInRect:rect withAttributes:attributes];
        NSSize charSize = [str sizeWithAttributes:attributes];
        [widthsFrame bytes][i] = (char)charSize.width;
	}
	
	
	[NSGraphicsContext restoreGraphicsState];
	
	unsigned char *buffer = [bitmapRep bitmapData];
    
    int x, y;
    for (y = 0; y < height; y++)
        for (x = 0; x < width; x++)
            [bitmapFrame setDotAtPoint:NSMakePoint(x,y) toState:(*buffer++)>>6];
    
    [bitmapRep release];
}

- (void)makeWindowControllers
{
    DMDEditorWindowController *editorWindowController = [[DMDEditorWindowController alloc] initWithWindowNibName:@"EditorWindow"];
    [self addWindowController:editorWindowController];
    [editorWindowController release];
}

@end // Animation

