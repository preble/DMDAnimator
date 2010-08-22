//
//  DMDLayer.m
//  DMDAnimator
//
//  Created by Adam Preble on 8/21/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import "DMDLayer.h"
#import "Animation.h"
#import "Frame.h"
#import "DMDView.h"
#import "DMDEditorWindowController.h"
#import "Animation+DMDView.h"

@interface DMDLayer ()
- (DMDView *)dmdView;
@end

@implementation DMDLayer
@synthesize animation, compositeMode, visible, position;

- (id)initWithAnimation:(Animation *)theAnimation
{
	if ((self = [super init]))
	{
		[self setAnimation:theAnimation];
		visible = YES;
	}
	return self;
}

- (NSString *)name
{
	return [animation displayName];
}


- (DMDView *)dmdView
{
	return [animation dmdView];
}

- (void)compositeOntoFrame:(Frame *)dstFrame
{
	if (!visible)
		return;
	Frame *srcFrame = [animation frameAtIndex:[[self dmdView] frameIndex]];
	[srcFrame compositeRect:NSZeroRect ontoFrame:dstFrame atPoint:position withMode:[self compositeMode]];
}

@end
