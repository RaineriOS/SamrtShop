//
//  RootViewController.h
//  SmartShop
//
//  Created by Batman on 05/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *shopsArr;


@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *locationTextField;
- (IBAction)searchForShops:(id)sender;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
