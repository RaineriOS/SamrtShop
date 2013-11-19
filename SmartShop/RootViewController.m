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

#import "LoginViewController.h"
#import "MapViewController.h"
#import "DirectionsCell.h"
#import "GoogleAPIShop.h"
#import "Photo.h"
#import "Route.h"
#import "Leg.h" 
#import "Step.h"
#import "Location.h"
#import "NSMapping.h"


@interface RootViewController ()

@property (strong, nonatomic) MKPointAnnotation *currentPointAnnotation;
@property (strong, nonatomic) NSMutableArray *routes;
@property (strong, nonatomic) NSMutableArray *tableCellInfoArr;
@property (assign, nonatomic) CLLocationCoordinate2D origin;

@end

@implementation RootViewController
{
    NSMutableArray *images;
}

@synthesize tableCellInfoArr;
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
    images = [[NSMutableArray alloc] init];
    shopsArr = [[NSMutableArray alloc] init];
    tableCellInfoArr = [[NSMutableArray alloc] init];
    self.routes = [[NSMutableArray alloc] init];
    [self.mapView setHidden:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Username: %@", [userDefaults valueForKey:@"username"]);
    if ([[userDefaults valueForKey:@"username"] isEqualToString:@""]) {
        UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary
                                                             objectForKey:@"UIMainStoryboardFile"]
                                                     bundle:[NSBundle mainBundle]];
        LoginViewController *loginViewController = [st instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchForShops:(id)sender
{
    [tableCellInfoArr removeAllObjects];
    [images removeAllObjects];
    [self.routes removeAllObjects];
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
                        GoogleAPIShop *newShop = [NSMapping makeObject:[GoogleAPIShop class] WithMapping:shopMapping fromJSON:shopDict];
                        [shopsArr addObject:newShop];
                        double lat = newShop.location.lat;
                        double lng = newShop.location.lng;
                        CLLocationCoordinate2D dest = CLLocationCoordinate2DMake(lat, lng);
                        [self appleGetDirectionsFrom:self.origin to:dest completionBlock:^(MKDirectionsResponse *response){
                                   MKRoute *route = [[response routes] lastObject];
                            NSDictionary *cellInfo = @{
                                                       @"originLabel": response.source.name,
                                                       @"destinationLabel": response.destination.name,
                                                       @"distanceLabel": [[NSString alloc] initWithFormat:@"%0.2f m", route.distance, nil],
                                                       @"durationLabel":[[NSString alloc] initWithFormat:@"%0.0f minutes", route.expectedTravelTime/60, nil]
                                                       };
                            [tableCellInfoArr addObject:cellInfo];
                            [tableView reloadData];
                        }];
                        [self createImage:dest completionblock:^{
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [tableView reloadData];
                            });
                        }];
                    }
                }];
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
    [self.routes removeAllObjects];
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
        
        NSLog(@"response = %@",response);
        // block(response);
        handleResponse(response);
        NSArray *arrRoutes = [response routes];
        [self.routes addObjectsFromArray:arrRoutes];
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

#pragma Get Directions From Googles API

// Get directions from an origin to a destination, using google's API
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
                    
                    MKPolyline *line = [MapViewController polylineWithEncodedString:newRoute.overviewPolylinePointsEncoded];
                    // [self.routes addObject:mkRouteSteps];
                    [self.routes addObject:line];
                }
            }];
        }
    }];
}


# pragma mark - Map view segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRestaurant"]) {
        
        GoogleAPIShop *shop = [shopsArr objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        // show the location
        MKPointAnnotation *annotationView = [[MKPointAnnotation alloc] init];
        double lat = shop.location.lat;
        double lng = shop.location.lng;
        // NSLog(@"%f %f %i", lat, lng, self.tableView.indexPathForSelectedRow.row);
        NSLog(@"%i", self.tableView.indexPathForSelectedRow.row);
        annotationView.coordinate = CLLocationCoordinate2DMake(lat, lng);
        self.currentPointAnnotation = annotationView;
        
        MapViewController *mapVC = [segue destinationViewController];
        [mapVC removeOverlays];
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
    GoogleAPIShop *shop = [shopsArr objectAtIndex:indexPath.row];
    // cell.textLabel.text = shop.SName;
    cell.nameLabel.text = shop.SName;
    
    if (tableCellInfoArr.count > indexPath.row) {
        NSDictionary *cellInfo = [tableCellInfoArr objectAtIndex:indexPath.row];
        cell.originLabel.text = [cellInfo objectForKey:@"originLabel"];
        cell.destinationLabel.text = [cellInfo objectForKey:@"destinationLabel"];
        cell.distanceLabel.text = [cellInfo objectForKey:@"distanceLabel"];
        cell.durationLabel.text = [cellInfo objectForKey:@"durationLabel"];
    }
    if (images.count > indexPath.row) {
        cell.mapImage.image = [images objectAtIndex:indexPath.row];
    }
    
    
    return cell;
}

// Based on a given destination, create an image in the mapview and take a snapshot of it
-(void)createImage:(CLLocationCoordinate2D) dest completionblock:(void(^)())block
{
    
       //[self getDirectionsFrom:self.origin to:dest forCell:cell];
       // Camera snap shot thing
    MKMapCamera *camera = [MKMapCamera
                           cameraLookingAtCenterCoordinate:dest
                           fromEyeCoordinate:dest
                           eyeAltitude:500.0];
    
    [self.mapView setCamera:camera];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.mapView.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = self.mapView.frame.size;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        
        // get the image associated with the snapshot
        UIImage *image = snapshot.image;
        
        // Get a standard annotation view pin. Clearly, Apple assumes that we'll only want to draw standard annotation pins!
        MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
        UIImage *pinImage = pin.image;
        
        // ok, let's start to create our final image
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        
        // first, draw the image from the snapshotter
        [image drawAtPoint:CGPointMake(0, 0)];
        
        // CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
        CGPoint point = [snapshot pointForCoordinate:dest];
        CGPoint pinCenterOffset = pin.centerOffset;
        point.x -= pin.bounds.size.width / 2.0;
        point.y -= pin.bounds.size.height / 2.0;
        point.x += pinCenterOffset.x;
        point.y += pinCenterOffset.y;
        
        [pinImage drawAtPoint:point];
        
        // grab the final image
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [images addObject:finalImage];
        if (block)
            block();
    }];
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
