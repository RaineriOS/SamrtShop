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
#import "DirectionCellModel.h"
#import "ShopController.h"
#import "GoogleAPIShop.h"
#import "Photo.h"
#import "Route.h"
#import "Leg.h" 
#import "Step.h"
#import "Location.h"
#import "NSMapping.h"
#import "RouteController.h"
#import "MapSnapShotsController.h"


@interface RootViewController ()

@property (strong, nonatomic) MKPointAnnotation *currentPointAnnotation;
@property (strong, atomic) NSMutableArray *directionModelsArr;
@property (strong, atomic) NSMutableArray *imagesArr;

@property (strong, nonatomic) NSMutableArray *routesArr;
@property (assign, nonatomic) CLLocationCoordinate2D origin;

@end

@implementation RootViewController


@synthesize directionModelsArr;
@synthesize imagesArr;
@synthesize tableView;
@synthesize locationTextField;

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
    imagesArr = [[NSMutableArray alloc] init];
    directionModelsArr = [[NSMutableArray alloc] init];
    self.routesArr = [[NSMutableArray alloc] init];
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

-(IBAction)searchForShops:(id)sender
{
    [directionModelsArr removeAllObjects];
    [imagesArr removeAllObjects];
    [self.routesArr removeAllObjects];
    NSString *city = self.locationTextField.text;
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:city completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        CLLocationCoordinate2D origin = placemark.location.coordinate;
        ShopController *shopController = [[ShopController alloc] init];
        [shopController searchForShops:origin completionBlock:^{
            RouteController *findRoutes = [[RouteController alloc] initWithShops:shopController.shopsArr andLocation:origin];
            directionModelsArr = findRoutes.routesArr;
            MapSnapShotsController *snapshotImages = [[MapSnapShotsController alloc] initWithShops:shopController.shopsArr withMapView:self.mapView];
            imagesArr = snapshotImages.imagesArr;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [tableView reloadData];
            });
        }];
    }];
}

# pragma mark - Map view segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRestaurant"]) {
        GoogleAPIShop *shop = [[directionModelsArr objectAtIndex:tableView.indexPathForSelectedRow.row] shop];
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
        // mapVC.locationArray = @[[self.routesArr objectAtIndex:tableView.indexPathForSelectedRow.row]];
        [mapVC setPointAnnotation:self.currentPointAnnotation];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [directionModelsArr count];
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
    
    if ([[directionModelsArr objectAtIndex:indexPath.row] isKindOfClass:[DirectionCellModel class]]) {
        DirectionCellModel *cellModel = [directionModelsArr objectAtIndex:indexPath.row];
        cell.nameLabel.text = cellModel.shop.SName;
        cell.originLabel.text = cellModel.origin;
        cell.destinationLabel.text = cellModel.destination;
        cell.distanceLabel.text = cellModel.distance;
        cell.durationLabel.text = cellModel.duration;
    }
    if ([[imagesArr objectAtIndex:indexPath.row] isKindOfClass:[UIImage class]]) {
        cell.mapImage.image = [imagesArr objectAtIndex:indexPath.row];
    }
    
    
    return cell;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}




@end
