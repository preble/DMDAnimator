//
//  DMDTransportController.m
//  DMDAnimator
//
//  Created by Adam Preble on 4/26/10.
//  Copyright 2010 Big Nerd Ranch. All rights reserved.
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

- (DMDView *)dmdViewForDocument
{
	NSWindowController *wc = [[[self document] windowControllers] objectAtIndex:0];
	NSAssert1([wc respondsToSelector:@selector(dmdView)], @"Not the window controller we were hoping for: %@", wc);
	return [(DMDEditorWindowController*)wc dmdView];
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
	[slider setIntValue:[[self dmdViewForDocument] frameIndex]];
}

- (IBAction)sliderMoved:(id)sender
{
	[[self dmdViewForDocument] setFrameIndex:[slider intValue]];
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
