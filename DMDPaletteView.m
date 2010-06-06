//
//  DMDPaletteView.m
//  DMDAnimator
//
//  Created by Adam Preble on 6/5/10.
//  Copyright 2010 Big Nerd Ranch. All rights reserved.
//

#import "DMDPaletteView.h"
#import "Frame+Drawing.h"

@implementation DMDPaletteView

- (void)dealloc
{
	[paletteFrame release];
	[super dealloc];
}

- (void)awakeFromNib
{
	const char dotData[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
	paletteFrame = [[Frame alloc] initWithSize:NSMakeSize(4, 4) dots:dotData document:nil];
}

- (void)setSelectedColor:(uint8_t)color
{
	selectedColor = color;
	[self setNeedsDisplay:YES];
}
- (uint8_t)selectedColor
{
	return selectedColor;
}

- (int)dotSize
{
	return NSWidth([self bounds])/4.0;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	int dotSize = [self dotSize];
	[paletteFrame drawDotsInRect:[self bounds] dotSize:dotSize displayMode:DMDDisplayModeRounded];
	[[NSColor lightGrayColor] set];
	int x = selectedColor % 4;
	int y = selectedColor / 4;
	NSRect selectionRect = NSMakeRect(x * dotSize, y * dotSize, dotSize, dotSize);
	NSFrameRect(selectionRect);
	//NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:round(0.45*(float)dotSize) yRadius:round(0.45*(float)dotSize)];
	//[path stroke];
}

// These calls (shouldDelayWindowOrderingForEvent, acceptsFirstMouse, and preventWindowOrdering
// are used to prevent the palette from coming to the foreground when the user selects a color.
// http://www.cocoadev.com/index.pl?PreventWindowOrdering

- (BOOL)shouldDelayWindowOrderingForEvent:(NSEvent *)theEvent; 
{
	return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent; 
{
	return YES; 
}

- (void)mouseDown:(NSEvent *)event
{
	[NSApp preventWindowOrdering]; 
	
	NSPoint localPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	int dotSize = [self dotSize];
	selectedColor = ((int)localPoint.x/dotSize) + ((int)localPoint.y/dotSize) * 4;
	[self setNeedsDisplay:YES];
}
@end
