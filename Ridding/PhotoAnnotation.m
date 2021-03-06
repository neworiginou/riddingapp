//
//  PhtotAnnotation.m
//  Ridding
//
//  Created by zys on 12-10-13.
//
//

#import "PhotoAnnotation.h"

@interface PhotoAnnotation ()

@end

@implementation PhotoAnnotation

- (id)initWithLatitude:(CLLocationDegrees)latitude
          andLongitude:(CLLocationDegrees)longitude {

  if (self = [super init]) {
    _latitude = latitude;
    _longitude = longitude;
  }
  return self;
}

- (CLLocationCoordinate2D)coordinate {

  CLLocationCoordinate2D coordinate;
  coordinate.latitude = _latitude;
  coordinate.longitude = _longitude;
  return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {

  _latitude = newCoordinate.latitude;
  _longitude = newCoordinate.longitude;
}


@end
