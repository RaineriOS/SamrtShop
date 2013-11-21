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
#import <SBJson.h>

#import "AppDelegate.h"
#import "Shop.h" // The shop for core data
#import "LoginViewController.h"
#import "StepByStepRouteViewController.h"
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
#import "MapSnapshotsController.h"


@interface RootViewController ()

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
@synthesize delegate;

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
            RouteController *findRoutes = [[RouteController alloc]
                                           initWithShops:shopController.shopsArr
                                           andLocation:origin];
            findRoutes.delegate = self;
            directionModelsArr = findRoutes.routesArr;
            MapSnapshotsController *snapshotImages = [[MapSnapshotsController alloc]
                                                      initWithShops:shopController.shopsArr
                                                      withMapView:self.mapView];
            snapshotImages.delegate = self;
            imagesArr = snapshotImages.imagesArr;
        }];
    }];
}

# pragma mark - Map view segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowRoute"]) {
        DirectionCellModel *directionModel = [directionModelsArr objectAtIndex:tableView.indexPathForSelectedRow.row];
        if ([directionModel isKindOfClass:[DirectionCellModel class]]) {
            
            GoogleAPIShop *shop = [directionModel shop];
            
            // show the location
            MKPointAnnotation *annotationView = [[MKPointAnnotation alloc] init];
            annotationView.coordinate = CLLocationCoordinate2DMake(shop.location.lat, shop.location.lng);
            delegate = [segue destinationViewController];
            if ([delegate respondsToSelector:@selector(drawAndDirectRoute:withDestinationAnnotation:)])
                [delegate drawAndDirectRoute:directionModel.routes withDestinationAnnotation:annotationView];
        }
    }
}

// Don't perform the segue if the routes have not been recieived from the server
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    DirectionCellModel *directionModel = [directionModelsArr objectAtIndex:tableView.indexPathForSelectedRow.row];
    if ([directionModel isKindOfClass:[DirectionCellModel class]])
        return YES;
    return NO;
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
    
    if (directionModelsArr.count > indexPath.row &&
        [[directionModelsArr objectAtIndex:indexPath.row] isKindOfClass:[DirectionCellModel class]]) {
        DirectionCellModel *cellModel = [directionModelsArr objectAtIndex:indexPath.row];
        cell.nameLabel.text = cellModel.shop.SName;
        cell.originLabel.text = cellModel.origin;
        cell.destinationLabel.text = cellModel.destination;
        cell.distanceLabel.text = cellModel.distance;
        cell.durationLabel.text = cellModel.duration;
        [cell.tryAgainLabel setHidden:YES];
        [cell.mapImage setHidden:NO];
    } else {
        cell.nameLabel.text = @"";
        cell.originLabel.text = @"";
        cell.destinationLabel.text = @"";
        cell.distanceLabel.text = @"";
        cell.durationLabel.text = @"";
        [cell.tryAgainLabel setHidden:NO];
        [cell.mapImage setHidden:YES];
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

#pragma mark - RootViewDelegate
-(void)updateTableView
{
    [tableView reloadData];
}




@end
