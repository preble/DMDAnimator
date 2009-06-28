//
//  Animation.m
//  DMDAnimator
//
// Created by Adam Preble on 5/19/07.
// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.

#import "Animation.h"

@implementation Animation
@synthesize rows, columns=cols;

- (id)init
{
	return [self initWithRows:32 columns:128];
}

- (id)initWithRows:(int)theRows columns:(int)theCols
{
    if (self = [super init]) 
	{
		rows = theRows;
		cols = theCols;
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		frames = [[NSMutableArray arrayWithCapacity:1] retain];
		[frames addObject:[[Frame alloc] initWithRows:rows columns:cols dots:NULL]];
		frameNumber = 0;
		playing = NO;
    }
    return self;
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
		data = [NSMutableData dataWithCapacity:4 * 4 + rows * cols * frameCount];
		[data appendBytes:&format length:4];
		[data appendBytes:&frameCount length:4];
		[data appendBytes:&cols length:4];
		[data appendBytes:&rows length:4];
		for (Frame *frame in frames)
		{
			[data appendData:[frame data]];
			[frame clearEdited];
		}
	}
	else
	{
		 // Legacy file format:
		data = [NSMutableData dataWithCapacity:1 + (rows * cols) * [frames count]];
		char frameCount = (char)[frames count];
		[data appendBytes:&frameCount length:1];
		
		int frame;
		for(frame = 0; frame < frameCount; frame++) {
			Frame* frameObj = [frames objectAtIndex:frame];
			[data appendData:[frameObj data]];
			[frameObj clearEdited];
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
			[frames addObject:[[Frame alloc] initWithRows:rows 
												  columns:cols 
													 dots:buffer + 1 + ([frames count] * (rows * cols))]];
		}
	}
	else if(wordPtr[0] == 0x00646D64) // DMD0 format
	{
		int frameCount = wordPtr[1];
		cols = wordPtr[2];
		rows = wordPtr[3];
		buffer = ((char*)[data bytes]) + 4 * 4;
		int expectedLength = 4 * 4 + rows * cols * frameCount;
		if ([data length] != expectedLength)
		{
			NSLog(@"Actual file length %d != %d (expected).", (int)[data length], expectedLength);
			return NO;
		}
		while ([frames count] < frameCount)
		{
			[frames addObject:[[Frame alloc] initWithRows:rows 
												  columns:cols 
													 dots:buffer]];
			buffer += rows * cols;
		}
	}
	frameNumber = 0;
	buffer = NULL;
    
    return YES;
}
-(BOOL)isEdited
{
	int i = 0;
	for(i = 0; i < [frames count]; i++) {
		if([[frames objectAtIndex:i] isEdited]) {
			return YES;
		}
	}
	return NO;
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
	[frames insertObject:[currentFrame mutableCopy] atIndex:frameNumber+1];
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
	rows = newSize.height;
	cols = newSize.width;
	for (Frame *frame in frames)
		[frame resize:newSize];
}

@end // Animation

