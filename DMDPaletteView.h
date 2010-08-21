//
//  DMDPaletteView.h
//  DMDAnimator
//
//  Created by Adam Preble on 6/5/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Frame;

@interface DMDPaletteView : NSView {
	Frame *paletteFrame;
	uint8_t selectedColor;
}
- (void)setSelectedColor:(uint8_t)color;
- (uint8_t)selectedColor;
@end
