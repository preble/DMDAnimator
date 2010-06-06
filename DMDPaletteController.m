//
//  DMDPaletteController.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/5/10.
//  Copyright 2010 Big Nerd Ranch. All rights reserved.
//

#import "DMDPaletteController.h"
#import "DMDEditorWindowController.h"

static DMDPaletteController *globalPaletteController;

@implementation DMDPaletteController

+ (DMDPaletteController *)sharedController
{
	if (!globalPaletteController)
	{
		globalPaletteController = [[DMDPaletteController alloc] initWithWindowNibName:@"PalettePanel"];
		[[NSNotificationCenter defaultCenter] addObserver:globalPaletteController selector:@selector(documentActivateNotification:) name:DMDNotificationDocumentActivate object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:globalPaletteController selector:@selector(documentDeactivateNotification:) name:DMDNotificationDocumentDeactivate object:nil];
	}
	return globalPaletteController;
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
		return;
	}
	
	//Animation *anim = (Animation *)document;
}

- (NSString *) windowTitleForDocumentDisplayName: (NSString *) displayName
{
	return [NSString stringWithFormat:NSLocalizedString(@"Palette", @""), displayName];
}

- (void) windowDidLoad
{
	[super windowDidLoad];
	
	[self setShouldCascadeWindows:NO];
	[self setWindowFrameAutosaveName:@"palettePanel"];
	
}

- (uint8_t)selectedColor
{
	return [paletteView selectedColor];
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
