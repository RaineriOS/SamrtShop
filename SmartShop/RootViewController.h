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

@protocol RootViewDelegate <NSObject>

@required
-(void) updateTableView;

@end

@interface RootViewController : UIViewController <RootViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutlet id<StepByStepRouteViewDelegate> delegate;
- (IBAction)searchForShops:(id)sender;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
