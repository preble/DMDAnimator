// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.
#import "DMDView.h"
#import "DMDAnimatorAppDelegate.h"
#import "DMDResizeWindowController.h"
#import "DMDViewSettingsController.h" 
#import "DMDFontmapperController.h"

@implementation DMDView
@synthesize viewFontTools;

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		NSLog(@"Initializing");
		colorOff = [NSColor blackColor];
		colorLow = [[NSColor colorWithDeviceRed: 0.5 green: 0.25 blue: 0.0 alpha: 1.0] retain];
		colorMed = [[NSColor colorWithDeviceRed: 0.8 green: 0.5 blue: 0.0 alpha: 1.0] retain];
		colorHigh = [[NSColor colorWithDeviceRed: 1.0 green: 0.7 blue: 0.0 alpha: 1.0] retain];
		sixteenColors[0] = [colorOff retain];
		for (int c = 1; c < 16; c++)
		{
			float q = (0.80 * ((float)c/15.0));
			sixteenColors[c] = [[NSColor colorWithDeviceRed:q+0.20 green:q*0.8 blue:0 alpha:1] retain];
		}
		rectSelected = NO;
		rectSelecting = NO;
	}
	return self;
}
- (void)dealloc
{
	for (int c = 0; c < 16; c++)
		[sixteenColors[c] release];

	[super dealloc];
}
- (void)awakeFromNib
{
	[[self window] makeFirstResponder:self];
	[[self window] setAcceptsMouseMovedEvents: YES];
    [self setFrame:NSMakeRect(0, 0, [animation columns] * 8, [animation rows] * 8)];
    [[NSFontManager sharedFontManager] setDelegate:self];
    [[NSFontManager sharedFontManager] setSelectedFont:[NSFont fontWithName:@"Helvetica" size:24.0f] isMultiple:NO];
    fontmapperController = [[DMDFontmapperController alloc] initWithNibName:@"FontmapperView" bundle:[NSBundle mainBundle]];
    [[NSFontPanel sharedFontPanel] setAccessoryView:[fontmapperController view]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUndo:) name:NSUndoManagerDidUndoChangeNotification object:nil];
}
- (void)didUndo:(NSNotification*)notification
{
	[self setNeedsDisplay:YES];
}
- (BOOL)acceptsFirstResponder
{
	return YES;
}
- (void)showCursor:(bool)value
{
	if(value != cursorShown) {
		cursorShown = value;
		[self setNeedsDisplay: YES];
	}
}
- (void)moveCursorToRow:(int)row column:(int)col
{
	bool doDisplay = NO;
	if(!cursorShown) {
		cursorShown = YES;
		doDisplay = YES;
		rectSelected = NO;
		rectSelecting = NO;
	}
	if(row != cursorRow || col != cursorCol) {
		cursorRow = row % [animation rows];
		cursorCol = col % [animation columns];
		doDisplay = YES;
		if(cursorRow < 0) {
			cursorRow = [animation rows]-1;
		}
		if(cursorCol < 0) {
			cursorCol = [animation columns]-1;
		}
	}
	//if(row < 0 || row >= [animation rows] || col < 0 || col >= [animation columns]) {
	//	cursorShown = NO;
	//}
	[self setNeedsDisplay: doDisplay];
}
- (void)keyUp:(NSEvent*)event
{
}
- (void)keyDown:(NSEvent*)event
{
    int charIndex;
    int charsInEvent;

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
					rectSelection = NSMakeRect(cursorCol, cursorRow, 1, 1);
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
					if(rectSelection.size.height < [animation rows]-1) {
                        inc = MIN(inc, [animation rows] - rectSelection.size.height);
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
					if(rectSelection.size.width < [animation columns]-1) {
                        inc = MIN(inc, [animation columns] - rectSelection.size.width);
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
				cursorCol = rectSelection.origin.x;
				cursorRow = rectSelection.origin.y;
			}
			// [Opt]+Arrow: Move cursor.
			switch(character) {
				case NSUpArrowFunctionKey: [self moveCursorToRow:cursorRow-inc column:cursorCol]; continue;
				case NSDownArrowFunctionKey: [self moveCursorToRow:cursorRow+inc column:cursorCol]; continue;
				case NSLeftArrowFunctionKey: [self moveCursorToRow:cursorRow column:cursorCol-inc]; continue;
				case NSRightArrowFunctionKey: [self moveCursorToRow:cursorRow column:cursorCol+inc]; continue;
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
		
		if(character == ' ') {
			if([animation togglePlay]) {
				timer = [NSTimer scheduledTimerWithTimeInterval: 1.0/10.0 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
			} else {
				[timer invalidate];
			}
			continue;
		}
		
		NSLog(@"Unknown character: %C", character);
	}
	[self setNeedsDisplay: YES];
	[self updateWindowTitle];
}
- (void)setDot:(DotState)state
{
	if(rectSelected) {
		[[animation frame] setDotsInRect:rectSelection toState:state];
	} else {
		[[animation frame] setDotAtRow:cursorRow column:cursorCol toState:state];
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
	[animation insertFrameAfterCurrent];
	[animation nextFrame];
	[self updateWindowTitle];
}
- (IBAction)framePrevious:(id)sender
{
	[animation prevFrame];
	[self updateWindowTitle];
	[self setNeedsDisplay: YES];
}
- (IBAction)frameNext:(id)sender
{
	[animation nextFrame];
	[self updateWindowTitle];
	[self setNeedsDisplay: YES];
}
- (IBAction)frameShiftRight:(id)sender
{
	if(rectSelected) {
		[[animation frame] shiftRect:rectSelection horizontal:1];
		rectSelection.origin.x++;
	} else {
		[[animation frame] shiftRight];
	}
	[self setNeedsDisplay: YES];
}
- (IBAction)frameShiftLeft:(id)sender
{
	if(rectSelected) {
		[[animation frame] shiftRect:rectSelection horizontal:-1];
		rectSelection.origin.x--;
	} else {
		[[animation frame] shiftLeft];
	}
	[self setNeedsDisplay: YES];
}
- (IBAction)frameShiftUp:(id)sender
{
	if(rectSelected) {
		[[animation frame] shiftRect:rectSelection vertical:-1];
		rectSelection.origin.y--;
	} else {
		[[animation frame] shiftUp];
	}
	[self setNeedsDisplay: YES];
}
- (IBAction)frameShiftDown:(id)sender
{
	if(rectSelected) {
		[[animation frame] shiftRect:rectSelection vertical:1];
		rectSelection.origin.y++;
	} else {
		[[animation frame] shiftDown];
	}
	[self setNeedsDisplay: YES];
}

// Clipboard
- (void)copy:(id)sender
{
	if(rectSelected) {
        Frame *frame = [[animation frame] frameWithRect:rectSelection];
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
    NSPoint destOrigin = NSMakePoint(cursorCol, cursorRow);
    NSSize size = NSMakeSize([frame columns], [frame rows]);
    [[animation frame] setDotsFromFrame:frame sourceOrigin:sourceOrigin destOrigin:destOrigin size:size];
	[self setNeedsDisplay:YES];
}

- (void)updateWindowTitle
{
	NSString* filename = [[self window] representedFilename];
	if([filename length] == 0) {
		filename = @"Untitled";
	}
	[[self window] setTitle: [NSString stringWithFormat:@"%@ - %d/%d", 
		[filename lastPathComponent], [animation frameNumber]+1, [animation frameCount]]];
}
void PointToDot(NSPoint point, int *row, int *col)
{
	*row = (int)floor((point.y) / dotSize);
	*col = (int)floor(point.x / dotSize);
}
- (void)mouseMoved:(NSEvent*)event
{
	NSPoint localPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	if(NSPointInRect(localPoint, NSIntersectionRect([self bounds], [[self superview] bounds]))) {
		int row, col;
		PointToDot(localPoint, &row, &col);
		//NSLog(@"mouseMoved %f, %f => %d, %d", localPoint.x, localPoint.y, col, row);
		[self moveCursorToRow:row column:col];
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
	int row, col;
	PointToDot(localPoint, &row, &col);
	Frame* frame = [animation frame];
	DotState state = [frame dotAtRow:row column:col];
	[frame setDotAtRow:row column:col toState:(state + 1) % 4];
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

	Frame* frame = [[animation frame] retain];
	if(frame == nil) {
		return;
	}
	[frame retain];
	
	int row0 = ((int)rect.origin.y)/dotSize;
	int col0 = ((int)rect.origin.x)/dotSize;
	int rowCount = MIN(1 + ((int)rect.size.height)/dotSize, [frame rows]);
	int colCount = MIN(1 + ((int)rect.size.width)/dotSize, [frame columns]);

	DotState lastState = Dot_Off;
	int row, col;
	for(row = row0; row < row0 + rowCount; row++) {
		for(col = col0; col < col0 + colCount; col++) {
			//NSLog(@"%d, %d", row, col);
			DotState state = [frame dotAtRow:row column:col];
			if(state != Dot_Off) {
				if(state != lastState) {
					[sixteenColors[state&0xf] set];
					lastState = state;
				}
				NSRectFill(NSMakeRect(col * dotSize + 1, (row) * dotSize + 1, dotSize-2, dotSize-2));
			}
		}
	}

    if (viewFontTools && [animation frameCount] == 2 && [animation frameNumber] == 0 && [animation rows] == [animation columns])
    {
		[[NSColor colorWithCalibratedRed:0.5 green:0 blue:0 alpha:1] setStroke];
        NSBezierPath* thePath = [NSBezierPath bezierPath];
        Frame *widthsFrame = [animation frameAtIndex:1];
        char *widths = (char*)[widthsFrame bytes];
        for (int i = 0; i < 96; i++)
        {
            int x = (i % 10) * [animation rows]/10 + widths[i];
            int y = (i / 10) * [animation rows]/10;
            [thePath moveToPoint:NSMakePoint(0.5 + dotSize * x, 0.5 + dotSize * y)];
            [thePath lineToPoint:NSMakePoint(0.5 + dotSize * x, 0.5 + dotSize * (y + [animation rows]/10))];
        }
        [thePath stroke];
    }
    
	[frame release];
	if(cursorShown) {
		[[NSColor grayColor] setFill];
		NSFrameRect(NSMakeRect(cursorCol * dotSize, (cursorRow) * dotSize, dotSize, dotSize));
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
            for(row = (guidesY * (1 + row0/guidesY)); row < row0 + rowCount; row += guidesY) 
            {
                [thePath moveToPoint:NSMakePoint(0, 0.5+dotSize * row)];
                [thePath lineToPoint:NSMakePoint([self bounds].size.width, 0.5+dotSize * row)];
            }
        }
        if (guidesX > 0)
        {
            for(col = (guidesX * (1 + col0/guidesY)); col < col0 + colCount; col += guidesX) 
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
	if (guidesX == 0 || guidesY == 0 && [animation rows] == [animation columns] && ([animation rows] % 10) == 0)
	{
		guidesY = guidesX = [animation rows]/10;
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
    guidesEnabled = YES;
    guidesX = [animation columns]/10;
    guidesY = [animation rows]/10;
    
    NSFont *newFont = [sender convertFont:[sender selectedFont]];
    float verticalOffset = [[fontmapperController verticalOffsetField] floatValue];
    NSLog(@"%@ verticalOffset=%0.2f", newFont, verticalOffset);
    [animation fillWithFont:newFont verticalOffset:verticalOffset];
    [self setNeedsDisplay:YES];
    return;
}

- (IBAction)toggleFontTools:(id)sender
{
    [self setViewFontTools:![self viewFontTools]];
    if ([self viewFontTools]) // Should be doing this in a validateMenuItem:.
    {
        [self setGuidelinesEnabled:YES horizontal:[animation rows]/10 vertical:[animation rows]/10];
    }
    [self setNeedsDisplay:YES];
}
- (void)incremementCharWidth:(int)inc
{
    if ([animation frameCount] == 2 && [animation frameNumber] == 0 && [animation rows] == [animation columns])
    {
        int charSize = [animation rows]/10;
        int charIndex = (cursorCol / charSize) + (cursorRow / charSize) * 10;
        int x = charIndex % [animation columns];
        int y = charIndex / [animation columns];
        int value = [[animation frameAtIndex:1] dotAtRow:y column:x] + inc;
        if (value < 0 || value > charSize)
            return;
        [[animation frameAtIndex:1] setDotAtRow:y column:x toState:value];
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
        return [animation rows] == [animation columns];
    }
    return YES;
}

@end
