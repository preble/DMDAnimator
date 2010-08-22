// DMDAnimator Copyright (c) 2007 Adam Preble.  All Rights Reserved.
#import "DMDView.h"
#import "Animation.h"
#import "DMDAnimatorAppDelegate.h"
#import "DMDViewSettingsController.h" 
#import "DMDFontmapperController.h"
#import "Frame+Drawing.h"
#import "DMDPaletteController.h"

NSString * const DMDNotificationDotCursorMoved = @"DMDNotificationDotCursorMoved";
NSString * const DMDNotificationRefreshedDots = @"DMDNotificationRefreshedDots";

@interface DMDView ()
- (void)updateFrameSize;
- (void)setNeedsDisplayRefreshDots:(BOOL)flag;
- (Frame *)currentFrame;
@property (nonatomic, retain) NSImage *cachedDots;
@end


@implementation DMDView
@synthesize dataSource;
@synthesize viewFontTools;
@synthesize cachedDots;
@synthesize framesPerSecond;
@synthesize frameIndex;
@synthesize cursor, rectSelection, rectSelecting;

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		dotSize = 8;
        displayMode = DMDDisplayModeRealistic;
		rectSelected = NO;
		rectSelecting = NO;
		framesPerSecond = 60;
        [self setCachedDots:[[[NSImage alloc] init] autorelease]];
	}
	return self;
}
- (void)dealloc
{
    [self setCachedDots:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUndoManagerDidUndoChangeNotification object:nil];
    
    [self removeObserver:self forKeyPath:@"dataSource"];
    
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUndo:) name:NSUndoManagerDidUndoChangeNotification object:nil];
    
    [self addObserver:self forKeyPath:@"dataSource" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
}

- (Frame *)currentFrame
{
	return [dataSource dmdView:self frameAtIndex:frameIndex];
}

- (void)setFrameIndex:(int)index
{
	frameIndex = index;
	[self setNeedsDisplayRefreshDots:YES];
}

- (void)setNeedsDisplayRefreshDots:(BOOL)flag
{
    refreshDots |= flag;
    [self setNeedsDisplay:YES];
}

- (void)updateFrameSize
{
    NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];
    NSRect newFrame = NSMakeRect(0, 0, frameSize.width * 8, frameSize.height * 8);
    [self setFrame:newFrame];
    [self setCachedDots:[[[NSImage alloc] initWithSize:newFrame.size] autorelease]];
    [self setNeedsDisplayRefreshDots:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"dataSource"])
    {
        // We are abusing the DMDViewDataSource protocol here, since we know it has a "size" key...
        if ([change objectForKey:NSKeyValueChangeOldKey] != [NSNull null])
            [[change objectForKey:NSKeyValueChangeOldKey] removeObserver:self forKeyPath:@"size"];
        [(id)[self dataSource] addObserver:self forKeyPath:@"size" options:0 context:nil];
        [self updateFrameSize];
    }
    else if (object == [self dataSource] && [keyPath isEqual:@"size"])
    {
        [self updateFrameSize];
    }
}

- (void)didUndo:(NSNotification*)notification
{
	[self setNeedsDisplayRefreshDots:YES];
}
- (BOOL)acceptsFirstResponder
{
	return YES;
}
- (BOOL)fitsFontCriteria
{
    NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];
    return [dataSource numberOfFramesInDmdView:self] == 2 && frameIndex == 0 && frameSize.width == frameSize.height;
}
- (void)showCursor:(bool)value
{
	if(value != cursorShown) {
		cursorShown = value;
		[self setNeedsDisplayRefreshDots:NO];
	}
}
- (void)moveCursorToPoint:(NSPoint)point
{
	if(!cursorShown) {
		cursorShown = YES;
		rectSelected = NO;
		rectSelecting = NO;
	}
	if (!NSEqualPoints(cursor, point)) {
        NSSize frameSize = [dataSource sizeOfFrameInDmdView:self];
		cursor.x = ((int)point.x) % (int)frameSize.width;
		cursor.y = ((int)point.y) % (int)frameSize.height;
		if(cursor.y < 0) {
			cursor.y = frameSize.height-1;
		}
		if(cursor.x < 0) {
			cursor.x = frameSize.width-1;
		}
	}
	[self setNeedsDisplayRefreshDots:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:DMDNotificationDotCursorMoved object:self userInfo:nil];
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
				[[NSNotificationCenter defaultCenter] postNotificationName:DMDNotificationDotCursorMoved object:self userInfo:nil];
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
		
		if(character == ' ') {
			if(!timer) {
				timer = [[NSTimer scheduledTimerWithTimeInterval: 1.0/(float)framesPerSecond target:self selector:@selector(tick:) userInfo:nil repeats:YES] retain];
			} else {
				[timer invalidate];
				[timer release];
				timer = nil;
			}
			continue;
		}
		
		NSLog(@"Unknown character: %C", character);
	}
	[self setNeedsDisplayRefreshDots:NO];
	[self updateWindowTitle];
}

#pragma mark -
#pragma mark Dots

- (void)setDot:(DMDDotState)state
{
	if(rectSelected) {
		[[self currentFrame] setDotsInRect:rectSelection toState:state];
	} else {
		[[self currentFrame] setDotAtPoint:cursor toState:state];
	}
	[self setNeedsDisplayRefreshDots:YES];
}
- (IBAction)dotClear:(id)sender { [self setDot:DMDDotClear]; }
- (IBAction)dotOff:(id)sender { [self setDot:DMDDotOff]; }
- (IBAction)dotLow:(id)sender { [self setDot:DMDDotLow]; }
- (IBAction)dotMedium:(id)sender { [self setDot:DMDDotMed]; }
- (IBAction)dotHigh:(id)sender { [self setDot:DMDDotHigh]; }

#pragma mark -
#pragma mark Frames

- (IBAction)frameNew:(id)sender
{
	if ([dataSource respondsToSelector:@selector(dmdView:insertFrame:atIndex:)])
	{
		Frame *frame = [[dataSource dmdView:self frameAtIndex:frameIndex] mutableCopy];
		[dataSource dmdView:self insertFrame:frame atIndex:frameIndex+1];
	}
	[self updateWindowTitle];
}
- (IBAction)framePrevious:(id)sender
{
	[self setFrameIndex:MAX(0, frameIndex - 1)];
	[self updateWindowTitle];
	[self setNeedsDisplayRefreshDots:YES];
}
- (IBAction)frameNext:(id)sender
{
	[self setFrameIndex:MIN([dataSource numberOfFramesInDmdView:self]-1, frameIndex + 1)];
	[self updateWindowTitle];
	[self setNeedsDisplayRefreshDots:YES];
}
- (IBAction)frameShiftRight:(id)sender
{
	if(rectSelected) {
		[[self currentFrame] shiftRect:rectSelection horizontal:1];
		rectSelection.origin.x++;
	} else {
		[[self currentFrame] shiftRight];
	}
	[self setNeedsDisplayRefreshDots:YES];
}
- (IBAction)frameShiftLeft:(id)sender
{
	if(rectSelected) {
		[[self currentFrame] shiftRect:rectSelection horizontal:-1];
		rectSelection.origin.x--;
	} else {
		[[self currentFrame] shiftLeft];
	}
	[self setNeedsDisplayRefreshDots:YES];
}
- (IBAction)frameShiftUp:(id)sender
{
	if(rectSelected) {
		[[self currentFrame] shiftRect:rectSelection vertical:-1];
		rectSelection.origin.y--;
	} else {
		[[self currentFrame] shiftUp];
	}
	[self setNeedsDisplayRefreshDots:YES];
}
- (IBAction)frameShiftDown:(id)sender
{
	if(rectSelected) {
		[[self currentFrame] shiftRect:rectSelection vertical:1];
		rectSelection.origin.y++;
	} else {
		[[self currentFrame] shiftDown];
	}
	[self setNeedsDisplayRefreshDots:YES];
}

// Clipboard
- (void)copy:(id)sender
{
	if(rectSelected) {
        Frame *frame = [[self currentFrame] frameWithRect:rectSelection];
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
    [[self currentFrame] setDotsFromFrame:frame sourceOrigin:sourceOrigin destOrigin:destOrigin size:size];
	[self setNeedsDisplayRefreshDots:YES];
}

- (void)updateWindowTitle
{
	NSString* filename = [[self window] representedFilename];
	if([filename length] == 0) {
		filename = @"Untitled";
	}
	[[self window] setTitle: [NSString stringWithFormat:@"%@ - %d/%d", 
		[filename lastPathComponent], frameIndex+1, [dataSource numberOfFramesInDmdView:self]]];
}
- (NSPoint)pointToDot:(NSPoint)point
{
    return NSMakePoint(floor(point.x / dotSize), floor(point.y / dotSize));
}
- (void)mouseMoved:(NSEvent*)event
{
	NSPoint localPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	if(NSPointInRect(localPoint, NSIntersectionRect([self bounds], [[self superview] bounds]))) {
		[self moveCursorToPoint:[self pointToDot:localPoint]];
		[NSCursor setHiddenUntilMouseMoves:YES];
	} else {
		// mouse has left the view
		[self showCursor:NO];
	}
}
- (void)mouseDragging:(NSEvent*)event
{
	
}
-(void)mouseDown:(NSEvent*)event
{
	NSPoint localPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	//NSLog(@"mouseUp: %f, %f -> %d, %d)", localPoint.x, localPoint.y, col, row);
	NSPoint dotPos = [self pointToDot:localPoint];
	Frame* frame = [self currentFrame];
	DMDDotState state = [[DMDPaletteController sharedController] selectedColor];
	[frame setDotAtPoint:dotPos toState:state];
	[self setNeedsDisplayRefreshDots:YES];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent; 
{
	return YES; 
}

- (void)resetCursorRects
{
	//[self addCursorRect:[self visibleRect] cursor: nil]; //[NSCursor crosshairCursor]];
}

- (void)renderDotsFromFrame:(Frame *)frame toImage:(NSImage *)image inRect:(NSRect)rect
{
    [image lockFocus];
	[frame drawDotsInRect:rect dotSize:dotSize displayMode:displayMode];
    [image unlockFocus];
}

- (void)drawRect:(NSRect)rect
{
	int row, col;
    
	[[NSColor blackColor] set];
	NSRectFill(rect);

	Frame* frame = [self currentFrame];
	if(frame == nil)
		return;

    int y0 = ((int)rect.origin.y)/dotSize;
	int x0 = ((int)rect.origin.x)/dotSize;
	int yCount = MIN(1 + ((int)rect.size.height)/dotSize, [frame height]);
	int xCount = MIN(1 + ((int)rect.size.width)/dotSize, [frame width]);
    
    if (refreshDots)
    {
        [self renderDotsFromFrame:frame toImage:cachedDots inRect:rect];
		[[NSNotificationCenter defaultCenter] postNotificationName:DMDNotificationRefreshedDots object:self];
        refreshDots = NO;
    }
    [cachedDots drawInRect:rect fromRect:rect operation:NSCompositeCopy fraction:1.0];
    

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
	[self setFrameIndex:frameIndex + 1];
	if (frameIndex == [dataSource numberOfFramesInDmdView:self])
		[self setFrameIndex:0];
	[self updateWindowTitle];
	[self setNeedsDisplayRefreshDots:YES];
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
    [self setNeedsDisplayRefreshDots:NO];
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
    [self setNeedsDisplayRefreshDots:YES];
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
    [self setNeedsDisplayRefreshDots:NO];
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
        [self setNeedsDisplayRefreshDots:NO];
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
