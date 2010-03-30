// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.
#import "DMDView.h"
#import "Animation.h"
#import "DMDAnimatorAppDelegate.h"
#import "DMDResizeWindowController.h"
#import "DMDViewSettingsController.h" 
#import "DMDFontmapperController.h"

NSString * const DMDViewDataSourceDidChangeNotification = @"net.adampreble.dmd.dmdView.dataSourceDidChange";

@implementation DMDView
@synthesize dataSource;
@synthesize viewFontTools;

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		NSLog(@"Initializing");
		sixteenColors[0] = [[NSColor blackColor] retain];
		for (int c = 1; c < 16; c++)
		{
			float q = (0.80 * ((float)c/15.0));
			sixteenColors[c] = [[NSColor colorWithDeviceRed:q+0.20 green:q*0.8 blue:0 alpha:1] retain];
		}
        dotImage = [[NSImage imageNamed:@"Dot"] retain];
        displayMode = DMDDisplayModeRealistic;
		rectSelected = NO;
		rectSelecting = NO;
	}
	return self;
}
- (void)dealloc
{
	for (int c = 0; c < 16; c++)
		[sixteenColors[c] release];
    
    [dotImage release];
    dotImage = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUndoManagerDidUndoChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DMDViewDataSourceDidChangeNotification object:nil];
    
	[super dealloc];
}
- (void)awakeFromNib
{
	[[self window] makeFirstResponder:self];
	[[self window] setAcceptsMouseMovedEvents: YES];
    [[NSFontManager sharedFontManager] setDelegate:self];
    [[NSFontManager sharedFontManager] setSelectedFont:[NSFont fontWithName:@"Helvetica" size:24.0f] isMultiple:NO];
    fontmapperController = [[DMDFontmapperController alloc] initWithNibName:@"FontmapperView" bundle:[NSBundle mainBundle]];
    [[NSFontPanel sharedFontPanel] setAccessoryView:[fontmapperController view]];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceDidChange:) name:DMDViewDataSourceDidChangeNotification object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUndo:) name:NSUndoManagerDidUndoChangeNotification object:nil];
}
- (void)dataSourceDidChange:(NSNotification*)notification
{
    // Do this as some sort of "size did change" notification?
    NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];
    [self setFrame:NSMakeRect(0, 0, frameSize.width * 8, frameSize.height * 8)];
}
- (void)didUndo:(NSNotification*)notification
{
	[self setNeedsDisplay:YES];
}
- (BOOL)acceptsFirstResponder
{
	return YES;
}
- (BOOL)fitsFontCriteria
{
    NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];
    return [dataSource numberOfFramesInDmdView:self] == 2 && [dataSource currentFrameIndexInDmdView:self] == 0 && frameSize.width == frameSize.height;
}
- (void)showCursor:(bool)value
{
	if(value != cursorShown) {
		cursorShown = value;
		[self setNeedsDisplay: YES];
	}
}
- (void)moveCursorToPoint:(NSPoint)point
{
	bool doDisplay = NO;
	if(!cursorShown) {
		cursorShown = YES;
		doDisplay = YES;
		rectSelected = NO;
		rectSelecting = NO;
	}
	if (!NSEqualPoints(cursor, point)) {
        NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];
		cursor.x = ((int)point.x) % (int)frameSize.width;
		cursor.y = ((int)point.y) % (int)frameSize.height;
		doDisplay = YES;
		if(cursor.y < 0) {
			cursor.y = frameSize.height-1;
		}
		if(cursor.x < 0) {
			cursor.x = frameSize.width-1;
		}
	}
	[self setNeedsDisplay: doDisplay];
}
- (void)keyUp:(NSEvent*)event
{
}
- (void)keyDown:(NSEvent*)event
{
    int charIndex;
    int charsInEvent;
    NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];

	unsigned int modifiers = [event modifierFlags];

    charsInEvent = [[event characters] length];
	for (charIndex = 0; charIndex < charsInEvent; charIndex++) {
		unichar character = [[event characters] characterAtIndex:charIndex];
		
		if(character >= NSUpArrowFunctionKey && character <= NSRightArrowFunctionKey) {
			int inc = (modifiers & NSAlternateKeyMask) ? 4 : 1; // Option key makes us move by 4.
			// Shift+[Opt]+Arrow: Rectangle selection.
			if(modifiers & NSShiftKeyMask) {
				if(rectSelecting == NO) {
					// Setup for the selection.
					rectSelecting = YES;
					rectSelected = YES; // Set these independently for mouse...?
					rectSelection = NSMakeRect(cursor.x, cursor.y, 1, 1);
					cursorShown = NO;
				}
				switch(character) {
				case NSUpArrowFunctionKey: 
					if(rectSelection.origin.y > 0) { 
                        inc = MIN(inc, rectSelection.origin.y);
						rectSelection.origin.y -= inc; 
						rectSelection.size.height += inc; 
					}
					break;
				case NSDownArrowFunctionKey: 
					if(rectSelection.size.height < frameSize.height-1) {
                        inc = MIN(inc, frameSize.height - rectSelection.size.height);
						rectSelection.size.height += inc; 
					}
					break;
				case NSLeftArrowFunctionKey: 
					if(rectSelection.origin.x > 0) {
                        inc = MIN(inc, rectSelection.origin.x);
						rectSelection.origin.x -= inc; 
						rectSelection.size.width += inc;
					}
					break;
				case NSRightArrowFunctionKey: 
					if(rectSelection.size.width < frameSize.width-1) {
                        inc = MIN(inc, frameSize.width - rectSelection.size.width);
						rectSelection.size.width += inc;
					}
					break;
				}
				continue;
			}
			if(rectSelecting == YES) {
				// If arrow has been moved without the shift key, drop the rect selection.
				rectSelecting = NO;
				rectSelected = NO; // could change this to shift the selection area...?
				cursorShown = YES;
				cursor = rectSelection.origin;
			}
			// [Opt]+Arrow: Move cursor.
			switch(character) {
				case NSUpArrowFunctionKey: [self moveCursorToPoint:NSMakePoint(cursor.x, cursor.y-inc)]; continue;
				case NSDownArrowFunctionKey: [self moveCursorToPoint:NSMakePoint(cursor.x, cursor.y+inc)]; continue;
				case NSLeftArrowFunctionKey: [self moveCursorToPoint:NSMakePoint(cursor.x-inc, cursor.y)]; continue;
				case NSRightArrowFunctionKey: [self moveCursorToPoint:NSMakePoint(cursor.x+inc, cursor.y)]; continue;
			}
		}
		
		switch(character) {
			case '~': [self dotClear:self]; continue;
			case '`': [self dotOff:self]; continue;
			case '1': [self dotLow:self]; continue;
			case '2': [self dotMedium:self]; continue;
			case '3': [self dotHigh:self]; continue;
			//case '+': [self frameNew:self]; continue;
			case '.': [self frameNext:self]; continue;
			case ',': [self framePrevious:self];  continue;
		}
		
//		if(character == ' ') {
//			if([animation togglePlay]) {
//				timer = [NSTimer scheduledTimerWithTimeInterval: 1.0/10.0 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
//			} else {
//				[timer invalidate];
//			}
//			continue;
//		}
		
		NSLog(@"Unknown character: %C", character);
	}
	[self setNeedsDisplay: YES];
	[self updateWindowTitle];
}
- (void)setDot:(DotState)state
{
	if(rectSelected) {
		[[dataSource currentFrameInDmdView:self] setDotsInRect:rectSelection toState:state];
	} else {
		[[dataSource currentFrameInDmdView:self] setDotAtPoint:cursor toState:state];
	}
	[self setNeedsDisplay: YES];
}
- (IBAction)dotClear:(id)sender { [self setDot:Dot_Clear]; }
- (IBAction)dotOff:(id)sender { [self setDot:Dot_Off]; }
- (IBAction)dotLow:(id)sender { [self setDot:Dot_Low]; }
- (IBAction)dotMedium:(id)sender { [self setDot:Dot_Med]; }
- (IBAction)dotHigh:(id)sender { [self setDot:Dot_High]; }

- (IBAction)frameNew:(id)sender
{
//	[animation insertFrameAfterCurrent];
//	[animation nextFrame];
	[self updateWindowTitle];
}
- (IBAction)framePrevious:(id)sender
{
//	[animation prevFrame];
	[self updateWindowTitle];
	[self setNeedsDisplay: YES];
}
- (IBAction)frameNext:(id)sender
{
//	[animation nextFrame];
	[self updateWindowTitle];
	[self setNeedsDisplay: YES];
}
- (IBAction)frameShiftRight:(id)sender
{
	if(rectSelected) {
		[[dataSource currentFrameInDmdView:self] shiftRect:rectSelection horizontal:1];
		rectSelection.origin.x++;
	} else {
		[[dataSource currentFrameInDmdView:self] shiftRight];
	}
	[self setNeedsDisplay: YES];
}
- (IBAction)frameShiftLeft:(id)sender
{
	if(rectSelected) {
		[[dataSource currentFrameInDmdView:self] shiftRect:rectSelection horizontal:-1];
		rectSelection.origin.x--;
	} else {
		[[dataSource currentFrameInDmdView:self] shiftLeft];
	}
	[self setNeedsDisplay: YES];
}
- (IBAction)frameShiftUp:(id)sender
{
	if(rectSelected) {
		[[dataSource currentFrameInDmdView:self] shiftRect:rectSelection vertical:-1];
		rectSelection.origin.y--;
	} else {
		[[dataSource currentFrameInDmdView:self] shiftUp];
	}
	[self setNeedsDisplay: YES];
}
- (IBAction)frameShiftDown:(id)sender
{
	if(rectSelected) {
		[[dataSource currentFrameInDmdView:self] shiftRect:rectSelection vertical:1];
		rectSelection.origin.y++;
	} else {
		[[dataSource currentFrameInDmdView:self] shiftDown];
	}
	[self setNeedsDisplay: YES];
}

// Clipboard
- (void)copy:(id)sender
{
	if(rectSelected) {
        Frame *frame = [[dataSource currentFrameInDmdView:self] frameWithRect:rectSelection];
		if (frame == nil) {
			NSLog(@"copy: Failed to get frame in selection");
			return;
		}
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:frame];
		if (data == nil) {
			NSLog(@"copy: Failed to archived data from frame");
			return;
		}
		[[NSPasteboard generalPasteboard] setData:data forType:DMDDotsPboardType];
	} else {
		NSLog(@"copy: when no rectSelected");
	}
}
- (void)paste:(id)sender
{
	NSString *bestType = [[NSPasteboard generalPasteboard] availableTypeFromArray:[NSArray arrayWithObjects:DMDDotsPboardType, nil]];
	if (bestType == nil)
	{
		NSLog(@"Type not found on pasteboard");
		return;
	}
	Frame *frame = (Frame*)[NSKeyedUnarchiver unarchiveObjectWithData:[[NSPasteboard generalPasteboard] dataForType:DMDDotsPboardType]];
    NSPoint sourceOrigin = NSMakePoint(0, 0);
    NSPoint destOrigin = cursor;
    NSSize size = [frame size];
    [[dataSource currentFrameInDmdView:self] setDotsFromFrame:frame sourceOrigin:sourceOrigin destOrigin:destOrigin size:size];
	[self setNeedsDisplay:YES];
}

- (void)updateWindowTitle
{
	NSString* filename = [[self window] representedFilename];
	if([filename length] == 0) {
		filename = @"Untitled";
	}
	[[self window] setTitle: [NSString stringWithFormat:@"%@ - %d/%d", 
		[filename lastPathComponent], [dataSource currentFrameIndexInDmdView:self]+1, [dataSource numberOfFramesInDmdView:self]]];
}
NSPoint PointToDot(NSPoint point)
{
    return NSMakePoint(floor(point.x / dotSize), floor(point.y / dotSize));
}
- (void)mouseMoved:(NSEvent*)event
{
	NSPoint localPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	if(NSPointInRect(localPoint, NSIntersectionRect([self bounds], [[self superview] bounds]))) {
		int row, col;
		[self moveCursorToPoint:PointToDot(localPoint)];
		[NSCursor setHiddenUntilMouseMoves:YES];
	} else {
		// mouse has left the view
		[self showCursor:NO];
	}
}
- (void)mouseDragging:(NSEvent*)event
{
	
}
-(void)mouseUp:(NSEvent*)event
{
	NSPoint localPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	//NSLog(@"mouseUp: %f, %f -> %d, %d)", localPoint.x, localPoint.y, col, row);
	NSPoint dotPos = PointToDot(localPoint);
	Frame* frame = [dataSource currentFrameInDmdView:self];
	DotState state = [frame dotAtPoint:dotPos];
	[frame setDotAtPoint:dotPos toState:(state + 1) % 4];
	[self setNeedsDisplay: YES];
}
- (void)resetCursorRects
{
	//[self addCursorRect:[self visibleRect] cursor: nil]; //[NSCursor crosshairCursor]];
}

- (void)drawRect:(NSRect)rect
{
	[[NSColor blackColor] set];
	NSRectFill(rect);

	Frame* frame = [[dataSource currentFrameInDmdView:self] retain];
	if(frame == nil) {
		return;
	}
	[frame retain];
	
	int y0 = ((int)rect.origin.y)/dotSize;
	int x0 = ((int)rect.origin.x)/dotSize;
	int yCount = MIN(1 + ((int)rect.size.height)/dotSize, [frame height]);
	int xCount = MIN(1 + ((int)rect.size.width)/dotSize, [frame width]);

	DotState lastState = Dot_Off;
	int row, col;
	for(row = y0; row < y0 + yCount; row++) {
		for(col = x0; col < x0 + xCount; col++) {
			//NSLog(@"%d, %d", row, col);
			DotState state = [frame dotAtRow:row column:col];
			if(state != Dot_Off) {
				if(state != lastState) {
					[sixteenColors[state&0xf] set];
					lastState = state;
				}
                if (displayMode == DMDDisplayModeBasic)
                {
                    NSRectFill(NSMakeRect(col * dotSize + 1, (row) * dotSize + 1, dotSize-2, dotSize-2));
                }
                else if (displayMode == DMDDisplayModeRealistic)
                {
                    float alpha = (float)(state&0xf)/15.0f;
                    [dotImage drawInRect:NSMakeRect(col * dotSize, (row) * dotSize, dotSize, dotSize) fromRect:NSZeroRect operation:NSCompositeCopy fraction:alpha];
                }
			}
		}
	}

    if (viewFontTools && [self fitsFontCriteria])
    {
		[[NSColor colorWithCalibratedRed:0.5 green:0 blue:0 alpha:1] setStroke];
        NSBezierPath* thePath = [NSBezierPath bezierPath];
        Frame *widthsFrame = [dataSource dmdView:self frameAtIndex:1];
        NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];
        char *widths = (char*)[widthsFrame bytes];
        for (int i = 0; i < 96; i++)
        {
            int x1 = (i % 10) * (int)frameSize.width/10 + widths[i];
            int y1 = (i / 10) * (int)frameSize.height/10;
            [thePath moveToPoint:NSMakePoint(0.5 + dotSize * x1, 0.5 + dotSize * y1)];
            [thePath lineToPoint:NSMakePoint(0.5 + dotSize * x1, 0.5 + dotSize * (y1 + frameSize.height/10))];
        }
        [thePath stroke];
    }
    
	[frame release];
	if(cursorShown) {
		[[NSColor grayColor] setFill];
		NSFrameRect(NSMakeRect(cursor.x * dotSize, (cursor.y) * dotSize, dotSize, dotSize));
	}
	if(rectSelecting || rectSelected) {
		[[NSColor grayColor] setFill];
		NSFrameRect(NSMakeRect(rectSelection.origin.x * dotSize, (rectSelection.origin.y) * dotSize, 
			rectSelection.size.width * dotSize, rectSelection.size.height * dotSize));
	} 
    if (guidesEnabled)
    {
		[[NSColor grayColor] setStroke];
        NSBezierPath* thePath = [NSBezierPath bezierPath];
        if (guidesY > 0)
        {
            for(row = (guidesY * (1 + y0/guidesY)); row < y0 + yCount; row += guidesY) 
            {
                [thePath moveToPoint:NSMakePoint(0, 0.5+dotSize * row)];
                [thePath lineToPoint:NSMakePoint([self bounds].size.width, 0.5+dotSize * row)];
            }
        }
        if (guidesX > 0)
        {
            for(col = (guidesX * (1 + x0/guidesY)); col < x0 + xCount; col += guidesX) 
            {
                [thePath moveToPoint:NSMakePoint(0.5 + dotSize * col, 0)];
                [thePath lineToPoint:NSMakePoint(0.5 + dotSize * col, [self bounds].size.height)];
            }
        }
        [thePath stroke];
    }
}

- (BOOL)isFlipped
{
	return YES;
}

-(void)tick:(NSTimer*)timer
{
	[self setNeedsDisplay:YES];
}


- (IBAction)resize:(id)sender
{
	if ([[self window] isDocumentEdited])
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Cannot resize unsaved animation."
										 defaultButton:@"OK" 
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"This feature is intended to be used with new documents."];
		[alert runModal];
		return;
	}
	[resizeWindowController show];
}
- (IBAction)showViewSettings:(id)sender
{
	if (guidesX == 0 || guidesY == 0 && [self fitsFontCriteria])
	{
        NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];
		guidesY = guidesX = (int)frameSize.width/10;
	}
    [viewSettingsController setGuidelinesEnabled:[NSNumber numberWithBool:guidesEnabled]];
    [viewSettingsController setGuidelineSpacingX:[NSNumber numberWithInt:guidesX]];
    [viewSettingsController setGuidelineSpacingY:[NSNumber numberWithInt:guidesY]];
    [viewSettingsController showViewSettings:sender];
}

- (void)setGuidelinesEnabled:(BOOL)enable horizontal:(int)x vertical:(int)y
{
    guidesEnabled = enable;
    guidesX = x;
    guidesY = y;
    [self setNeedsDisplay:YES];
}

- (void)changeFont:(id)sender
{
    NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];
    guidesEnabled = YES;
    guidesX = frameSize.width/10;
    guidesY = frameSize.height/10;
    
    NSFont *newFont = [sender convertFont:[sender selectedFont]];
    float verticalOffset = [[fontmapperController verticalOffsetField] floatValue];
    NSLog(@"%@ verticalOffset=%0.2f", newFont, verticalOffset);
//    [animation fillWithFont:newFont verticalOffset:verticalOffset];
    [self setNeedsDisplay:YES];
    return;
}
- (IBAction)toggleFontTools:(id)sender
{
    [self setViewFontTools:![self viewFontTools]];
    if ([self viewFontTools]) // Should be doing this in a validateMenuItem:.
    {
        NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];
        [self setGuidelinesEnabled:YES horizontal:frameSize.width/10 vertical:frameSize.height/10];
    }
    [self setNeedsDisplay:YES];
}
- (void)incremementCharWidth:(int)inc
{
    if ([self fitsFontCriteria])
    {
        NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];
        int charSize = frameSize.height/10;
        int charIndex = (cursor.x / charSize) + (cursor.y / charSize) * 10;
        int x = charIndex % (int)frameSize.width;
        int y = charIndex / (int)frameSize.width;
        int value = [[dataSource dmdView:self frameAtIndex:1] dotAtRow:y column:x] + inc;
        if (value < 0 || value > charSize)
            return;
        [[dataSource dmdView:self frameAtIndex:1] setDotAtPoint:NSMakePoint(x, y) toState:value];
        [self setNeedsDisplay:YES];
    }
}
- (IBAction)increaseCharWidth:(id)sender
{
    [self incremementCharWidth:1];
}
- (IBAction)decreaseCharWidth:(id)sender
{
    [self incremementCharWidth:-1];
}

-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
    if ([theMenuItem action] == @selector(increaseCharWidth:))
    {
        return viewFontTools;
    }
    if ([theMenuItem action] == @selector(decreaseCharWidth:))
    {
        return viewFontTools;
    }
    if ([theMenuItem action] == @selector(toggleFontTools:))
    {
        [theMenuItem setState:viewFontTools ? NSOnState : NSOffState];
        return [self fitsFontCriteria];
    }
    return YES;
}

@end
