//
//  ShopController.m
//  SmartShop
//
//  Created by Batman on 19/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "ShopController.h"
#import <MapKit/MapKit.h>

#import "Location.h"
#import "Photo.h"
#import "DirectionCellModel.h"
#import "GoogleAPIShop.h"
#import "NSMapping.h"

// Google Route finder which is not currently used in the app
#import "Leg.h"
#import "Step.h"
#import "Route.h"


@interface ShopController ()


@end

@implementation ShopController

@synthesize shopsArr;

-(id)init
{
    self = [super init];
    if (self) {
        shopsArr = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)searchForShops:(CLLocationCoordinate2D)origin completionBlock:(void(^)())block
{
    // The address entered
    NSOperationQueue *downloadQueue = [[NSOperationQueue alloc] init];
    downloadQueue.name = @"download_queue";
    [downloadQueue addOperationWithBlock:^{
        // Perform geocoding
        // Send a synchronous request
        NSString *jsonPath = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=10000&types=clothing_store&sensor=false&key=AIzaSyAw0m3prCKzqP-zrWauU7DsXJgMDnbQY-Y",
                              origin.latitude,
                              origin.longitude ];
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
                                  JSONObjectWithData:responseData // 1
                                  options:kNilOptions
                                  error:&error];
            NSDictionary *locationMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             @"lat", @"lat",
                                             @"lng", @"lng",
                                             nil];
            NSDictionary *photoMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          @"reference", @"photo_reference",
                                          @"height", @"height",
                                          @"width", @"width",
                                          nil];
            NSDictionary *shopMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         @"SName", @"name",
                                         
                                         @{
                                           @"property": @"location", // The name in the class
                                           @"class": [Location class],
                                           @"mapping": locationMapping
                                           }, @"geometry.location",
                                         
                                         @{
                                           @"property": @"photosArray",
                                           @"class": [Photo class],
                                           @"mapping": photoMapping,
                                           }, @"photos",
                                         
                                         nil];
            [shopsArr removeAllObjects];
            for (NSDictionary *shopDict in [json objectForKey:@"results"]) {
                GoogleAPIShop *newShop = [NSMapping makeObject:[GoogleAPIShop class] WithMapping:shopMapping fromJSON:shopDict];
                [shopsArr addObject:newShop];
            }
        }
        if (block)
            block();
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
                    // Leg *leg = [newRoute.legsArray lastObject];
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
