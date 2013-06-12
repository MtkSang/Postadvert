//
//  CurrentLocationDetector.h
//  Stroff
//
//  Created by Ray on 6/12/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CurrentLocationDetector : NSObject<CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}
@property (nonatomic ) CLLocationCoordinate2D currentLocation;

- (CLLocationCoordinate2D ) gettingCurrentLocation;


@end
