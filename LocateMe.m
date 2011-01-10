//
//  LocateMe.m
//
//  Created by Robert Harder on 10/22/10.
//  Copyright 2010 Robert Harder. All rights reserved.
//

#import "LocateMe.h"


/**
 * Small and simple main method.
 */
int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    LocateMe *loc = [[[LocateMe alloc] init] retain];
    
    do {} 
    while ( [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]] && !loc.goodLocationFound );   
    
	
    [loc release];
    
    [pool drain];
    return 0;
}



@implementation LocateMe

@synthesize goodLocationFound;
@synthesize bestEffortAtLocation;


-(id) init {
    if( self = [super init] ){
        locationMeasurements = [[[NSMutableArray alloc] init] retain];
        locationManager = [[[CLLocationManager alloc] init] retain];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;    
        locationManager.distanceFilter = 10;
        [locationManager startUpdatingLocation];
    }
    return self;
}



-(void) dealloc {
    [locationManager release];
    [locationMeasurements release];
    
    [super dealloc];
}


-(void) stopUpdatingLocation{
    [locationManager stopUpdatingLocation];
    printf( "%s\n", [[self.bestEffortAtLocation description] UTF8String] );
    self.goodLocationFound = YES;
}

#pragma mark -
#pragma mark Location Manager Interactions 



- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    
    // store all of the measurements, just so we can see what kind of data we might receive
    [locationMeasurements addObject:newLocation];
    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 15.0) {
        return;
    }
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0){
        return;
    }
    
    // test the measurement to see if it is more accurate than the previous measurement
    if (self.bestEffortAtLocation == nil || self.bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        
        // store the location as the "best effort"
        self.bestEffortAtLocation = newLocation;
        
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue 
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of 
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            // we have a measurement that meets our requirements, so we can stop updating the location
            // 
            [self stopUpdatingLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a 
    // timeout that will stop the location manager to save power.
    if ([error code] != kCLErrorLocationUnknown) {
        NSLog(@"[error code] != kCLErrorLocationUnknown: %@", error);
    }
    NSLog(@"Error: %@", error);
}




@end
