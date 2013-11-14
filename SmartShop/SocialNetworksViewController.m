//
//  SocialNetworksViewController.m
//  SmartShop
//
//  Created by Batman on 12/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "SocialNetworksViewController.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <SBJson.h>

@interface SocialNetworksViewController ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointAnnotation *annotationView;
@end

@implementation SocialNetworksViewController

@synthesize locationManager;

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
    [[self.textViewPostContent layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.textViewPostContent layer] setBorderWidth:2.3];
    
    [[self.imageView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.imageView layer] setBorderWidth:2.3];
    
    _accountStore = [[ACAccountStore alloc] init];
    
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    // When the view of the app is clicked, remove the keyboard if it is active
    UITapGestureRecognizer *resigneKeyboardTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextViewPostContentKeyboard:)];
    resigneKeyboardTapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:resigneKeyboardTapRecognizer];

    // Map click handler
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPin:)];
    //[recognizer setNumberOfTapsRequired:1];
    [self.mapView addGestureRecognizer:recognizer];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // 100 m
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

-(void)resignTextViewPostContentKeyboard:(UIGestureRecognizer *)getureRecognizer
{
    [self.textViewPostContent resignFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated
{
}

#warning does not work with differnet orientations
- (void)keyboardDidShow: (NSNotification *) notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.scrollView.contentSize = CGSizeMake(keyboardFrameBeginRect.size.width, keyboardFrameBeginRect.size.height*3);
    /*
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35f];
    CGRect frame = self.view.frame;
    frame.origin.y = -150;
    [self.view setFrame:frame];
    [UIView commitAnimations];
    for (UIView *subview in [self.view subviews]) {
        CGRect frame = subview.frame;
        frame.origin.y = 150;
        [subview setFrame:frame];
    }
     */
}

- (void)keyboardDidHide: (NSNotification *) notification
{
    self.scrollView.contentSize = CGSizeMake(0,0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(id)sender
{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        /*
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
         */
        
    } else {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

// Post to tweeter
- (IBAction)tweet:(id)sender
{
    [self.textViewPostContent resignFirstResponder];
    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    SLRequestHandler requestHandler = ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData
                                                options:NSJSONReadingMutableContainers
                                                  error:NULL];
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
            }
            else {
                NSLog(@"[ERROR] Server responded: status code %d %@", statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        }
        else {
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
        }
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler = ^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                          @"/1.1/statuses/update_with_media.json"];
            NSDictionary *params = @{@"status" : self.textViewPostContent.text};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:url
                                                       parameters:params];
            NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 1.f);
            [request addMultipartData:imageData
                             withName:@"media[]"
                                 type:@"image/jpeg"
                             filename:@"image.jpg"];
            [request setAccount:[accounts lastObject]];
            [request performRequestWithHandler:requestHandler];
        }
        else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
        }
    };
    
    [self.accountStore requestAccessToAccountsWithType:twitterType
                                               options:NULL
                                            completion:accountStoreHandler];
}

// Post the new input from the user to our server
- (IBAction)post:(id)sender
{
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString *jsonString = [jsonWriter stringWithObject:@{@"content": self.textViewPostContent.text}];
    NSString *urlString = @"http://localhost:3000/image";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    // For when the user needs to be authenticated
    // if ([defaults objectForKey:@"UserToken"]) {
        // add the header to the request.
        // [request addValue:[defaults objectForKey:@"UserToken"] forHTTPHeaderField:@"token"];
    // }
    
    NSString *boundary = @"14737809831466499882746641449"; // Randomly generated
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"body\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/json\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"recording\"; filename=\"test.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:UIImageJPEGRepresentation(self.imageView.image, 1.0)];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    // send the request (submit the form) and get the response
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", returnString);

}

- (IBAction)pickPosition:(id)sender
{
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 140) {
        textView.text = [textView.text substringToIndex:140];
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
   if (self.annotationView)
       [self.mapView removeAnnotation:self.annotationView];
    self.annotationView = [[MKPointAnnotation alloc] init];
    self.annotationView.coordinate = location.coordinate;
    [self placeAnnotationOnMap:self.annotationView];
}

#pragma mark - update map view UI
// Add pin to the map
- (void)addPin:(UITapGestureRecognizer*)recognizer
{
    [self.locationManager stopUpdatingLocation];
    CGPoint tappedPoint = [recognizer locationInView:self.mapView];
    NSLog(@"Tapped At : %@",NSStringFromCGPoint(tappedPoint));
    CLLocationCoordinate2D coord= [self.mapView convertPoint:tappedPoint toCoordinateFromView:self.mapView];
    NSLog(@"lat  %f",coord.latitude);
    NSLog(@"long %f",coord.longitude);
    MKPointAnnotation *annotationView = [[MKPointAnnotation alloc] init];
    annotationView.coordinate = CLLocationCoordinate2DMake(coord.latitude, coord.longitude);
    if (self.annotationView)
        [self.mapView removeAnnotation:self.annotationView];
    self.annotationView = annotationView;
    [self placeAnnotationOnMap:self.annotationView];
    // add an annotation with coord
}

-(void)placeAnnotationOnMap:(MKPointAnnotation *)annotationView
{
    [self.mapView addAnnotation:(id)annotationView];
    
    MKMapCamera *camera = [MKMapCamera
                           cameraLookingAtCenterCoordinate:annotationView.coordinate
                           fromEyeCoordinate:annotationView.coordinate
                           eyeAltitude:70000.0];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.mapView setCamera:camera];
    }];
}
@end
