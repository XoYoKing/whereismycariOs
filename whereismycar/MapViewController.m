//
//  ViewController.m
//  whereismycar
//
//  Created by Francisco Buitrago Pavon on 05/05/13.
//  Copyright (c) 2013 Francisco Buitrago Pavon. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "DDAnnotation.h"
#import "MapViewController.h"
#import "AppDelegate.h"
#import "Datos.h"
#import "AFDSTAPIClient.h"
#import "AFJSONRequestOperation.h"
#define ZOOM 100
#define HANGAR_LATITUDE 41.60941f
#define HANGAR_LONGITUDE -0.890064

@interface MapViewController ()
-(void)calculateRoute:(float)latitudOrigen longitudOringen:(float)longitudOringen;
-(void)pintar:(float)latitudO longitudO:(float)longitudO coche:(bool)isCar ;

@end

@implementation MapViewController
@synthesize latitud,longitud,locationManager,mapa,annotations,_path;
bool ultimosParking = false;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)setPosition{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;// 100 m
    [locationManager startUpdatingLocation];
    
    
}

- (void) viewWillAppear:(BOOL)animated{
   
    [self setPosition];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    mapa.delegate = self;
    self.mapa.showsUserLocation = YES;
    [self.view addSubview:mapa];
   
    
}

- (void)viewDidUnload
{
    [self setMapa:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void) mapView:(MKMapView *) mapView didAddAnnotationViews:(NSArray *) views
{
    //  [annotation setCoordinate:(location)];
    NSLog(@"paso por didAddAnnotationViews");
    //[mapView selectAnnotation:[[mapView annotations] lastObject] animated:NO];
    
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    self.latitud=newLocation.coordinate.latitude;
    self.longitud=newLocation.coordinate.longitude;
    
    [locationManager stopUpdatingLocation];
    if (ultimosParking){
        if ([mapa.annotations count]>0){
            NSArray *oldAnnotations=[self.mapa annotations];
            [self.mapa removeAnnotations:oldAnnotations];
        
            
        }
        NSArray *oldOverlays=[self.mapa overlays];
        [self.mapa removeOverlays:oldOverlays];

        NSMutableArray *lastParkings = [[NSMutableArray alloc]initWithArray:[self getDataFromBBDD:5 lat:latitud longs:longitud]];
        
        for(int i =0; i<[lastParkings count];i++){
            CLLocationCoordinate2D point ;
            Datos *data =  [lastParkings objectAtIndex:i];
            
            float lat = [data.latitude floatValue];
            
            float longs = [data.longitude floatValue];
            point.latitude=lat;
            point.longitude=longs;
            
            [self pintar:lat longitudO:longs coche:true];
            
        }
        ultimosParking=false;
        
    }else{
        [self pintar:latitud longitudO:longitud coche:false];
        [self calculateRoute:latitud longitudOringen:longitud];
    }
        
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if ( status == kCLAuthorizationStatusDenied){
        UIAlertView *alertViewDialog =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"titGuar", @"")  message:NSLocalizedString(@"gps", @"")  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertViewDialog show];
        [locationManager stopUpdatingLocation];
        //[delegado activarMapa];
    }
}


-(void)pintar:(float)latitudO longitudO:(float)longitudO coche:(bool)isCar{
    
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude= latitudO;
    theCoordinate.longitude= longitudO;
    
    
        
    DDAnnotation* myAnnotation;
    myAnnotation=[[DDAnnotation alloc] init];
    myAnnotation.coordinate=theCoordinate;
    if (isCar)
        myAnnotation.title= NSLocalizedString(@"coche", @"");
    else
        myAnnotation.title= NSLocalizedString(@"tu posicion", @"");
    myAnnotation.subtitle = [NSString	stringWithFormat:@"%f %f",myAnnotation.coordinate.latitude, myAnnotation.coordinate.longitude];
    
    [mapa addAnnotation:myAnnotation];
    
    /*
     MKMapRect flyTo = MKMapRectNull;
     map.visibleMapRect = flyTo;
     for (MHAnnotation* annotation in annotations)
     {
     MKMapPoint annotationPoint = MKMapPointForCoordinate(myAnnotation.coordinate);
     MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y-75000, 0, 0);
     if (MKMapRectIsNull(flyTo)) {
     flyTo = pointRect;
     } else {
     flyTo = MKMapRectUnion(flyTo, pointRect);
     }
     }
     
     MKCoordinateRegion region;
     MKCoordinateSpan span;
     span.latitudeDelta=0.2*10/ZOOM;
     span.longitudeDelta=0.2*10/ZOOM;
     region.center=theCoordinate;
     region.span=span;
     [map setRegion:region animated:TRUE];
     [map regionThatFits:region];
     */
    
    
    
    
    
}


-(NSMutableArray *)decodePolyLine:(NSString *)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc]
                                initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0,
                                                    [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1)
                          : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1)
                          : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:
                                [latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:location];
    }
    return array;
}

- (void)parseResponse:(NSDictionary *)response {
    NSArray *routes = [response objectForKey:@"routes"];
    NSDictionary *route = [routes lastObject];
    if (route) {
        NSString *overviewPolyline = [[route objectForKey:
                                       @"overview_polyline"] objectForKey:@"points"];
        _path = [self decodePolyLine:overviewPolyline];
        NSArray *oldOverlays=[self.mapa overlays];
        [self.mapa removeOverlays:oldOverlays];
    }else {
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalidAddress",@"") message:NSLocalizedString(@"textoInvalidAddres",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok",@"") otherButtonTitles:nil];
        [alertError show];
        
        
        
    }
    
    NSInteger numberOfSteps = _path.count;
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        CLLocation *location = [_path objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
    }
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates
                                                         count:numberOfSteps];
    [mapa addOverlay:polyLine];
    
}

-(void)calculateRoute:(float)latitudOrigen longitudOringen:(float)longitudOringen{
    // Also request Google Directions API to retrieve the route:
    
    
    
    AFHTTPClient *_httpClient = [AFHTTPClient clientWithBaseURL:[NSURL
                                                                 URLWithString:@"http://maps.googleapis.com/"]];
    [_httpClient registerHTTPOperationClass: [AFJSONRequestOperation class]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%f,%f",
                           latitudOrigen,longitudOringen]
                   forKey:@"origin"];
    
    
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self pintar:appDelegate.getlatitude longitudO:appDelegate.getlongitude coche:true];
    [parameters setObject:[NSString stringWithFormat:@"%f,%f",
                           appDelegate.getlatitude   ,appDelegate.getlongitude]
                   forKey:@"destination"];
    [parameters setObject:@"true" forKey:@"sensor"];
    NSMutableURLRequest *request = [_httpClient requestWithMethod:@"GET" path:
                                    @"maps/api/directions/json" parameters:parameters];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    AFHTTPRequestOperation *operation = [_httpClient
                                         HTTPRequestOperationWithRequest:request
                                         success:^(AFHTTPRequestOperation *operation, id response) {
                                             NSInteger statusCode = operation.response.statusCode;
                                             if (statusCode == 200) {
                                                 [self parseResponse:response];
                                             } else {
                                             }
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) { }];
    [_httpClient enqueueHTTPRequestOperation:operation];
  
    
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:
                                    overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 3.0;
    return polylineView;
}

-(double)deg2rad:(double)deg
{
    return deg *(M_1_PI/180);
    
}


-(double)isNear:(float) lat1
     longitud1:(float) lon1
      latitud2:(float) lat2
     longitud2:(float)lon2
{
    
    double R = 6371;
    double dLat = [self deg2rad:(lat2-lat1)];
    double dLon = [self deg2rad:(lon2-lon1)];
    double a =
    sin(dLat/2) * sin(dLat/2) +
    cos([self deg2rad:(lat1)]) * cos([self deg2rad:(lat2)]) *
    sin(dLon/2) * sin(dLon/2);
    double c = 2 * atan2(sqrt(a),sqrt(1-a));
    double d = R * c; // Distance in km
    return d;
    
}


- (NSMutableArray *)getDataFromBBDD:(float)distance lat:(float)latitud2 longs:(float)longitud2{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Datos" inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cdEstado==%d OR cdEstado==%d", ESTADO_CHEQUEADO,ESTADO_CANCELADA];
    //    request.predicate=predicate;
    
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cdCodigo" ascending:NO selector:@selector(localizedStandardCompare:)];
    //NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    //[request setSortDescriptors:sortDescriptors];
    
    
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    
    NSMutableArray *mutableResults = [[NSMutableArray alloc]init];
    
    for( int i = 0 ; i< [mutableFetchResults count];i++) {
        
        Datos *data =  [mutableFetchResults objectAtIndex:i];
        
        float lat = [data.latitude floatValue];
        
        float longs = [data.longitude floatValue];
        double distancecal = [self isNear:latitud2 longitud1:longitud2 latitud2:lat longitud2:longs];
        if (distance>[self isNear:latitud2 longitud1:longitud2 latitud2:lat longitud2:longs]){
             NSLog(@"%f locationbd distnce", distancecal);
            [mutableResults addObject:data];
        }else
            NSLog(@"im not here");
        
        
        NSLog(@"%f locationbd latitude", lat);
        NSLog(@"%f locationbd longitude", longs);
    }
    return mutableResults;
}



- (IBAction)btlastParkings:(id)sender {
    ultimosParking=true;
    [self setPosition];
    
}

- (IBAction)btRoute:(id)sender {
    if ([mapa.annotations count]>0){
        NSArray *oldAnnotations=[self.mapa annotations];
        [self.mapa removeAnnotations:oldAnnotations];
        
        
    }
    NSArray *oldOverlays=[self.mapa overlays];
    [self.mapa removeOverlays:oldOverlays];
    [self setPosition];
    
}

@end
