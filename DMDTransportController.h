//
//  DMDTransportController.h
//  DMDAnimator
//
//  Created by Adam Preble on 4/26/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DMDTransportController : NSWindowController {
	IBOutlet NSSlider *slider;
}
+ (DMDTransportController *)sharedController;
- (void)toggleVisible;
- (IBAction)sliderMoved:(id)sender;
@end
