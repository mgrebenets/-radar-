//
//  TouchView.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TouchView.h"


@implementation TouchView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	if ([viewCtl.soundButton hitTest:[touch locationInView:viewCtl.soundButton] withEvent:event]) {
		[viewCtl soundAction:self];
		return;
	}
	[viewCtl tapAction:self];
}

@end
