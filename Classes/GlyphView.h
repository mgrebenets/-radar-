//
//  GlyphView.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/14/10.
//  Copyright 2010 i4nApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface GlyphView : UILabel {
	float animationDuration;
	BOOL stopAnimations;
	CAAnimationGroup *moveAnimationGroup;
}

- (void)startAnimating;
- (void)stopAnimating;

@end
