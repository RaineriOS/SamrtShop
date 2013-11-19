//
//  ShopController.m
//  SmartShop
//
//  Created by Batman on 19/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "ShopAndRouteController.h"
#import <MapKit/MapKit.h>

#import "Location.h"
#import "Photo.h"
#import "DirectionCellModel.h"
#import "GoogleAPIShop.h"
#import "NSMapping.h"


@interface ShopAndRouteController ()

@property (assign, nonatomic) CLLocationCoordinate2D origin;

@end

@implementation ShopAndRouteController

@synthesize shopsAndDirectionsArr;

-(id)init
{
    self = [super init];
    if (self) {
        shopsAndDirectionsArr = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)searchForShops:(NSString *)city
{
    // The address entered
    NSOperationQueue *downloadQueue = [[NSOperationQueue alloc] init];
    downloadQueue.name = @"download_queue";
    downloadQueue.maxConcurrentOperationCount = 5;
    [downloadQueue addOperationWithBlock:^{
        // Perform geocoding
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder geocodeAddressString:city completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            self.origin = placemark.location.coordinate;
            
            // Send a synchronous request
            NSString *jsonPath = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=10000&types=clothing_store&sensor=false&key=AIzaSyAw0m3prCKzqP-zrWauU7DsXJgMDnbQY-Y",
                                  placemark.location.coordinate.latitude,
                                  placemark.location.coordinate.longitude ];
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
                int i = 0;
                for (NSDictionary *shopDict in [json objectForKey:@"results"]) {
                    GoogleAPIShop *newShop = [NSMapping makeObject:[GoogleAPIShop class] WithMapping:shopMapping fromJSON:shopDict];
                    double lat = newShop.location.lat;
                    double lng = newShop.location.lng;
                    CLLocationCoordinate2D dest = CLLocationCoordinate2DMake(lat, lng);
                    [self appleGetDirectionsFrom:self.origin to:dest completionBlock:^(MKDirectionsResponse *response){
                        MKRoute *route = [[response routes] lastObject];
                        DirectionCellModel *newDirection = [[DirectionCellModel alloc] init];
                        [newDirection setValuesForKeysWithDictionary:@{
                                                                       @"shop": newShop,
                                                                       @"origin": response.source.name,
                                                                       @"destination": response.destination.name,
                                                                       @"distance": [[NSString alloc]
                                                                                     initWithFormat:@"%0.2f m", route.distance, nil],
                                                                       @"duration":[[NSString alloc]
                                                                                    initWithFormat:@"%0.0f minutes",
                                                                                    route.expectedTravelTime/60, nil]
                                                                       }];
                    }];
                    i++;
                }
            }
        }];
    }];
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
                 // block(response);
                 handleResponse(response);
             }
         }];
        
        [[[CLGeocoder alloc] init] reverseGeocodeLocation:destination.location completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if ([placemarks count] > 0)
             {
                 response.destination.name = [[[placemarks lastObject] addressDictionary] objectForKey:@"Name"];
                 block(response);
                 handleResponse(response);
             }
         }];
        
        // block(response);
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


@end
