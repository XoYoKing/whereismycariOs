//
//  Datos.h
//  whereismycar
//
//  Created by Francisco Buitrago Pavon on 07/05/13.
//  Copyright (c) 2013 Francisco Buitrago Pavon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Datos : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
