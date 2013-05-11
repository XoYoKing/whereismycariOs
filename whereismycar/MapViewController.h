//
//  ViewController.h
//  whereismycar
//
//  Created by Francisco Buitrago Pavon on 05/05/13.
//  Copyright (c) 2013 Francisco Buitrago Pavon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate>{
    IBOutlet MKMapView *mapa;
    float latitud;
    float longitud;
    CLLocationManager *locationManager;
    NSMutableArray *annotations;
    
    
    
}

@property (nonatomic, retain) NSMutableArray *annotations;
@property (nonatomic, retain) MKMapView *mapa;
@property (nonatomic,assign) float latitud;
@property (nonatomic,assign) float longitud;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic,retain) NSMutableArray *_path;
- (IBAction)btRoute:(id)sender;
- (IBAction)btlastParkings:(id)sender;



@end
