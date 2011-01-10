//
//  LocateMe.h
//
//  Created by Robert Harder on 10/22/10.
//  Copyright 2010 Robert Harder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>
#import <stdio.h>

@interface LocateMe : NSObject <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    NSMutableArray *locationMeasurements;
    
    CLLocation * bestEffortAtLocation;
    BOOL goodLocationFound;
}

@property (nonatomic) BOOL goodLocationFound;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;

-(id) init;
-(void) dealloc;
-(void) stopUpdatingLocation;



@end
