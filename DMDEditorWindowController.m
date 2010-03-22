//
//  DMDEditorWindowController.m
//  DMDAnimator
//
//  Created by Adam Preble on 3/19/10.
//  Copyright 2010 Giraffe Lab. All rights reserved.
//

#import "DMDEditorWindowController.h"
#import "DMDView.h"

@implementation DMDEditorWindowController

- (void)windowDidLoad
{
    // Can't set first responder as dataSource in IB?
    [dmdView setDataSource:[self document]];
}

@end
