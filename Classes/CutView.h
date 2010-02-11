//
//  CutView.h
//  iScanner
//
//  Created by Maksym Grebenets on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum _CutViewType {
	CutViewTypeHorizontalScan,
	CutViewTypeRayScan,
	CutViewTypeDrawnConcentricScan,
	CutViewTypeImageConcentricScan,
};

@interface CutView : UIView {
	NSInteger cutViewType;
	IBOutlet UIImageView *cutImageView;
	NSTimer *updateTimer;
	CGFloat circleDiameter;
	BOOL needsClear;
}

- (void)startAnimation;
- (void)stopAnimation;

@property NSInteger cutViewType;

@end
