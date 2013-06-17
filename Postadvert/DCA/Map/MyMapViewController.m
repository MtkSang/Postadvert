//
//  MyMapViewController.m
//  Stroff
//
//  Created by Ray on 6/10/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "MyMapViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#define METERS_PER_MILE 1609.344

@interface MyMapViewController ()

@end

@implementation MyMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _listPlacemarks = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapView.showsUserLocation = NO;
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addAnnotation];
}

- (void) viewDidAppear:(BOOL)animated
{
    _mapView.showsUserLocation = NO;
    [super viewDidAppear:animated];
}

- (void ) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_mapView removeAnnotations:_mapView.annotations];

}
- (void) addAnnotation
{
    allPointAnotation = [[NSMutableArray alloc]init];
    for (CLPlacemark* placemark in _listPlacemarks) {
        if ([placemark isKindOfClass:[NSNull class]]) {
            [allPointAnotation addObject:[NSNull null]];
            continue;
        }
        //CLPlacemark *placemark = (CLPlacemark*)pm;
        
        // use the AddressBook framework to create an address dictionary
        NSString *addressString = CFBridgingRelease(CFBridgingRetain(ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)));
        
        CLLocationDegrees latitude = placemark.location.coordinate.latitude;
        CLLocationDegrees longitude = placemark.location.coordinate.longitude;
        
        MKPointAnnotation *myLocation=[[MKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude   = latitude;
        coor.longitude  = longitude;
        [myLocation setCoordinate:coor];
        myLocation.title= addressString;
        //        myLocation.subtitle=tempCategory;
        [allPointAnotation addObject:myLocation];
        [_mapView addAnnotation:myLocation];
    }
    //
//    if (_listPlacemarks.count) {
//        
//        CLLocationCoordinate2D coor;
//        CLPlacemark *placemark = [_listPlacemarks objectAtIndex:0];
//        CLLocationDegrees latitude = placemark.location.coordinate.latitude;
//        CLLocationDegrees longitude = placemark.location.coordinate.longitude;
//        coor.latitude   = latitude;
//        coor.longitude  = longitude;
//        
//        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coor,1*METERS_PER_MILE, 1*METERS_PER_MILE);
//        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
//        [_mapView setRegion:adjustedRegion animated:YES];
//    }
}

- (void) addPlacemark:(CLPlacemark*)placemark
{
    [_listPlacemarks addObject:placemark];
    if ([placemark isKindOfClass:[NSNull class]]) {
        [allPointAnotation addObject:[NSNull null]];
        return;
    }
    //CLPlacemark *placemark = (CLPlacemark*)pm;
    
    // use the AddressBook framework to create an address dictionary
    NSString *addressString = CFBridgingRelease(CFBridgingRetain(ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)));
    
    CLLocationDegrees latitude = placemark.location.coordinate.latitude;
    CLLocationDegrees longitude = placemark.location.coordinate.longitude;
    
    MKPointAnnotation *myLocation=[[MKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude   = latitude;
    coor.longitude  = longitude;
    [myLocation setCoordinate:coor];
    myLocation.title= addressString;
    //        myLocation.subtitle=tempCategory;
    [allPointAnotation addObject:myLocation];
    [_mapView addAnnotation:myLocation];
    
}

- (void) centerMap
{
    if (_listPlacemarks.count == 1) {

        CLLocationCoordinate2D coor;
        CLPlacemark *placemark = [_listPlacemarks objectAtIndex:0];
        CLLocationDegrees latitude = placemark.location.coordinate.latitude;
        CLLocationDegrees longitude = placemark.location.coordinate.longitude;
        coor.latitude   = latitude;
        coor.longitude  = longitude;

        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coor,0.5 * METERS_PER_MILE, 0.5 *METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:YES];
        return;
    }

    [self zoomToAnnotationsBounds:_mapView.annotations];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *annotationView = nil;
    annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                     reuseIdentifier:nil];
    [annotationView setPinColor:1];
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    //    if (allNotations) {
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:self
                    action:@selector(showDetailView:)
          forControlEvents:UIControlEventTouchUpInside];
    rightButton.tag = [allPointAnotation indexOfObject:annotation];
    annotationView.rightCalloutAccessoryView = rightButton;
    //    }
    return annotationView;
}

- (void) showDetailView:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(callOutBtn_Clicked:)]) {
        [self.delegate callOutBtn_Clicked:sender];
    }
}

- (void) zoomToAnnotationsBounds:(NSArray *)annotations {
    
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    for (MKPointAnnotation *annotation in annotations) {
        double annotationLat = annotation.coordinate.latitude;
        double annotationLong = annotation.coordinate.longitude;
        minLatitude = fmin(annotationLat, minLatitude);
        maxLatitude = fmax(annotationLat, maxLatitude);
        minLongitude = fmin(annotationLong, minLongitude);
        maxLongitude = fmax(annotationLong, maxLongitude);
    }
    
    // See function below
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
    
    // If your markers were 40 in height and 20 in width, this would zoom the map to fit them perfectly. Note that there is a bug in mkmapview's set region which means it will snap the map to the nearest whole zoom level, so you will rarely get a perfect fit. But this will ensure a minimum padding.
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(40.0, 10.0, 0.0, 10.0);
    CLLocationCoordinate2D relativeFromCoord = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
    
    // Calculate the additional lat/long required at the current zoom level to add the padding
    CLLocationCoordinate2D topCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.top) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D rightCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.right) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D bottomCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.bottom) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D leftCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.left) toCoordinateFromView:self.mapView];
    
    double latitudeSpanToBeAddedToTop = relativeFromCoord.latitude - topCoord.latitude;
    double longitudeSpanToBeAddedToRight = relativeFromCoord.latitude - rightCoord.latitude;
    double latitudeSpanToBeAddedToBottom = relativeFromCoord.latitude - bottomCoord.latitude;
    double longitudeSpanToBeAddedToLeft = relativeFromCoord.latitude - leftCoord.latitude;
    
    maxLatitude = maxLatitude + latitudeSpanToBeAddedToTop;
    minLatitude = minLatitude - latitudeSpanToBeAddedToBottom;
    
    maxLongitude = maxLongitude + longitudeSpanToBeAddedToRight;
    minLongitude = minLongitude - longitudeSpanToBeAddedToLeft;
    
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
}

-(void) setMapRegionForMinLat:(double)minLatitude minLong:(double)minLongitude maxLat:(double)maxLatitude maxLong:(double)maxLongitude {
    
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    if (minLatitude == DBL_MAX ||
        maxLatitude == -DBL_MAX ||
        minLongitude == DBL_MAX ||
        maxLongitude == -DBL_MAX )
    {
        region = MKCoordinateRegionMakeWithDistance(_mapView.userLocation.location.coordinate,1*METERS_PER_MILE, 1*METERS_PER_MILE);
    }
    // MKMapView BUG: this snaps to the nearest whole zoom level, which is wrong- it doesn't respect the exact region you asked for. See http://stackoverflow.com/questions/1383296/why-mkmapview-region-is-different-than-requested
    [self.mapView setRegion:region animated:YES];
}

@end
