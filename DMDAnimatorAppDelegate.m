//
//  DMDAnimatorAppDelegate.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/27/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import "DMDAnimatorAppDelegate.h"
#import "DMDFontPreviewWindowController.h"
#import "DMDTransportController.h"
#import "DMDPaletteController.h"
#import "DMDCompositingPanelController.h"

NSString *DMDDotsPboardType = @"dmdanimator.dots";

@implementation DMDAnimatorAppDelegate

- (void)dealloc
{
    [fontPreviewWindowController release];
    fontPreviewWindowController = nil;
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:DMDDotsPboardType, nil] owner:self];
	
	[self togglePalettePanel:nil]; // show!
}



- (IBAction)toggleFontPreview:(id)sender
{
    if (fontPreviewWindowController == nil)
    {
        fontPreviewWindowController = [[DMDFontPreviewWindowController alloc] initWithWindowNibName:@"FontPreviewWindow"];
        [[fontPreviewWindowController window] orderOut:self]; // if we don't call this, isVisible says true below?
    }
    if ([[fontPreviewWindowController window] isVisible])
        [[fontPreviewWindowController window] orderOut:self];
    else
        [fontPreviewWindowController showWindow:sender];
}

- (IBAction)toggleTransportPanel:(id)sender
{
	DMDTransportController *transportController = [DMDTransportController sharedController];
	[transportController toggleVisible];
}

- (IBAction)togglePalettePanel:(id)sender
{
	DMDPaletteController *paletteController = [DMDPaletteController sharedController];
	[paletteController toggleVisible];
}

- (IBAction)toggleCompositingPanel:(id)sender
{
	[[DMDCompositingPanelController sharedController] toggleVisible];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(toggleTransportPanel:))
		[menuItem setState:[[[DMDTransportController sharedController] window] isVisible] ? NSOnState : NSOffState];
	if ([menuItem action] == @selector(togglePalettePanel:))
		[menuItem setState:[[[DMDPaletteController sharedController] window] isVisible] ? NSOnState : NSOffState];
	if ([menuItem action] == @selector(toggleCompositingPanel:))
		[menuItem setState:[[[DMDCompositingPanelController sharedController] window] isVisible] ? NSOnState : NSOffState];
	return YES;
}

@end
