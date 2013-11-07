//
//  RootViewController.m
//  SmartShop
//
//  Created by Batman on 05/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "RootViewController.h"
#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController ()

@property (strong, nonatomic) MKPointAnnotation *currentPointAnnotation;

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
            
            // Send a synchronous request
            NSString *jsonPath = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=10000&types=clothing_store&sensor=false&key=AIzaSyAw0m3prCKzqP-zrWauU7DsXJgMDnbQY-Y",
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
                    shopsArr = [json objectForKey:@"results"];
                    [tableView reloadData];
                }];
            }
        }];
    }];
}

# pragma mark - Map view segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRestaurant"]) {
        self.mapView = [[segue destinationViewController] mapView];
        MapViewController *mapVC = [segue destinationViewController];
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
    static NSString *cellReusableCellId = @"Cell";
    UITableViewCell *cell = [localTableView dequeueReusableCellWithIdentifier:cellReusableCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReusableCellId];
    }
    cell.textLabel.text = [[shopsArr objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", [shopsArr objectAtIndex:indexPath.row]);
    NSDictionary *shop = [shopsArr objectAtIndex:indexPath.row];
    
    // show the location
    MKPointAnnotation *annotationView = [[MKPointAnnotation alloc] init];
    
    double lat = [[[[shop objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
    double lng = [[[[shop objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
    
    annotationView.coordinate = CLLocationCoordinate2DMake(lat, lng);
    
    self.currentPointAnnotation = annotationView;
    /*
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[annotation.lat doubleValue] longitude:[restaurant.lng doubleValue]];
        // Setting the geo coder
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        // Get the current address
        [geocoder reverseGeocodeLocation:location
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           // Get current address
                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                           
                           NSMutableString * str = [[NSMutableString alloc] init];
                           for (NSString *s in [placemark.addressDictionary objectForKey:@"FormattedAddressLines"]) {
                               [str appendString:s];
                               [str appendString:@", "];
                           }
                           restaurant.address = [[NSString alloc] initWithString:str];
                           annotation.subtitle = restaurant.address;
                           annotation.restaurant = restaurant;
                       }];
    */
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}




@end
