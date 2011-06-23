//
//  LocateMe.h
//
//  Created by Robert Harder on 10/22/10.
//  Copyright 2010 Robert Harder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>
#import <stdio.h>


BOOL g_verbose = NO;
NSString *VERSION = @"0.2";
NSString *GOOGLE_URL_FORMAT = @"http://maps.google.com/maps?q={LAT},{LON}({HOST},+{TIME})&ie=UTF8&ll={LAT},{LON}&t=roadmap&z=14&iwloc=A&mrt=loc";
NSString *LONG_FORMAT = @"Latitude: {LAT}\nLongitude: {LON}\nAltitude (m): {ALT}\nSpeed (m/s): {SPD}\nDirection: {DIR}\nHorizontal Accuracy (m): {HAC}\nVertical Accuracy (m): {VAC}\nTimestamp: {TIME}\nHostname: {HOST}";


@interface LocateMe : NSObject <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    NSMutableArray *locationMeasurements;
    
    CLLocation * bestEffortAtLocation;
    NSString *userFormat;
    BOOL goodLocationFound;
    BOOL outputAsGoogleURL;
}

@property (nonatomic) BOOL goodLocationFound;
@property (nonatomic) BOOL outputAsGoogleURL;
@property (nonatomic, retain) NSString *userFormat;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;

-(id) init;
-(void) dealloc;
-(void) stopUpdatingLocation;
-(void) outputLocation:(CLLocation *) loc asGoogleURL:(BOOL) asGoogle;



@end
