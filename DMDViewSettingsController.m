//
//  DMDViewSettingsController.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/28/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import "DMDViewSettingsController.h"
#import "DMDView.h"
#import "NSWindowAdditions.h"

@implementation DMDViewSettingsController

@synthesize guidelineSpacingX, guidelineSpacingY, guidelinesEnabled;

- (id)init
{
	if (self = [super init])
	{
		self.guidelineSpacingX = [NSNumber numberWithInt:32];
		self.guidelineSpacingY = [NSNumber numberWithInt:32];
		self.guidelinesEnabled = [NSNumber numberWithBool:NO];
	}
	return self;
}
- (void)dealloc
{
	self.guidelineSpacingX = nil;
	self.guidelineSpacingY = nil;
	self.guidelinesEnabled = nil;
	[super dealloc];
}


- (IBAction)showViewSettings:(id)sender
{
	if (sheet == nil)
		[NSBundle loadNibNamed:@"DMDViewSettings" owner:self];
	
	[NSApp beginSheet:sheet modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:NULL];
}
- (IBAction)okButton:(id)sender
{
	[sheet commitChanges];
    [documentView setGuidelinesEnabled:[[self guidelinesEnabled] boolValue] horizontal:[[self guidelineSpacingX] intValue] vertical:[[self guidelineSpacingY] intValue]];
	[NSApp endSheet:sheet returnCode:NSRunStoppedResponse];
}
- (void)didEndSheet:(NSWindow *)theSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [theSheet orderOut:nil];
}

@end
