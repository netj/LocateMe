//
//  LocateMe.m
//
//  Created by Robert Harder on 10/22/10.
//  Copyright 2010 Robert Harder. All rights reserved.
//

#import "LocateMe.h"

int processArguments(int argc, const char * argv[]);
void printUsage(int argc, const char * argv[]);

/**
 * Small and simple main method.
 */
int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    
    int result = processArguments(argc, argv);
    
    [pool drain];
    return result;
}



/**
 * Process command line arguments and execute program.
 */
int processArguments(int argc, const char * argv[] ){
	
    NSString *userFormat = nil;
    
    
	int i;
	for( i = 1; i < argc; ++i ){
		
		// Handle command line switches
		if (argv[i][0] == '-') {
            
            // Dash only? Not allowed
            if( argv[i][1] == 0 ){
                printf("Option not understood: -\n");
                printUsage( argc, argv );
                return 1;
            } else {
                
                // Which switch was given
                switch (argv[i][1]) {
                        
                        // Help
                    case '?':
                    case 'h':
                        printUsage( argc, argv );
                        return 0;
                        break;
                        
                        
                        // Verbose
                    case 'v':
                        g_verbose = YES;
                        break;
                        
                        
                        // Output as a Google Map URL
                    case 'g': 
                        userFormat = GOOGLE_URL_FORMAT;
                        break;
                        
                        // Output as a long multiline format
                    case 'l': 
                        userFormat = LONG_FORMAT;
                        break;
                        
                        // Output with user-defined format
                    case 'f':
                        if( i+1 < argc ){
                            userFormat = [NSString stringWithUTF8String:argv[++i]];
                        } else {
                            printf("No format supplied with option: -f\n");
                            printUsage( argc, argv );
                            return 3;
                        }
                        break;
                        
                    default:
                        printf("Option not understood: %s\n",argv[i]);
                        printUsage( argc, argv );
                        return 2;
                }	// end switch: flag value
            }   // end else: not dash only
		}	// end if: '-'
        
        // Else no dash
		else {
			// Ignore options w/o dashes?
		}
        
	}	// end for: each command line argument
	
    
    LocateMe *loc = [[[LocateMe alloc] init] retain];
    
    if( userFormat != nil ){
        loc.userFormat = userFormat;
    }

    do {} 
    while ( [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]] && !loc.goodLocationFound );   
    [loc release];
    
    
    return 0;
}



void printUsage(int argc, const char * argv[]){
    printf( "USAGE: %s [options]\n", [[[NSString stringWithUTF8String:argv[0]] lastPathComponent] UTF8String] );
    printf( "Version: %s\n", [VERSION UTF8String] );
    printf( "Outputs your current location using Apple's geolocation services.\n" );
    printf( "  -h          This help message\n" );
//    printf( "  -v          Verbose mode\n");
    printf( "  -g          Generate a Google Map URL\n" );
    printf( "  -l          Generate long, multiline format\n" );
    printf( "  -f format   Generate a custom output with the following placeholders\n" );
    printf( "     {LAT}    Latitude as a floating point number\n" );
    printf( "     {LON}    Longitude as a floating point number\n" );
    printf( "     {ALT}    Altitude in meters as a floating point number\n" );
    printf( "     {SPD}    Speed in meters per second as a floating point number\n" );
    printf( "     {DIR}    Direction in degrees from true north as a floating point number\n" );
    printf( "     {HAC}    Horizontal accuracy in meters as a floating point number\n" );
    printf( "     {VAC}    Vertical accuracy in meters as a floating point number\n" );
    printf( "     {TIME}   Timestamp (with date) of the location fix\n" );
    printf( "     {HOST}   Computer hostname\n" );
    printf( "\nExamples:\n\n" );
    printf( " Command: %s -f \"lat={LAT},lon={LON}\"\n", [[[NSString stringWithUTF8String:argv[0]] lastPathComponent] UTF8String] );
    printf( " Output : lat=12.34567,lon=98.76543\n" );
    printf( "\n ");
    printf( "Command: %s -f \"<lat>{LON}</lat><lon>{LON}</lon><alt>{ALT}</alt>\"\n", [[[NSString stringWithUTF8String:argv[0]] lastPathComponent] UTF8String] );
    printf( " Output : <lat>12.34567</lat><lon>98.76543</lon><alt>123</alt>\n" );
}





@implementation LocateMe

@synthesize goodLocationFound;
@synthesize outputAsGoogleURL;
@synthesize bestEffortAtLocation;
@synthesize userFormat;


-(id) init {
    self = [super init];
    if( self ){
        goodLocationFound = FALSE;
        outputAsGoogleURL = FALSE;
        userFormat = nil;
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
    //printf( "%s\n", [[self.bestEffortAtLocation description] UTF8String] );
    self.goodLocationFound = YES;
    [self outputLocation:self.bestEffortAtLocation asGoogleURL:self.outputAsGoogleURL];
}

-(NSString *)urlencode:(NSString *)raw{
    NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                   NULL,
                                                                                   (CFStringRef)raw,
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8 );
    return encodedString;
}

-(void) outputLocation:(CLLocation *) loc asGoogleURL:(BOOL) asGoogle{
    
    if( self.userFormat == nil ){
        printf( "%s\n", [[loc description] UTF8String] );
    } else {
        NSMutableString *format = [userFormat mutableCopy];
        
        [format replaceOccurrencesOfString:@"{LAT}" withString:[NSString stringWithFormat:@"%f", loc.coordinate.latitude] options:0 range:NSMakeRange(0, [format length])];
        [format replaceOccurrencesOfString:@"{LON}" withString:[NSString stringWithFormat:@"%f", loc.coordinate.longitude] options:0 range:NSMakeRange(0, [format length])];
        [format replaceOccurrencesOfString:@"{ALT}" withString:[NSString stringWithFormat:@"%f", loc.altitude] options:0 range:NSMakeRange(0, [format length])];
        [format replaceOccurrencesOfString:@"{SPD}" withString:[NSString stringWithFormat:@"%f", loc.speed] options:0 range:NSMakeRange(0, [format length])];
        [format replaceOccurrencesOfString:@"{DIR}" withString:[NSString stringWithFormat:@"%f", loc.course] options:0 range:NSMakeRange(0, [format length])];
        [format replaceOccurrencesOfString:@"{HAC}" withString:[NSString stringWithFormat:@"%f", loc.horizontalAccuracy] options:0 range:NSMakeRange(0, [format length])];
        [format replaceOccurrencesOfString:@"{VAC}" withString:[NSString stringWithFormat:@"%f", loc.verticalAccuracy] options:0 range:NSMakeRange(0, [format length])];
        [format replaceOccurrencesOfString:@"{TIME}" withString:[loc.timestamp description] options:0 range:NSMakeRange(0, [format length])];
        [format replaceOccurrencesOfString:@"{HOST}" withString:[[NSHost currentHost] name] options:0 range:NSMakeRange(0, [format length])];
        
        printf( "%s\n", [format UTF8String] );
    }
    /*
    if( asGoogle ){
        NSString *gurl = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f(%@,+%@)&ie=UTF8&ll=%f,%f&t=roadmap&z=14&iwloc=A&mrt=loc",
                          loc.coordinate.latitude,
                          loc.coordinate.longitude,
                          [self urlencode:[[NSHost currentHost] name]],
                          [self urlencode:[loc.timestamp description]],   
                          loc.coordinate.latitude,
                          loc.coordinate.longitude
                          ];
        printf( "%s\n", [gurl UTF8String] );

    } else {
        printf( "%s\n", [[loc description] UTF8String] );
    }
    */
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
    //NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    //if (locationAge > 15.0) {
    //    NSLog(@"Old age %f", locationAge);
    //    return;
    //}
    
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
