//
//  DMDLayer.h
//  DMDAnimator
//
//  Created by Adam Preble on 8/21/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Frame.h"

@class Animation;

@interface DMDLayer : NSObject {
	Animation *animation;
	DMDCompositeMode compositeMode;
	BOOL visible;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, retain) Animation *animation;
@property (nonatomic, assign) DMDCompositeMode compositeMode;
@property (nonatomic, assign) BOOL visible;

- (id)initWithAnimation:(Animation *)theAnimation;

- (void)compositeOntoFrame:(Frame *)frame;

@end
