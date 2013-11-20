//
//  RouteController.m
//  SmartShop
//
//  Created by Batman on 20/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "RouteController.h"
#import <MapKit/MapKit.h>
#import "NSMapping.h"
#import "GoogleAPIShop.h"
#import "DirectionCellModel.h"

// Google Route finder which is not currently used in the app
#import "Leg.h"
#import "Step.h"
#import "Route.h"

@implementation RouteController

@synthesize routesArr;

-(id)init{
    self = [super init];
    if (self) {
        routesArr = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithShops:(NSMutableArray *)shopsArr andLocation:(CLLocationCoordinate2D)origin
{
    self = [self init];
    if (self) {
        int i = 0;
        [routesArr removeAllObjects];
        for (int i=0; i<shopsArr.count; i++)
            [routesArr addObject:[[NSObject alloc] init]];
        for (GoogleAPIShop *shop in shopsArr) {
            double lat = shop.location.lat;
            double lng = shop.location.lng;
            CLLocationCoordinate2D dest = CLLocationCoordinate2DMake(lat, lng);
            [self appleGetDirectionsFrom:origin to:dest completionBlock:^(MKDirectionsResponse *response){
                MKRoute *route = [[response routes] lastObject];
                DirectionCellModel *newDirection = [[DirectionCellModel alloc] init];
                [newDirection
                 setValuesForKeysWithDictionary:@{
                                                  @"shop": shop,
                                                  @"origin": response.source.name,
                                                  @"destination": response.destination.name,
                                                  @"distance": [[NSString alloc]
                                                                initWithFormat:@"%0.2f m", route.distance, nil],
                                                  @"duration":[[NSString alloc]
                                                               initWithFormat:@"%0.0f minutes",
                                                               route.expectedTravelTime/60, nil],
                                                  @"routes":[response routes]
                                                  }];
                [routesArr replaceObjectAtIndex:i withObject:newDirection];
            }];
            i++;
        }
    }
    return self;
}

-(void) appleGetDirectionsFrom:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D)dest completionBlock:(void (^)(MKDirectionsResponse *response))block
{
    MKPlacemark *source = [[MKPlacemark alloc]
                           initWithCoordinate:origin
                           addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
 
    
    MKMapItem *srcMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:dest addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    int __block numResponsesReceived = 0;
    void(^handleResponse)(MKDirectionsResponse *response)=^(MKDirectionsResponse *response){
        numResponsesReceived += 1;
        if (numResponsesReceived==3)
            block(response);
    };
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        [[[CLGeocoder alloc] init] reverseGeocodeLocation:source.location completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if ([placemarks count] > 0)
             {
                 response.source.name = [[[placemarks lastObject] addressDictionary] objectForKey:@"Name"];
                 handleResponse(response);
             }
         }];
        
        [[[CLGeocoder alloc] init] reverseGeocodeLocation:destination.location completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if ([placemarks count] > 0)
             {
                 response.destination.name = [[[placemarks lastObject] addressDictionary] objectForKey:@"Name"];
                 handleResponse(response);
             }
         }];
        handleResponse(response);
        // NSArray *arrRoutes = [response routes];
        /*
         // Showing steps and info on that
        [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MKRoute *rout = obj;
            
            
            MKPolyline *line = [rout polyline];
            // [self.mkMapView addOverlay:line];
            NSLog(@"Rout Name : %@",rout.name);
            NSLog(@"Total Distance (in Meters) :%f",rout.distance);
            
            NSArray *steps = [rout steps];
            
            NSLog(@"Total Steps : %d",[steps count]);
            
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSLog(@"Rout Instruction : %@",[obj instructions]);
                // NSLog(@"Rout Distance : %f",[obj distance]);
            }];
        }];
         */
    }];
}

@end
