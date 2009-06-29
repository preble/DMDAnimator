//
//  DMDViewSettingsController.h
//  DMDAnimator
//
//  Created by Adam Preble on 6/28/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DMDView;

@interface DMDViewSettingsController : NSWindowController {
	IBOutlet NSWindow *mainWindow;
	IBOutlet DMDView *documentView;
	IBOutlet NSWindow *sheet;
	NSNumber *guidelineSpacingX;
	NSNumber *guidelineSpacingY;
	NSNumber *guidelinesEnabled;
}
@property (nonatomic, retain) NSNumber *guidelineSpacingX;
@property (nonatomic, retain) NSNumber *guidelineSpacingY;
@property (nonatomic, retain) NSNumber *guidelinesEnabled;
- (IBAction)showViewSettings:(id)sender;
- (IBAction)okButton:(id)sender;
@end
