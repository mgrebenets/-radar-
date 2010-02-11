//
//  CutView.m
//  iScanner
//
//  Created by Maksym Grebenets on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CutView.h"
#import <QuartzCore/QuartzCore.h>

// horizontal scan image
#define	kHorizontalScanImageName	@"5_cut_static.png"

// ray scan image
#define kRayScanImageName	@"cut_sector.png"

// drawn concentric scan
#define kDrawnConcentricScanTimerInterval	(0.05f)
#define kDrawnConcentricScanMaxDiameter	(440)
#define kDrawnConcentricScanDiameterDelta	(1)
#define kDrawnConcentricScanWidth	(5)

// image concentric scan
#define kImageConcentricScanInitialFrame    CGRectMake(160, 240, 480, 480)
#define kImageConcentricScanFinalFrame      CGRectMake(0, 0, 0, 0)

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
		case CutViewTypeRayScan:
			cutImageView.image = [UIImage imageNamed:kRayScanImageName];
			cutImageView.hidden = NO;
			[self clearCircleScan];			
			break;
		case CutViewTypeDrawnConcentricScan:
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
		self.cutViewType = CutViewTypeRayScan;
    }
    return self;
}

- (void)detachTimerCreate:(id)val {
	// doesn't work (thread dies, so does its run loop)
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	updateTimer = [[NSTimer scheduledTimerWithTimeInterval:kDrawnConcentricScanTimerInterval target:self selector:@selector(updateTimerFire:) userInfo:nil repeats:YES] retain];
	[updateTimer fire];
	[pool release];
}

- (void)detachTimerStop:(id)val {

}

- (void)updateTimerFire:(NSTimer *)timer {
//	NSLog(@"%s", _cmd);
	circleDiameter += kDrawnConcentricScanDiameterDelta;
	if (circleDiameter > kDrawnConcentricScanMaxDiameter) {
		circleDiameter = 0.0f;
	}
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	if (cutViewType != CutViewTypeDrawnConcentricScan) return;
	
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
	cRect = CGRectMake(cRect.origin.x + kDrawnConcentricScanWidth, 
					   cRect.origin.y + kDrawnConcentricScanWidth, 
					   cRect.size.width - kDrawnConcentricScanWidth * 2, 
					   cRect.size.height - kDrawnConcentricScanWidth * 2);
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
#define kScanningAnimationDuration  (8.0f)


- (void)startAnimation {
	switch (cutViewType) {
		case CutViewTypeHorizontalScan:
			// nothing, in this case the image itself must be moving
			break;
		case CutViewTypeRayScan:
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
		case CutViewTypeDrawnConcentricScan:
			if (!updateTimer) {
//				[NSThread detachNewThreadSelector:@selector(detachTimerCreate:) toTarget:self withObject:nil];
//				updateTimer = [[NSTimer timerWithTimeInterval:kDrawnConcentricScanTimerInterval target:self selector:@selector(updateTimerFire:) userInfo:nil repeats:YES] retain];
//				[[NSRunLoop new] addTimer:updateTimer forMode:NSDefaultRunLoopMode];
//				[[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSDefaultRunLoopMode];				
				updateTimer = [[NSTimer scheduledTimerWithTimeInterval:kDrawnConcentricScanTimerInterval target:self selector:@selector(updateTimerFire:) userInfo:nil repeats:YES] retain];
				[updateTimer fire];
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
		case CutViewTypeRayScan:
			[[cutImageView layer] removeAnimationForKey:kScanningAnimationKey];			
			break;
		case CutViewTypeDrawnConcentricScan:
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
