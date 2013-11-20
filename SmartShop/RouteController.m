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
                                                               route.expectedTravelTime/60, nil]
                                                  }];
                [routesArr replaceObjectAtIndex:i withObject:newDirection];
                // [routesArr addObject:newDirection];
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
        NSArray *arrRoutes = [response routes];
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

// This is alternative method of using google's API to find routes
// The framework uses apples as the google routes are not centered on the road
// This can be used later on for other transportation styles
#pragma Get Directions From Googles API
// Get directions from an origin to a destination, using google's API
-(void) googleGetDirectionsFrom:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D) dest
{
    // The address entered
    NSOperationQueue *downloadQueue = [[NSOperationQueue alloc] init];
    downloadQueue.name = @"Download Queue";
    downloadQueue.maxConcurrentOperationCount = 5;
    [downloadQueue addOperationWithBlock:^{
        // Send a synchronous request
        NSString *jsonPath = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&avoid=highways&mode=walking",
                              origin.latitude, origin.longitude,
                              dest.latitude, dest.longitude
                              ];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:jsonPath]];
        NSURLResponse *returingResponse = nil;
        NSError *connError = nil;
        NSData * responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                      returningResponse:&returingResponse
                                                                  error:&connError];
        if (connError == nil)
        {
            //parse out the json data
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseData //1
                                  options:kNilOptions
                                  error:&error];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                NSDictionary *locationMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                 @"lat", @"lat",
                                                 @"lng", @"lng",
                                                 nil];
                
                NSDictionary *stepMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             @"travelMode", @"travel_mode",
                                             @"distance", @"distance.text",
                                             @"duration", @"duration.text",
                                             @"htmlInstructions", @"html_instructions",
                                             @"maneuver", @"maneuver",
                                             
                                             @{
                                               @"property": @"startLocation", // The name in the class
                                               @"class": [Location class],
                                               @"mapping": locationMapping
                                               }, @"start_location",
                                             @{
                                               @"property": @"endLocation", // The name in the class
                                               @"class": [Location class],
                                               @"mapping": locationMapping
                                               }, @"end_location",
                                             
                                             nil];
                
                NSDictionary *legMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                            @"endAddress", @"end_address",
                                            @"startAddress", @"start_address",
                                            @"distance", @"distance.text",
                                            @"duration", @"duration.text",
                                            
                                            @{
                                              @"property": @"startLocation", // The name in the class
                                              @"class": [Location class],
                                              @"mapping": locationMapping
                                              }, @"start_location",
                                            
                                            @{
                                              @"property": @"endLocation", // The name in the class
                                              @"class": [Location class],
                                              @"mapping": locationMapping
                                              }, @"end_location",
                                            
                                            @{
                                              @"property": @"stepsArray",
                                              @"class": [Step class],
                                              @"mapping": stepMapping
                                              }, @"steps",
                                            
                                            nil];
                
                NSDictionary *routeMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                               @"copyrights", @"copytights",
                                              @"warnings", @"warnings",
                                              @"overviewPolylinePointsEncoded", @"overview_polyline.points",
                                               @{
                                                 @"property": @"legsArray",
                                                 @"class": [Leg class],
                                                 @"mapping":legMapping
                                                 }, @"legs",
                                               nil];
                
                for (NSDictionary *routeDict in [json objectForKey:@"routes"]) {
                    Route *newRoute = [NSMapping makeObject:[Route class] WithMapping:routeMapping fromJSON:routeDict];
                    Leg *leg = [newRoute.legsArray lastObject];
                    // cell.originLabel.text = leg.startAddress;
                    // cell.destinationLabel.text = leg.endAddress;
                    // cell.durationLabel.text = leg.duration;
                    // cell.distanceLabel.text = leg.distance;
                    // NSLog(@"%@", newRoute);
                    
                    // Location *customStartLocation = [[newRoute.legsArray firstObject] startLocation];
                    // Location *customEndLocation = [[newRoute.legsArray firstObject] endLocation];
                    // [self.routes addObject:customStartLocation];
                    // [self.routes addObject:customEndLocation];
                    
                    NSMutableArray *mkRouteSteps = [[NSMutableArray alloc] init];
                    for (Step *step in [[newRoute.legsArray firstObject] stepsArray]) {
                        [mkRouteSteps addObject:step.startLocation];
                        [mkRouteSteps addObject:step.endLocation];
                        // [self.routes addObject:step.startLocation];
                        // [self.routes addObject:step.endLocation];
                    }
                    // NSLog(@"%@", mkRouteSteps);
                    
                    // MKPolyline *line = [MapViewController polylineWithEncodedString:newRoute.overviewPolylinePointsEncoded];
                    // [self.routes addObject:mkRouteSteps];
                }
            }];
        }
    }];
}
@end
