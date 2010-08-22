//
//  Animation+DMDView.m
//  DMDAnimator
//
//  Created by Adam Preble on 8/22/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import "Animation+DMDView.h"
#import "DMDEditorWindowController.h"

@implementation Animation (DMDView)

- (DMDView *)dmdView
{
	for (NSWindowController *wc in [self windowControllers])
	{
		if ([wc respondsToSelector:@selector(dmdView)])
			return [(DMDEditorWindowController*)wc dmdView];
	}
	return nil;
}

@end
