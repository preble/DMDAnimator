//
//  Frame+Drawing.h
//  DMDAnimator
//
//  Created by Adam Preble on 6/5/10.
//  Copyright 2010 Big Nerd Ranch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Frame.h"

typedef enum DMDDisplayMode {
    DMDDisplayModeBasic,
    DMDDisplayModeRealistic
} DMDDisplayMode;

@interface Frame (Drawing)
- (void)drawDotsInRect:(NSRect)rect dotSize:(int)dotSize displayMode:(DMDDisplayMode)displayMode;
@end
