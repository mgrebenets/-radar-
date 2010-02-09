//
//  CutView.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CutView.h"
#import <QuartzCore/QuartzCore.h>

#define	kHorizontalScanImageName	@"5_cut_static.png"
#define kRadarScanImageName	@"cut_sector.png"

#define kCircleScanTimeInterval	(0.05f)
#define kMaxCircleDiameter	(440)
#define kCircleDiameterDelta	(1)
#define kCircleScanWidth	(5)

@interface CutView ()
- (void)detachTimerCreate:(id)val;
- (void)detachTimerStop:(id)val;
- (void)updateTimerFire:(NSTimer *)timer;
- (void)clearCircleScan;
@end


@implementation CutView

@synthesize cutViewType;

- (void)setCutViewType:(NSInteger)type {
	cutViewType = type;
	switch (cutViewType) {
		case CutViewTypeHorizontalScan:
			cutImageView.image = [UIImage imageNamed:kHorizontalScanImageName];
			cutImageView.hidden = NO;
			[self clearCircleScan];
			break;
		case CutViewTypeRadarScan:
			cutImageView.image = [UIImage imageNamed:kRadarScanImageName];
			cutImageView.hidden = NO;
			[self clearCircleScan];			
			break;
		case CutViewTypeCircleScan:
			// don't hide image view immediately, it will reveal answer before first draw occurs
			[self setNeedsDisplay];			
			break;
		default:
			break;
	}
}

- (id)initWithFrame:(CGRect)frame {
	NSLog(@"%s", _cmd);
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.cutViewType = CutViewTypeRadarScan;
    }
    return self;
}

- (void)detachTimerCreate:(id)val {

}

- (void)detachTimerStop:(id)val {

}

- (void)updateTimerFire:(NSTimer *)timer {
//	NSLog(@"%s", _cmd);
	circleDiameter += kCircleDiameterDelta;
	if (circleDiameter > kMaxCircleDiameter) {
		circleDiameter = 0.0f;
	}
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	if (cutViewType != CutViewTypeCircleScan) return;
	
    // Drawing code
//	NSLog(@"%s", _cmd);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	if (needsClear) {	
		CGContextRestoreGState(ctx);
		CGContextClearRect(ctx, rect);
		needsClear = NO;
		return;
	}
	
	CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
	CGContextFillRect(ctx, rect);
	
	if (!cutImageView.hidden) cutImageView.hidden = YES;
	
	CGRect cRect = CGRectMake(160 - circleDiameter / 2, 240 - circleDiameter / 2, circleDiameter, circleDiameter);
	CGContextAddEllipseInRect(ctx, cRect);
	CGContextClip(ctx);
	CGContextClearRect(ctx, cRect);
	
	CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
	cRect = CGRectMake(cRect.origin.x + kCircleScanWidth, 
					   cRect.origin.y + kCircleScanWidth, 
					   cRect.size.width - kCircleScanWidth * 2, 
					   cRect.size.height - kCircleScanWidth * 2);
	CGContextFillEllipseInRect(ctx, cRect);

}

- (void)clearCircleScan {
	needsClear = TRUE;
	[self setNeedsDisplay];
}


- (void)dealloc {
	[updateTimer release];
    [super dealloc];
}

#define kScanningAnimationKey	@"kScanningAnimationKey"
#define kScanningAnimationDuration  (5.0f)


- (void)startAnimation {
	switch (cutViewType) {
		case CutViewTypeHorizontalScan:
			// nothing, in this case the image itself must be moving
			break;
		case CutViewTypeRadarScan:
		{
			// 360 degrees rotation
			CABasicAnimation *animation;
			animation = [CABasicAnimation animationWithKeyPath:@"transform"];
			animation.duration = kScanningAnimationDuration;
			animation.repeatCount = HUGE_VALF;
			animation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateZ];
			animation.fromValue = [NSNumber numberWithFloat:0];
			animation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
			[[cutImageView layer] addAnimation:animation forKey:kScanningAnimationKey];				
			break;
		}
		case CutViewTypeCircleScan:
			if (!updateTimer) {
//				[NSThread detachNewThreadSelector:@selector(detachTimerCreate:) toTarget:self withObject:nil];
				updateTimer = [[NSTimer timerWithTimeInterval:kCircleScanTimeInterval target:self selector:@selector(updateTimerFire:) userInfo:nil repeats:YES] retain];
//				[[NSRunLoop new] addTimer:updateTimer forMode:NSDefaultRunLoopMode];
				[[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSDefaultRunLoopMode];				
				//updateTimer = [[NSTimer scheduledTimerWithTimeInterval:kCircleScanTimeInterval target:self selector:@selector(updateTimerFire:) userInfo:nil repeats:YES] retain];
				//[updateTimer fire];
			}			
			break;
		default:
			break;
	}
}

- (void)stopAnimation {
	switch (cutViewType) {
		case CutViewTypeHorizontalScan:
			// nothing, in this case the image itself must be moving and stopping
			break;
		case CutViewTypeRadarScan:
			[[cutImageView layer] removeAnimationForKey:kScanningAnimationKey];			
			break;
		case CutViewTypeCircleScan:
			if (updateTimer) {
				[updateTimer invalidate];
				[updateTimer release];
				updateTimer = nil;
			}
			break;
		default:
			break;
	}	
}

@end
