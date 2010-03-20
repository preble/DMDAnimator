//
//  NSWindowAdditions.m
//  DMDAnimator
//
//  Created by Adam Preble on 3/19/10.
//  Copyright 2010 Giraffe Lab. All rights reserved.
//

#import "NSWindowAdditions.h"


@implementation NSWindow (APAdditions)


- (void)commitChanges
{
    NSWindow *oMainDocumentWindow = self;
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



@end
