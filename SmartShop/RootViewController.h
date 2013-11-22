//
//  RootViewController.h
//  SmartShop
//
//  Created by Batman on 05/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "StepByStepRouteViewController.h"
#import "UpdateViewDelegate.h"


// This is the first view shown, controller which handles searching for shops close to a given location
@interface RootViewController : UIViewController <UpdateViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutlet id<StepByStepRouteViewDelegate> delegate;
- (IBAction)searchForShops:(id)sender;

// The mapview used to generate the images of each cell
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
