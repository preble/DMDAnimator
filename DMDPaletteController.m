//
//  DMDPaletteController.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/5/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import "DMDPaletteController.h"
#import "DMDEditorWindowController.h"
#import "DMDView.h"

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
	// Clear up on the old document:
	if ([self document])
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:DMDNotificationDotCursorMoved object:[self dmdViewForDocument]];
		[infoField setStringValue:@""];
	}
	
	[super setDocument:document];
	
	if (document)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dotCursorMoved:) name:DMDNotificationDotCursorMoved object:[self dmdViewForDocument]];
	}
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

	[self setDocument:[[NSDocumentController sharedDocumentController] currentDocument]];
}

- (uint8_t)selectedColor
{
	return [paletteView selectedColor];
}

#pragma mark -
#pragma mark Notifications

- (void)documentActivateNotification:(NSNotification *)notification // DMDNotificationDocumentActivate
{
	[self setDocument:[notification object]];
}

- (void)documentDeactivateNotification:(NSNotification *)notification // DMDNotificationDocumentDeactivate
{
	[self setDocument:nil];
}

- (void)dotCursorMoved:(NSNotification *)notification // DMDNotificationDotCursorMoved
{
	DMDView *dmdView = [self dmdViewForDocument];
	NSPoint cursor = [dmdView cursor];
	Frame *frame = [[dmdView dataSource] dmdView:dmdView frameAtIndex:[dmdView frameIndex]];
	NSMutableString *info = [NSMutableString string];
	if ([dmdView rectSelecting])
	{
		NSRect selection = [dmdView rectSelection];
		[info appendFormat:@"%dx%d @ %d, %d\n", (int)selection.size.width, (int)selection.size.height, (int)selection.origin.x, (int)selection.origin.y];
	}
	else
	{
		[info appendFormat:@"%d, %d\n", (int)cursor.x, (int)cursor.y];
	}
	[info appendFormat:@"Color: %d", [frame dotAtPoint:cursor]];
	[infoField setStringValue:info];
}

@end
