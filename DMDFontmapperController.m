//
//  DMDFontmapperController.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/28/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import "DMDFontmapperController.h"


@implementation DMDFontmapperController

@synthesize tileSizeNumber, scaleNumber;

- (id)init
{
	if (self = [super init])
	{
        self.tileSizeNumber = [NSNumber numberWithInt:32];
        self.scaleNumber = [NSNumber numberWithFloat:1.0f];
    }
    return self;
}
- (void)dealloc
{
    self.tileSizeNumber = nil;
    self.scaleNumber = nil;
    [super dealloc];
}
- (IBAction)apply:(id)sender
{
}
@end
