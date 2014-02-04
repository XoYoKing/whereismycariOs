//
//  ViewController.m
//  whereismycar
//
//  Created by Francisco Buitrago Pavon on 05/05/13.
//  Copyright (c) 2013 Francisco Buitrago Pavon. All rights reserved.
//

#import "Datos.h"
#import "MainViewController.h"
#import "AFDSTAPIClient.h"
#import "AppDelegate.h"

@interface MainViewController ()

-(void) setposition;



@end

@implementation MainViewController
@synthesize latitud;
@synthesize longitud;
@synthesize locationManager;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setposition{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;// 100 m
    [locationManager startUpdatingLocation];
   
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if ( status == kCLAuthorizationStatusDenied){
        UIAlertView *alertViewDialog =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"titGuar", @"")  message:NSLocalizedString(@"gps", @"")  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertViewDialog show];
        [locationManager stopUpdatingLocation];
                
        
    }
}



- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    self.latitud=newLocation.coordinate.latitude;
    self.longitud=newLocation.coordinate.longitude;
    
    [locationManager stopUpdatingLocation];
          AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
    appDelegate.latitude=latitud;
    appDelegate.longitude=longitud;
    NSLog(@"%f location", latitud);
    NSLog(@"%f location", longitud);
    
   
    
    Datos *data = (Datos *)[NSEntityDescription insertNewObjectForEntityForName:@"Datos" inManagedObjectContext:appDelegate.managedObjectContext];

    data.latitude=[NSNumber numberWithFloat:latitud];
    data.longitude=[NSNumber numberWithFloat:longitud];
    
    NSError *error = nil;
    
    if (![appDelegate.managedObjectContext save:&error]) {
        // Handle the error.
        NSLog(@"un error al guardar: %@", error);
        abort();
    }
    
 }



- (IBAction)btImHere:(id)sender {
    [self setposition];
}
@end
