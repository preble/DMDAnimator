//
//  DMDDocumentController.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/27/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import "DMDResizeWindowController.h"
#import "Animation.h"

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

- (void)commitChanges:(NSWindow *)oMainDocumentWindow
{
	// This is intended to be used when we want to:
	// 1) Commit editing changes (for controls that use bindings -- they only commit their changes when the focus leaves)
	// 2) Keep the first responder consistent.
	
	// From Daniel Jalkut: http://www.red-sweater.com/blog/229/stay-responsive
	
	// Save the current first responder, respecting the fact
	// that it might conceptually be the delegate of the
	// field editor that is "first responder."
	id oldFirstResponder = [oMainDocumentWindow firstResponder];
	if ((oldFirstResponder != nil) &&
		[oldFirstResponder isKindOfClass:[NSTextView class]] &&
		[(NSTextView*)oldFirstResponder isFieldEditor])
	{
		// A field editor's delegate is the view we're editing
		oldFirstResponder = [oldFirstResponder delegate];
		if ([oldFirstResponder isKindOfClass:[NSResponder class]] == NO)
		{
			// Eh ... we'd better back off if
			// this thing isn't a responder at all
			oldFirstResponder = nil;
		}
	} 
	
	// Gracefully end all editing in our window (from Erik Buck).
	// This will cause the user's changes to be committed.
	if([oMainDocumentWindow makeFirstResponder:oMainDocumentWindow])
	{
		// All editing is now ended and delegate messages sent etc.
	}
	else
	{
		// For some reason the text object being edited will
		// not resign first responder status so force an
		/// end to editing anyway
		[oMainDocumentWindow endEditingFor:nil];
	}
	
	// If we had a first responder before, restore it
	if (oldFirstResponder != nil)
	{
		[oMainDocumentWindow makeFirstResponder:oldFirstResponder];
	}
}

- (IBAction)okButton:(id)sender
{
	[self commitChanges:resizeSheet];
	[animation resize:NSMakeSize([width intValue], [height intValue])];
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
