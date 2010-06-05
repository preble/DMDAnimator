//
//  DMDEditorWindowController.m
//  DMDAnimator
//
//  Created by Adam Preble on 3/19/10.
//  Copyright 2010 Giraffe Lab. All rights reserved.
//

#import "DMDEditorWindowController.h"
#import "DMDView.h"
#import "DMDResizeWindowController.h"

NSString * const DMDNotificationDocumentActivate = @"DMDNotificationDocumentActivate";
NSString * const DMDNotificationDocumentDeactivate = @"DMDNotificationDocumentDeactivate";

@implementation DMDEditorWindowController

- (void)windowDidLoad
{
    // Can't set first responder as dataSource in IB?
    [dmdView setDataSource:[self document]];
    [resizeWindowController setDocument:[self document]];
}

- (DMDView *)dmdView
{
	return dmdView;
}

- (IBAction)resize:(id)sender
{
	if ([[self window] isDocumentEdited])
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Cannot resize unsaved animation."
										 defaultButton:@"OK" 
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"This feature is intended to be used with new documents."];
		[alert runModal];
		return;
	}
	[resizeWindowController show];
}


#pragma mark -
#pragma mark Window Delegate

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DMDNotificationDocumentActivate object:[self document]];
}

- (void)windowDidResignMain:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DMDNotificationDocumentDeactivate object:[self document]];
}

- (void)windowWillClose:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DMDNotificationDocumentDeactivate object:[self document]];
	[dmdView setDataSource:nil];
}


@end
