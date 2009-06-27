// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.
#import "DMDView.h"
#import "DMDAnimatorAppDelegate.h"

@implementation DMDView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		NSLog(@"Initializing");
		colorOff = [NSColor blackColor];
		colorLow = [[NSColor colorWithDeviceRed: 0.5 green: 0.25 blue: 0.0 alpha: 1.0] retain];
		colorMed = [[NSColor colorWithDeviceRed: 0.8 green: 0.5 blue: 0.0 alpha: 1.0] retain];
		colorHigh = [[NSColor colorWithDeviceRed: 1.0 green: 0.7 blue: 0.0 alpha: 1.0] retain];
		rectSelected = NO;
		rectSelecting = NO;
	}
	return self;
}
- (void)awakeFromNib
{
	[[self window] makeFirstResponder:self];
	[[self window] setAcceptsMouseMovedEvents: YES];
}
- (bool)acceptsFirstResponder
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
			// Shift+Arrow: Rectangle selection.
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
						rectSelection.origin.y--; 
						rectSelection.size.height++; 
					}
					break;
				case NSDownArrowFunctionKey: 
					if(rectSelection.size.height < [animation rows]-1) {
						rectSelection.size.height++; 
					}
					break;
				case NSLeftArrowFunctionKey: 
					if(rectSelection.origin.x > 0) {
						rectSelection.origin.x--; 
						rectSelection.size.width++; 
					}
					break;
				case NSRightArrowFunctionKey: 
					if(rectSelection.size.width < [animation columns]-1) {
						rectSelection.size.width++; 
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
			int inc = (modifiers & NSAlternateKeyMask) ? 4 : 1;
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
	[[self window] setDocumentEdited:[animation isEdited]];
	[self updateWindowTitle];
}
- (void)setDot:(DotState)state
{
	if(rectSelected) {
		Frame* frame = [animation frame];
		int x, y;
		for(x = 0; x < rectSelection.size.width; x++) {
			for(y = 0; y < rectSelection.size.height; y++) {
				[frame setDotAtRow:rectSelection.origin.y+y column:rectSelection.origin.x+x toState:state];
			}
		}
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
		int clipboardLength = rectSelection.size.width * rectSelection.size.height;
		char *clipboardDots = (char*)malloc(clipboardLength);
		int row, col;
		for(row = 0; row < rectSelection.size.height; row++) {
			for(col = 0; col < rectSelection.size.width; col++) {
				clipboardDots[row * (int)rectSelection.size.width + col] = 
					[[animation frame] dotAtRow:rectSelection.origin.y + row 
					column:rectSelection.origin.x + col];
			}
		}
		NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSValue valueWithSize:rectSelection.size], @"size",
							  [NSData dataWithBytes:clipboardDots length:clipboardLength], @"dots",
							  nil];
		[[NSPasteboard generalPasteboard] setData:[NSArchiver archivedDataWithRootObject:data] forType:DMDDotsPboardType];
		NSLog(@"%s after copy", _cmd);
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
	NSDictionary *data = (NSDictionary*)[NSUnarchiver unarchiveObjectWithData:[[NSPasteboard generalPasteboard] dataForType:DMDDotsPboardType]];
	if (data == nil)
	{
		NSLog(@"Paste but no data!");
		return;
	}
	NSSize clipboardSize = [[data objectForKey:@"size"] sizeValue];
	char *dotData = (char*)[[data objectForKey:@"dots"] bytes];
	int row, col;
	for(row = 0; row < clipboardSize.height; row++) {
		for(col = 0; col < clipboardSize.width; col++) {
			[[animation frame] setDotAtRow:cursorRow + row column:cursorCol + col 
				toState:dotData[row * (int)clipboardSize.width + col]];
		}
	}
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
	*row = (int)floor((point.y) / DOT_DIAMETER);
	*col = (int)floor(point.x / DOT_DIAMETER);
}
- (void)mouseMoved:(NSEvent*)event
{
	NSPoint localPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	if(NSPointInRect(localPoint, [self bounds])) {
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
-(NSColor*)dotStateToColor:(DotState)ds 
{
	switch(ds) {
		case Dot_Low: return colorLow;
		case Dot_Med: return colorMed;
		case Dot_High: return colorHigh;
	}
	return colorOff;
}

- (void)drawRect:(NSRect)rect
{
	[[NSColor blackColor] set];
	NSRectFill([self bounds]);

	Frame* frame = [[animation frame] retain];
	if(frame == nil) {
		return;
	}
	[frame retain];

	DotState lastState = Dot_Off;
	int row, col;
	for(row = 0; row < [animation rows]; row++) {
		for(col = 0; col < [animation columns]; col++) {
			//NSLog(@"%d, %d", row, col);
			DotState state = [frame dotAtRow:row column:col];
			if(state != Dot_Off) {
				if(state != lastState) {
					//NSColor* color = DotStateToColor(state);
					[[self dotStateToColor:state] set];
					lastState = state;
				}
				NSRectFill(NSMakeRect(col * DOT_DIAMETER + 1, (row) * DOT_DIAMETER + 1, DOT_DIAMETER-2, DOT_DIAMETER-2));
			}
		}
	}
	//[frame setDotAtRow:rand()%5 column:rand()%[animation columns] toState:rand()%4];
	[frame release];
	if(cursorShown) {
		[[NSColor grayColor] setFill];
		NSFrameRect(NSMakeRect(cursorCol * DOT_DIAMETER, (cursorRow) * DOT_DIAMETER, DOT_DIAMETER, DOT_DIAMETER));
	}
	if(rectSelecting || rectSelected) {
		[[NSColor grayColor] setFill];
		NSFrameRect(NSMakeRect(rectSelection.origin.x * DOT_DIAMETER, (rectSelection.origin.y) * DOT_DIAMETER, 
			rectSelection.size.width * DOT_DIAMETER, rectSelection.size.height * DOT_DIAMETER));
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
@end
