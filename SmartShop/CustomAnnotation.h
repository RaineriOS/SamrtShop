//
//  CustomAnnotation.h
//  SmartShop
//
//  Created by Batman on 22/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotation : MKAnnotationView


@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;

@end
