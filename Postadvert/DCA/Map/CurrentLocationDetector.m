//
//  CurrentLocationDetector.m
//  Stroff
//
//  Created by Ray on 6/12/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "CurrentLocationDetector.h"

@implementation CurrentLocationDetector

- (CLLocationCoordinate2D) gettingCurrentLocation {
    // locationManager update as location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    _currentLocation = coordinate;
    //[locationManager stopUpdatingLocation];
    return coordinate;
}


@end
