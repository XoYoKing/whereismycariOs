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

@interface MainViewController : UIViewController<CLLocationManagerDelegate>{
    
    
    float latitud;
    float longitud;
    CLLocationManager *locationManager;
    
}
@property (nonatomic,assign) float latitud;
@property (nonatomic,assign) float longitud;
@property (nonatomic, retain) CLLocationManager *locationManager;



- (IBAction)btImHere:(id)sender;

@end
