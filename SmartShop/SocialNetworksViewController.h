//
//  SocialNetworksViewController.h
//  SmartShop
//
//  Created by Batman on 12/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SocialNetworksViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate,
    CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *shopNameTextField;
@property (strong, nonatomic) IBOutlet UITextView *textViewPostContent;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

// Take picture
- (IBAction)takePicture:(id)sender;
// Tweet the post using the account stored on the device
- (IBAction)tweet:(id)sender;
// Post it to our own server
- (IBAction)post:(id)sender;

@end
