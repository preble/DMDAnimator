//
//  DMDAnimatorAppDelegate.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/27/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import "DMDAnimatorAppDelegate.h"

NSString *DMDDotsPboardType = @"dmdanimator.dots";

@implementation DMDAnimatorAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObjects:DMDDotsPboardType, nil] owner:self];
}

@end
