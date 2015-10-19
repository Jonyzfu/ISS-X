//
//  ISSLocation.h
//  ISS-X
//
//  Created by Jony Fu on 10/17/15.
//  Copyright © 2015 Jony Fu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ISSLocation : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;

- (id)initWithTitle: (NSString *) title Coordinate: (CLLocationCoordinate2D)coordinate;
- (MKAnnotationView *)annotationView;

@end
