//
//  Frame+Drawing.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/5/10.
//  Copyright 2010 Big Nerd Ranch. All rights reserved.
//

#import "Frame+Drawing.h"

static NSImage *dotImage;
static NSColor *sixteenColors[16];

@implementation Frame (Drawing)
- (void)drawDotsInRect:(NSRect)rect dotSize:(int)dotSize displayMode:(DMDDisplayMode)displayMode
{
	if (!dotImage && displayMode == DMDDisplayModeRealistic)
	{
		dotImage = [[NSImage imageNamed:@"Dot"] retain];
	}
	if (!sixteenColors[0] && displayMode == DMDDisplayModeBasic)
	{
		sixteenColors[0] = [[NSColor blackColor] retain];
		for (int c = 1; c < 16; c++)
		{
			float q = (0.80 * ((float)c/15.0));
			sixteenColors[c] = [[NSColor colorWithDeviceRed:q+0.20 green:q*0.8 blue:0 alpha:1] retain];
		}
	}
	
    [[NSColor blackColor] set];
	NSRectFill(rect);
	
    int y0 = ((int)rect.origin.y)/dotSize;
	int x0 = ((int)rect.origin.x)/dotSize;
	int yCount = MIN(1 + ((int)rect.size.height)/dotSize, [self height]);
	int xCount = MIN(1 + ((int)rect.size.width)/dotSize, [self width]);
    // Render the whole frame no matter what:
    x0 = y0 = 0;
    xCount = [self width];
    yCount = [self height];
    
	DMDDotState lastState = DMDDotOff;
	int row, col;
	for(row = y0; row < y0 + yCount; row++) {
		for(col = x0; col < x0 + xCount; col++) {
			//NSLog(@"%d, %d", row, col);
			DMDDotState state = [self dotAtRow:row column:col];
			if(state != DMDDotOff) {
				if(state != lastState) {
					[sixteenColors[state&0xf] set];
					lastState = state;
				}
                if (displayMode == DMDDisplayModeBasic)
                {
                    NSRectFill(NSMakeRect(col * dotSize + 1, (row) * dotSize + 1, dotSize-2, dotSize-2));
                }
                else if (displayMode == DMDDisplayModeRealistic)
                {
                    float alpha = (float)(state&0xf)/15.0f;
                    [dotImage drawInRect:NSMakeRect(col * dotSize, (row) * dotSize, dotSize, dotSize) fromRect:NSZeroRect operation:NSCompositeCopy fraction:alpha];
                }
			}
		}
	}
	
}
@end
