//
//  DMDFontmapperController.h
//  DMDAnimator
//
//  Created by Adam Preble on 6/28/09.
//  Copyright 2009 Giraffe Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DMDFontmapperController : NSViewController {
    NSNumber *tileSizeNumber;
    NSNumber *scaleNumber;
}
@property (nonatomic, retain) NSNumber *tileSizeNumber;
@property (nonatomic, retain) NSNumber *scaleNumber;
- (IBAction)apply:(id)sender;
@end
