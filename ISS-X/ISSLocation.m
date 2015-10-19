//
//  ISSLocation.m
//  ISS-X
//
//  Created by Jony Fu on 10/17/15.
//  Copyright © 2015 Jony Fu. All rights reserved.
//

#import "ISSLocation.h"

@interface ISSLocation ()

@end

@implementation ISSLocation

- (id)initWithTitle:(NSString *)title Coordinate:(CLLocationCoordinate2D)coordinate {
    if (self = [super init]) {
        self.coordinate = coordinate;
        self.title = title;
    }
    return self;
}

-(MKAnnotationView *)annotationView {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"ISSLocation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.contentMode = UIViewContentModeScaleAspectFit;
    annotationView.image = [UIImage imageNamed:@"iss.png"];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.frame = CGRectMake(0, 0, 50, 50);
    
    return annotationView;
}

@end
