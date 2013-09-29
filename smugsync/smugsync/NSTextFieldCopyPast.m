//
//  NSTextFieldCopyPast.m
//  smugsync
//
//  Created by Shane Dickson on 9/28/13.
//  Copyright (c) 2013 Shane Dickson. All rights reserved.
//

#import "NSTextFieldCopyPast.h"

@implementation NSTextFieldCopyPast

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}


- (BOOL)performKeyEquivalent:(NSEvent *)event { if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask)
{ // The command key is the ONLY modifier key being pressed.
    if ([[event charactersIgnoringModifiers] isEqualToString:@"x"])
    { return [NSApp sendAction:@selector(cut:) to:[[self window] firstResponder] from:self];
    }
    else if ([[event charactersIgnoringModifiers] isEqualToString:@"c"])
    { return [NSApp sendAction:@selector(copy:) to:[[self window] firstResponder] from:self];
    } else if ([[event charactersIgnoringModifiers] isEqualToString:@"v"])
    {
        return [NSApp sendAction:@selector(paste:) to:[[self window] firstResponder] from:self];
    }
    else if ([[event charactersIgnoringModifiers] isEqualToString:@"a"])
    { return [NSApp sendAction:@selector(selectAll:) to:[[self window] firstResponder] from:self];
    }
}
    return [super performKeyEquivalent:event];
}
    
    
@end
