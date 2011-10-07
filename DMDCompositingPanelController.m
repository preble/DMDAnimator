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
NSString * const DMDLayersTableColumnPosition = @"position";

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
	preview.layer = [CALayer layer];
	[preview setWantsLayer:YES];
	[[preview layer] setDelegate:self];
	[self updatePreview];
}

- (void)toggleVisible
{
	if ([[self window] isVisible])
		[[self window] orderOut:nil];
	else
		[self showWindow:nil];
}

- (void)showWindow:(id)sender
{
	[super showWindow:sender];
	[self updatePreview];
}

#pragma mark -
#pragma mark Layers Table Updating

- (void)updatePreview
{
	if (![[self window] isVisible])
		return;
	
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
	[NSGraphicsContext saveGraphicsState];
	
	NSGraphicsContext *nsgc = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:YES];
	[NSGraphicsContext setCurrentContext:nsgc];
	
	NSAffineTransform *xform = [NSAffineTransform transform];
	[xform scaleXBy:1 yBy:-1];
	[xform translateXBy:0 yBy:-[layer bounds].size.height];
	[xform concat];
	[buffer drawDotsInRect:NSRectFromCGRect([layer bounds])
				   dotSize:MIN([layer bounds].size.width/128, [layer bounds].size.height/32)
			   displayMode:DMDDisplayModeBasic];
	
	[NSGraphicsContext restoreGraphicsState];
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
	else if ([[tableColumn identifier] isEqual:DMDLayersTableColumnPosition])
	{
		return [NSString stringWithFormat:@"%d, %d", (int)[layer position].x, (int)[layer position].y];
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


#pragma mark -
#pragma mark Frame Shift

- (DMDLayer *)selectedLayer
{
	NSInteger row = [layersTable selectedRow];
	if (row == -1)
		return nil;
	else
		return [layers objectAtIndex:row];
}

- (void)offsetSelectedLayerPosition:(NSPoint)offset
{
	DMDLayer *layer = [self selectedLayer];
	if (layer)
		layer.position = NSMakePoint(layer.position.x + offset.x, layer.position.y + offset.y);
}

- (IBAction)frameShiftRight:(id)sender
{
	[self offsetSelectedLayerPosition:NSMakePoint( 1, 0)];
	[self updatePreview];
}
- (IBAction)frameShiftLeft:(id)sender
{
	[self offsetSelectedLayerPosition:NSMakePoint(-1, 0)];
	[self updatePreview];
}
- (IBAction)frameShiftUp:(id)sender
{
	[self offsetSelectedLayerPosition:NSMakePoint(0, -1)];
	[self updatePreview];
}
- (IBAction)frameShiftDown:(id)sender
{
	[self offsetSelectedLayerPosition:NSMakePoint(0,  1)];
	[self updatePreview];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(frameShiftLeft:) ||
		[menuItem action] == @selector(frameShiftRight:) ||
		[menuItem action] == @selector(frameShiftUp:) ||
		[menuItem action] == @selector(frameShiftDown:))
	{
		return [self selectedLayer] != nil;
	}
	return YES;
}

@end
