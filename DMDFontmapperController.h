//
//  DMDFontmapperController.h
//  DMDAnimator
//
//  Created by Adam Preble on 6/28/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DMDFontmapperController : NSViewController {
    IBOutlet NSTextField *verticalOffsetField;
}
@property (readonly) NSTextField *verticalOffsetField;
- (IBAction)apply:(id)sender;
@end
