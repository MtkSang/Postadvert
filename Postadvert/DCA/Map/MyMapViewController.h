//
//  MyMapViewController.h
//  Stroff
//
//  Created by Ray on 6/10/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/Mapkit.h"

@protocol MyMapViewControllerDelegate;

@interface MyMapViewController : UIViewController <MKMapViewDelegate, MKAnnotation>
{
    NSMutableArray *allPointAnotation;
}
@property (nonatomic, weak) id <MyMapViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *listPlacemarks;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *listAddressString;

- (void) addPlacemark:(CLPlacemark*)pm;
- (void) centerMap;
@end

@protocol MyMapViewControllerDelegate <NSObject>

- (void) callOutBtn_Clicked:(id) sender;

@end
