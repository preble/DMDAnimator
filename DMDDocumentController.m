//
//  DMDDocumentController.m
//  DMDAnimator
//
//  Created by Adam Preble on 8/21/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import "DMDDocumentController.h"

// This is a subclass of NSDocumentController, mainly to allow KVO of the documents array.
// According to http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/Documents/Tasks/SubclassController.html
// the subclass is used by making it the first instance of NSDocumentController to be instantiated.  So we create an instance in MainMenu.xib.

@implementation DMDDocumentController

- (void)addDocument:(NSDocument *)document
{
	[self willChangeValueForKey:@"documents"];
	[super addDocument:document];
	[self didChangeValueForKey:@"documents"];
}

- (void)removeDocument:(NSDocument *)document
{
	[self willChangeValueForKey:@"documents"];
	[super removeDocument:document];
	[self didChangeValueForKey:@"documents"];
}

@end
