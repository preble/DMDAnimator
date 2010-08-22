//
//  DMDCompositingPanelController.m
//  DMDAnimator
//
//  Created by Adam Preble on 8/21/10.
//  Copyright 2010 Adam Preble. All rights reserved.
//

#import "DMDCompositingPanelController.h"
#import "DMDLayer.h"
#import "Frame.h"
#import "Frame+Drawing.h"
#import "Animation+DMDView.h"

NSString * const DMDLayersTableColumnLayer = @"layer";
NSString * const DMDLayersTableColumnMode = @"mode";
NSString * const DMDLayersTableDragType = @"DMDLayersTableDragType";

static DMDCompositingPanelController *globalCompositingPanelController = nil;

@interface DMDCompositingPanelController ()
- (void)updateLayersWithDocuments;
- (void)updatePreview;
@end


@implementation DMDCompositingPanelController

+ (DMDCompositingPanelController *)sharedController
{
	if (!globalCompositingPanelController)
	{
		globalCompositingPanelController = [[DMDCompositingPanelController alloc] initWithWindowNibName:@"CompositingPanel"];
	}
	return globalCompositingPanelController;
}

- (id)initWithWindow:(NSWindow *)window
{
	if ((self = [super initWithWindow:window]))
	{
		layers = [[NSMutableArray alloc] init];
		[self updateLayersWithDocuments];
		[[NSDocumentController sharedDocumentController] addObserver:self forKeyPath:@"documents" options:0 context:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSDocumentController sharedDocumentController] removeObserver:self forKeyPath:@"documents"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[layers release];
	[buffer release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dmdViewRefreshedDots:) name:DMDNotificationRefreshedDots object:nil];
	[layersTable registerForDraggedTypes:[NSArray arrayWithObject:DMDLayersTableDragType]];
	[preview setWantsLayer:YES];
	[[preview layer] setDelegate:self];
}

- (void)toggleVisible
{
	if ([[self window] isVisible])
		[[self window] orderOut:nil];
	else
		[self showWindow:nil];
}

#pragma mark -
#pragma mark Layers Table Updating

- (void)updatePreview
{
	if (!buffer)
		buffer = [[Frame alloc] initWithSize:NSMakeSize(128, 32) dots:NULL document:nil];
	
	[buffer setDotsInRect:NSZeroRect toState:0]; // Clear!
	
	for (DMDLayer *layer in [layers reverseObjectEnumerator])
	{
		[layer compositeOntoFrame:buffer];
	}
	// Now display the frame we have created:
	[[preview layer] setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	CGContextSaveGState(ctx);
	//CGContextScaleCTM(ctx, 1, -1);
	NSGraphicsContext *nsgc = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:YES];
	[NSGraphicsContext setCurrentContext:nsgc];
	NSAffineTransform *xform = [NSAffineTransform transform];
	[xform scaleXBy:1 yBy:-1];
	[xform translateXBy:0 yBy:-[layer bounds].size.height];
	[xform concat];
	[buffer drawDotsInRect:NSRectFromCGRect([layer bounds]) dotSize:4 displayMode:DMDDisplayModeBasic];
	CGContextRestoreGState(ctx);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (object == [NSDocumentController sharedDocumentController] && [keyPath isEqual:@"documents"])
	{
		[self updateLayersWithDocuments];
	}
}

- (void)updateLayersWithDocuments
{
	NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
	NSMutableArray *addedDocuments = [NSMutableArray array];
	NSMutableArray *missingLayers = [NSMutableArray arrayWithArray:layers];
	for (NSDocument *doc in documents)
	{
		BOOL found = NO;
		for (DMDLayer *layer in layers)
		{
			if ((id)[layer animation] == (id)doc)
			{
				[missingLayers removeObject:layer];
				found = YES;
				break;
			}
		}
		if (!found)
			[addedDocuments addObject:doc];
	}
	for (DMDLayer *layer in missingLayers)
	{
		[layers removeObject:layer];
	}
	for (Animation *anim in addedDocuments)
	{
		DMDLayer *layer = [[[DMDLayer alloc] initWithAnimation:anim] autorelease];
		[layers addObject:layer];
	}
	[layersTable reloadData];
	[self updatePreview];
}


#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [layers count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	DMDLayer *layer = [layers objectAtIndex:row];
	if ([[tableColumn identifier] isEqual:DMDLayersTableColumnLayer])
	{
		return [NSNumber numberWithInt:[layer visible] ? NSOnState : NSOffState];
	}
	else if ([[tableColumn identifier] isEqual:DMDLayersTableColumnMode])
	{
		return [NSNumber numberWithInt:[layer compositeMode]];
	}
	else
		return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	DMDLayer *layer = [layers objectAtIndex:row];
	if ([[tableColumn identifier] isEqual:DMDLayersTableColumnLayer])
	{
		[layer setVisible:[object intValue] == NSOnState];
		[self updatePreview];
	}
	else if ([[tableColumn identifier] isEqual:DMDLayersTableColumnMode])
	{
		[layer setCompositeMode:[object intValue]];
		[self updatePreview];
	}
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	DMDLayer *layer = [layers objectAtIndex:row];
	if ([[tableColumn identifier] isEqual:DMDLayersTableColumnLayer])
	{
		[cell setTitle:[layer name]];
	}
}


#pragma mark -
#pragma mark Table Drag & Drop

// Source: http://developer.apple.com/Mac/library/documentation/Cocoa/Conceptual/DragandDrop/UsingDragAndDrop.html

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:DMDLayersTableDragType] owner:self];
    [pboard setData:data forType:DMDLayersTableDragType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op
{
    // Add code here to validate the drop
	if (op == NSTableViewDropAbove)
		return NSDragOperationMove;
	else
		return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:DMDLayersTableDragType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	
    // Move the specified row to its new location...
	NSArray *draggedLayers = [layers objectsAtIndexes:rowIndexes];
	[layers removeObjectsAtIndexes:rowIndexes];
	NSInteger actualRow = row;
	if (row > [rowIndexes firstIndex])
		actualRow -= [rowIndexes count];
	NSIndexSet *newIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(actualRow, [rowIndexes count])];
	[layers insertObjects:draggedLayers atIndexes:newIndexes];
	[layersTable selectRowIndexes:newIndexes byExtendingSelection:NO];
	[layersTable reloadData];
	[self updatePreview];
	return YES;
}


#pragma mark -
#pragma mark Notifications

- (void)dmdViewRefreshedDots:(NSNotification *)notification // DMDNotificationRefreshedDots
{
	//DMDView *dmdView = [notification object];
	[self updatePreview];
	
}

@end
