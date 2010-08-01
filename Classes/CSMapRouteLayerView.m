//
//  CSMapRouteLayerView.m
//  mapLines
//
//  Created by Craig on 4/12/09.
//  Copyright Craig Spitzkoff 2009. All rights reserved.
//

#import "CSMapRouteLayerView.h"

@implementation CSMapRouteLayerView
@synthesize mapView   = _mapView;
@synthesize points    = _points;
@synthesize lineColor = _lineColor; 
@synthesize lineWidth = _lineWidth;

- (id)initWithRoute:(NSMutableArray*)routePoints mapView:(MKMapView*)mapView {
	self = [super initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
    [self setLineWidth:5.0f]; // Like google Map Directions
	[self setBackgroundColor:[UIColor clearColor]];
	
	[self setMapView:mapView];
	[self setPoints:routePoints];
	
    [self updateRegion];
    
	[self setUserInteractionEnabled:NO];
	[self.mapView addSubview:self];
		
	return self;
}

- (void)appendPoint:(CLLocation *)lastPoint {
    [self.points addObject:lastPoint];
    //[self updateRegion];
    [self setNeedsDisplay];
}

- (void)updateRegion {
    if ([self.points count] > 0) {
     
        // determine the extents of the trip points that were passed in, and zoom in to that area. 
        CLLocationDegrees maxLat = -90;
        CLLocationDegrees maxLon = -180;
        CLLocationDegrees minLat = 90;
        CLLocationDegrees minLon = 180;
        
        for(int idx = 0; idx < self.points.count; idx++) {
            CLLocation* currentLocation = [self.points objectAtIndex:idx];
            if(currentLocation.coordinate.latitude > maxLat) {
                maxLat = currentLocation.coordinate.latitude;
            }
            if(currentLocation.coordinate.latitude < minLat) {
                minLat = currentLocation.coordinate.latitude;
            }
            if(currentLocation.coordinate.longitude > maxLon) {
                maxLon = currentLocation.coordinate.longitude;
            }
            if(currentLocation.coordinate.longitude < minLon) {
                minLon = currentLocation.coordinate.longitude;
            }
        }
        
        MKCoordinateRegion region;
        region.center.latitude = (maxLat + minLat) / 2;
        region.center.longitude = (maxLon + minLon) / 2;
        region.span.latitudeDelta = maxLat - minLat;
        region.span.longitudeDelta = maxLon - minLon;
        
        [self.mapView setRegion:region];
    }
}

- (void)drawRect:(CGRect)rect {
	// only draw our lines if we're not int he moddie of a transition and we 
	// acutally have some points to draw. 
	if(!self.hidden && nil != self.points && self.points.count > 0) {
		CGContextRef context = UIGraphicsGetCurrentContext(); 
		
		if(nil == self.lineColor) {
            self.lineColor = [UIColor blueColor]; // setting the property instead of the member variable will automatically reatin it.
        }
		
		CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
		CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);

		CGContextSetLineWidth(context, self.lineWidth);
        CGContextSetLineCap(context, kCGLineCapRound);
        
		for(int idx = 0; idx < self.points.count; idx++) {
			CLLocation* location = [self.points objectAtIndex:idx];
			CGPoint point = [_mapView convertCoordinate:location.coordinate toPointToView:self];
			
			if(idx == 0) {
				// move to the first point
				CGContextMoveToPoint(context, point.x, point.y);
			} else {
				CGContextAddLineToPoint(context, point.x, point.y);
			}
		}
		
		CGContextStrokePath(context);
	}
}

- (void) dealloc {
	[_points release];
	[_mapView release];
	[_lineColor release];
	[super dealloc];
}

@end
