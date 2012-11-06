//
//  CPTScatterBYPlotWithGap.m
//  CorePlot-CocoaTouch
//
//  Created by myeyesareblind on 11/5/12.
//
//

#import "CPTScatterPlotWithGap.h"
#import "CPTScatterPlot.h"

#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTLegend.h"
#import "CPTLineStyle.h"
#import "CPTMutableNumericData.h"
#import "CPTNumericData.h"
#import "CPTPathExtensions.h"
#import "CPTPlotArea.h"
#import "CPTPlotSpace.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTPlotSymbol.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "NSCoderExtensions.h"
#import "NSNumberExtensions.h"
#import <stdlib.h>

@interface CPTScatterPlotWithGap ()

@property (retain) NSArray* gapArray;

@end


@implementation CPTScatterPlotWithGap

@synthesize gapArray, gapDataSource;


- (id) initWithFrame:(CGRect)newFrame {
    self = [super initWithFrame:newFrame];
    if (self) {
        self.gapArray = NULL;
    }
    return self;
}


- (id) initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    if (self) {
        self.gapDataSource = NULL;
        self.gapArray = NULL;
    }
    return self;
}


- (void) dealloc {
    
    [self.gapArray release];
    
    [super dealloc];
    
}


- (void) reloadDataInIndexRange:(NSRange)indexRange {
    [super reloadDataInIndexRange:indexRange];
    
    if (self.gapDataSource) {
        if ([self.gapDataSource respondsToSelector:@selector(gapArrayForPlot:)]) {
            self.gapArray = [self.gapDataSource gapArrayForPlot:self];
        }
    }
}


-(CGPathRef)newDataLinePathForViewPoints:(CGPoint *)viewPoints indexRange:(NSRange)indexRange baselineYValue:(CGFloat)baselineYValue
{
	CGMutablePathRef dataLinePath				 = CGPathCreateMutable();
	CPTScatterPlotInterpolation theInterpolation = self.interpolation;
	BOOL lastPointSkipped						 = YES;
	CGFloat firstXValue							 = 0.0;
	CGFloat lastXValue							 = 0.0;
	NSUInteger lastDrawnPointIndex				 = NSMaxRange(indexRange);
    
	for ( NSUInteger i = indexRange.location; i <= lastDrawnPointIndex; i++ ) {
		CGPoint viewPoint = viewPoints[i];
        
		if ( isnan(viewPoint.x) || isnan(viewPoint.y) ) {
			if ( !lastPointSkipped ) {
				if ( !isnan(baselineYValue) ) {
					CGPathAddLineToPoint(dataLinePath, NULL, lastXValue, baselineYValue);
					CGPathAddLineToPoint(dataLinePath, NULL, firstXValue, baselineYValue);
					CGPathCloseSubpath(dataLinePath);
				}
				lastPointSkipped = YES;
			}
		}
		else {
			if ( lastPointSkipped ) {
				CGPathMoveToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
				lastPointSkipped = NO;
				firstXValue		 = viewPoint.x;
			}
			else {
				switch ( theInterpolation ) {
					case CPTScatterPlotInterpolationLinear:
                    {
                        BOOL shouldSkipPoint = NO;
                        if (self.gapArray.count) {
                            for (NSNumber* n in gapArray) {
                                NSUInteger gapIndex = [n unsignedIntegerValue];
                                gapIndex ++; /// skip the connection to the next point
                                if (gapIndex == i) {
                                    shouldSkipPoint = YES;
                                    break;
                                }
                            }
                        }
                        if (shouldSkipPoint) {
                            CGPathMoveToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
                        }
                        else {
                            CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
                        }
                    }
						break;
                        
					case CPTScatterPlotInterpolationStepped:
						CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoints[i - 1].y);
						CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
						break;
                        
					case CPTScatterPlotInterpolationHistogram:
					{
						CGFloat x = (viewPoints[i - 1].x + viewPoints[i].x) / (CGFloat)2.0;
						CGPathAddLineToPoint(dataLinePath, NULL, x, viewPoints[i - 1].y);
						CGPathAddLineToPoint(dataLinePath, NULL, x, viewPoint.y);
						CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
					}
                        break;
                        
					default:
						[NSException raise:CPTException format:@"Interpolation method not supported in scatter plot."];
						break;
				}
			}
			lastXValue = viewPoint.x;
		}
	}
    
	if ( !lastPointSkipped && !isnan(baselineYValue) ) {
		CGPathAddLineToPoint(dataLinePath, NULL, lastXValue, baselineYValue);
		CGPathAddLineToPoint(dataLinePath, NULL, firstXValue, baselineYValue);
		CGPathCloseSubpath(dataLinePath);
	}
    
	return dataLinePath;
}

@end
