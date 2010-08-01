//
//  CSMapRouteLayerView.h
//  mapLines
//
//  Created by Craig on 4/12/09.
//  Copyright Craig Spitzkoff 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CSMapRouteLayerView : UIView
{
	MKMapView* _mapView;
	NSMutableArray* _points;
	UIColor* _lineColor;
	CGFloat _lineWidth;
}

- (id)initWithRoute:(NSMutableArray*)routePoints mapView:(MKMapView*)mapView;

@property (nonatomic, retain) NSMutableArray* points;
@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) UIColor* lineColor; 
@property (assign) CGFloat lineWidth;

- (void)updateRegion;
- (void)appendPoint:(CLLocation *)lastPoint;

@end

/*
 Example of use:
 
 routeView = [[CSMapRouteLayerView alloc] initWithRoute:points mapView:_mapView];
 */
