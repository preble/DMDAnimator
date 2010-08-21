//
//  DMDPaletteController.h
//  DMDAnimator
//
//  Created by Adam Preble on 6/5/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DMDPaletteView;

@interface DMDPaletteController : NSWindowController {
	IBOutlet DMDPaletteView *paletteView;
	IBOutlet NSTextField *infoField;
}
+ (DMDPaletteController *)sharedController;
- (void)toggleVisible;

- (uint8_t)selectedColor;

@end
