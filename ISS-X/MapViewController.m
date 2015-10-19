//
//  MapViewController.m
//  ISS-X
//
//  Created by Jony Fu on 10/17/15.
//  Copyright © 2015 Jony Fu. All rights reserved.
//

#import "MapViewController.h"
#import "ISSLocation.h"

#define ZOOM_METERS 10000000.000
static BOOL isZoomCenter = YES;

@interface MapViewController () 

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    self.mapView.delegate = self;
    NSTimer* timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(fetchGeoData) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [super viewDidLoad];
    
    // [self fetchGeoData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.mapView.delegate = self;
    [self fetchGeoData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Map Annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString * identifier = @"ISSLocation";
    if ([annotation isKindOfClass:[ISSLocation class]]) {
        ISSLocation *issLocation = (ISSLocation *)annotation;
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = issLocation.annotationView;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}

- (void)refreshMapViewWithData:(NSDictionary *)jsonObject {
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
    }
    
    NSNumber *latitude = [[jsonObject objectForKey:@"iss_position"] objectForKey:@"latitude"];
    NSNumber *longitude = [[jsonObject objectForKey:@"iss_position"] objectForKey:@"longitude"];
    // NSLog(@"jsonObject: %@", jsonObject);
    // NSLog(@"%@, %@", latitude, longitude);
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = latitude.doubleValue;
    coordinate.longitude = longitude.doubleValue;
    
    // Make a region
    if (isZoomCenter) {
        MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(coordinate, ZOOM_METERS, ZOOM_METERS);
        [_mapView setRegion:mapRegion];
        isZoomCenter = NO;
    }
    
    // NSString *city = [self fetchCityDataWithLatitude:latitude.doubleValue andLongitude:longitude.doubleValue];
    // The first bonus was not implemented totally. I display the geo infomation on annotation.
    // The next step I can do:
        // The closest city will fetch data with latitude and longitude.
        // Call Google Maps API: https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f
        // Get the nearby city.
    
    ISSLocation *annotation = [[ISSLocation alloc] initWithTitle:[NSString stringWithFormat:@"Lat:%.2f, Lng:%.2f", latitude.doubleValue, longitude.doubleValue] Coordinate:coordinate];
    [_mapView addAnnotation:annotation];
}

#pragma mark Fetch ISS Location Data
- (void)fetchGeoData {
    NSURL *url = [NSURL URLWithString:@"http://api.open-notify.org/iss-now.json"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse * response, NSData * data, NSError * connectionError) {
        if (data) {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            // check status code and possibly MIME type (which shall start with "application/json"):
            NSRange range = [response.MIMEType rangeOfString:@"application/json"];
            
            if (httpResponse.statusCode == 200 && range.length != 0) {
                NSError* error;
                NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (jsonObject) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self refreshMapViewWithData:jsonObject];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"ERROR: %@", error);
                    });
                }
            }
            else {
                // status code indicates error, or didn't receive type of data requested
                NSString* desc = [[NSString alloc] initWithFormat:@"HTTP Request failed with status code: %d (%@)",
                                  (int)(httpResponse.statusCode),
                                  [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
                NSError* error = [NSError errorWithDomain:@"HTTP Request"
                                                     code:-1000
                                                 userInfo:@{NSLocalizedDescriptionKey: desc}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self handleError:error];
                    NSLog(@"ERROR: %@", error);
                });
            }
        }
        else {
            // request failed - error contains info about the failure
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self handleError:error];
                NSLog(@"ERROR: %@", connectionError);
            });
        }
    }];
    
}


@end
