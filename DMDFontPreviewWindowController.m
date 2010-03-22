//
//  DMDFontPreviewWindowController.m
//  DMDAnimator
//
//  Created by Adam Preble on 3/21/10.
//  Copyright 2010 Giraffe Lab. All rights reserved.
//

#import "DMDFontPreviewWindowController.h"
#import "DMDView.h"
#import "Frame.h"

@implementation DMDFontPreviewWindowController

- (void)awakeFromNib
{
    frame = [[Frame alloc] initWithSize:NSMakeSize(128,32) dots:nil document:nil];
}
- (void)dealloc
{
    [frame release];
    [super dealloc];
}

// DMDViewDataSource //
- (Frame *)currentFrameInDmdView:(DMDView *)dmdView
{
    return frame;
}
- (int)currentFrameIndexInDmdView:(DMDView *)dmdView
{
    return 0;
}
- (int)numberOfFramesInDmdView:(DMDView *)dmdView
{
    return 1;
}
- (Frame *)dmdView:(DMDView *)dmdView frameAtIndex:(int)frameIndex
{
    return frame;
}
- (NSSize)sizeOfFrameInDmdView:(DMDView *)dmdView
{
    return [frame size];
}


@end
