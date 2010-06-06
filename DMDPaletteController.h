//
//  DMDPaletteController.h
//  DMDAnimator
//
//  Created by Adam Preble on 6/5/10.
//  Copyright 2010 Big Nerd Ranch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DMDPaletteView;

@interface DMDPaletteController : NSWindowController {
	IBOutlet DMDPaletteView *paletteView;
}
+ (DMDPaletteController *)sharedController;
- (void)toggleVisible;

- (uint8_t)selectedColor;

@end
