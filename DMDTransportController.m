//
//  DMDTransportController.m
//  DMDAnimator
//
//  Created by Adam Preble on 4/26/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import "DMDTransportController.h"
#import "Animation.h"
#import "DMDEditorWindowController.h"

// Design from: http://borkware.com/rants/inspectors/

static DMDTransportController *globalTransportController;

@implementation DMDTransportController

+ (DMDTransportController *)sharedController
{
	if (!globalTransportController)
	{
		globalTransportController = [[DMDTransportController alloc] initWithWindowNibName:@"TransportControls"];
		[[NSNotificationCenter defaultCenter] addObserver:globalTransportController selector:@selector(documentActivateNotification:) name:DMDNotificationDocumentActivate object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:globalTransportController selector:@selector(documentDeactivateNotification:) name:DMDNotificationDocumentDeactivate object:nil];
	}
	return globalTransportController;
}

- (void)toggleVisible
{
	if ([[self window] isVisible])
		[[self window] orderOut:nil];
	else
	{
		[self showWindow:nil];
		[self setDocument:[[NSDocumentController sharedDocumentController] currentDocument]];
	}
}

- (void)setDocument:(NSDocument *)document
{
	[super setDocument:document];
	
	if (!document)
	{
		[slider setEnabled:NO];
		return;
	}
	
	Animation *anim = (Animation *)document;
	
	[slider setEnabled:YES];
	[slider setMinValue:0];
	[slider setMaxValue:[anim frameCount]-1];
	[slider setNumberOfTickMarks:[anim frameCount]];
	[slider setIntValue:[[[self document] dmdView] frameIndex]];
}

- (IBAction)sliderMoved:(id)sender
{
	[[[self document] dmdView] setFrameIndex:[slider intValue]];
}

- (NSString *) windowTitleForDocumentDisplayName: (NSString *) displayName
{
	return [NSString stringWithFormat:NSLocalizedString(@"Transport Controls for %@", @""), displayName];
}

- (void) windowDidLoad
{
	[super windowDidLoad];

	[self setShouldCascadeWindows:NO];
	[self setWindowFrameAutosaveName:@"transportPanel"];

}

#pragma mark -
#pragma mark Notifications

- (void)documentActivateNotification:(NSNotification *)notification
{
	[self setDocument:[notification object]];
}

- (void)documentDeactivateNotification:(NSNotification *)notification
{
	[self setDocument:nil];
}

@end
