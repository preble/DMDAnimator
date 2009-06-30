//
//  DMDFontmapperController.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/28/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import "DMDFontmapperController.h"


@implementation DMDFontmapperController

@synthesize verticalOffsetField;;

- (id)init
{
	if (self = [super init])
	{
    }
    return self;
}
- (void)dealloc
{
    [super dealloc];
}
- (IBAction)apply:(id)sender
{
    [[[NSFontManager sharedFontManager] delegate] changeFont:[NSFontManager sharedFontManager]];
}
@end
