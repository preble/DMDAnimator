//
//  DMDDocumentController.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/27/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import "DMDResizeWindowController.h"
#import "Animation.h"
#import "NSWindowAdditions.h"

@implementation DMDResizeWindowController

@synthesize width, height;

- (id)init
{
	if (self = [super init])
	{
		[self setWidth:[NSNumber numberWithInt:128]];
		[self setHeight:[NSNumber numberWithInt:32]];
	}
	return self;
}
- (void)dealloc
{
	[self setWidth:nil];
	[self setHeight:nil];
	[super dealloc];
}

- (void)awakeFromNib
{
}

- (void)show
{
	if (resizeSheet == nil)
		[NSBundle loadNibNamed:@"DMDResizeWindow" owner:self];
	
	[NSApp beginSheet:resizeSheet modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:NULL];
}

- (IBAction)okButton:(id)sender
{
	[resizeSheet commitChanges];
	[[self document] resize:NSMakeSize([width intValue], [height intValue])];
	//[mainWindow setContentMaxSize:NSMakeSize([width intValue] * 8, [height intValue] * 8)];
	[documentView setFrame:NSMakeRect(0, 0, [width intValue] * 8, [height intValue] * 8)];
	[documentView setNeedsDisplay:YES];
	[NSApp endSheet:resizeSheet returnCode:NSRunStoppedResponse];
}
- (IBAction)cancelButton:(id)sender
{
	[NSApp endSheet:resizeSheet returnCode:NSRunAbortedResponse];
}
- (void)didEndSheet:(NSWindow *)theSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [theSheet orderOut:nil];
}
@end
