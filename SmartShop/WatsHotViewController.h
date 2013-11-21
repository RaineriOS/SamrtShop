//
//  WatsHotViewController.h
//  SmartShop
//
//  Created by Batman on 21/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface WatsHotViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
