//
//  Frame+Drawing.h
//  DMDAnimator
//
//  Created by Adam Preble on 6/5/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Frame.h"

typedef enum DMDDisplayMode {
    DMDDisplayModeBasic,
    DMDDisplayModeRealistic,
	DMDDisplayModeRounded
} DMDDisplayMode;

@interface Frame (Drawing)
- (void)drawDotsInRect:(NSRect)rect dotSize:(int)dotSize displayMode:(DMDDisplayMode)displayMode;
@end