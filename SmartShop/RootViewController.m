//
//  RootViewController.m
//  SmartShop
//
//  Created by Batman on 05/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "RootViewController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "MapViewController.h"
#import "DirectionsCell.h"
#import "Shop.h"
#import "Photo.h"
#import "Route.h"
#import "Leg.h" 
#import "Step.h"
#import "Location.h"
#import "NSMapping.h"


@interface RootViewController ()

@property (strong, nonatomic) MKPointAnnotation *currentPointAnnotation;
@property (strong, nonatomic) NSMutableArray *routes;
@property (assign, nonatomic) CLLocationCoordinate2D origin;

@end

@implementation RootViewController

@synthesize tableView;
@synthesize locationTextField;
@synthesize shopsArr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    shopsArr = [[NSMutableArray alloc] init];
    self.routes = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchForShops:(id)sender
{
    NSString *city = self.locationTextField.text;
    // The address entered
    NSOperationQueue *downloadQueue = [[NSOperationQueue alloc] init];
    downloadQueue.name = @"Download Queue";
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
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
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
                    for (NSDictionary *shopDict in [json objectForKey:@"results"]) {
                        Shop *newShop = [NSMapping makeObject:[Shop class] WithMapping:shopMapping fromJSON:shopDict];
                        [shopsArr addObject:newShop];
                    }
                    [tableView reloadData];
                }];
            }
        }];
    }];
}

-(void) getDirectionsFrom:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D) dest forCell:(DirectionsCell *)cell
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
                    cell.originLabel.text = leg.startAddress;
                    cell.destinationLabel.text = leg.endAddress;
                    cell.durationLabel.text = leg.duration;
                    cell.distanceLabel.text = leg.distance;
                    [self.tableView reloadData];
                    NSLog(@"%@", newRoute);
                    
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
                    
                    MKPolyline *line = [MapViewController polylineWithEncodedString:newRoute.overviewPolylinePointsEncoded];
                    // [self.routes addObject:mkRouteSteps];
                    [self.routes addObject:line];
                }
            }];
        }
    }];
}

-(void) getDirectionsFrom:(CLLocationCoordinate2D)origin to:(CLLocationCoordinate2D) dest
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
                    NSLog(@"%@", newRoute);
                    
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
                    [self.routes addObject:mkRouteSteps];
                }
            }];
        }
    }];
}

# pragma mark - Map view segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRestaurant"]) {
        
        Shop *shop = [shopsArr objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        // show the location
        MKPointAnnotation *annotationView = [[MKPointAnnotation alloc] init];
        double lat = shop.location.lat;
        double lng = shop.location.lng;
        // NSLog(@"%f %f %i", lat, lng, self.tableView.indexPathForSelectedRow.row);
        NSLog(@"%i", self.tableView.indexPathForSelectedRow.row);
        annotationView.coordinate = CLLocationCoordinate2DMake(lat, lng);
        self.currentPointAnnotation = annotationView;
        
        MapViewController *mapVC = [segue destinationViewController];
        mapVC.locationArray = self.routes;
        [mapVC setPointAnnotation:self.currentPointAnnotation];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [shopsArr count];
}


-(UITableViewCell *)tableView:(UITableView *)localTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReusableCellId = @"DirectionsCell";
    DirectionsCell *cell = [localTableView dequeueReusableCellWithIdentifier:cellReusableCellId];
    if (cell == nil) {
        cell = [[DirectionsCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellReusableCellId];
    }
    Shop *shop = [shopsArr objectAtIndex:indexPath.row];
    // cell.textLabel.text = shop.SName;
    cell.nameLabel.text = shop.SName;
    
    double lat = shop.location.lat;
    double lng = shop.location.lng;
    CLLocationCoordinate2D dest = CLLocationCoordinate2DMake(lat, lng);
    // [self getDirectionsFrom:self.origin to:dest];
    [self getDirectionsFrom:self.origin to:dest forCell:cell];
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}




@end
