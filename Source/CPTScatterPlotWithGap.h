//
//  CPTScatterBYPlotWithGap.h
//  CorePlot-CocoaTouch
//
//  Created by myeyesareblind on 11/5/12.
//
//

#import "CPTScatterPlot.h"


@protocol CPTPlotGapDataSource <NSObject>
@required
/// NSArray of Numbers with NSIntegers as values
- (NSArray*) gapArrayForPlot: (CPTPlot*) plot;

@end


/// Purpose: create gaps while in CPTScatterPlotInterpolationLinear interpolation
/// no caching provided

@interface CPTScatterPlotWithGap : CPTScatterPlot

@property (nonatomic, readwrite, assign) id <CPTPlotGapDataSource> gapDataSource;

@end
