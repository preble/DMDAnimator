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

@end
