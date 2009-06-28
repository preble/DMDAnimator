//
//  DMDViewSettingsController.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/28/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import "DMDViewSettingsController.h"


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

@end
