//
//  MapViewController.m
//  SmartShop
//
//  Created by Batman on 06/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "StepByStepRouteViewController.h"
#import "Location.h"

@interface StepByStepRouteViewController ()

@property (strong, nonatomic) MKPolyline *routeLine;
@property (strong, nonatomic) MKPolylineView *routeLineView;

@end

@implementation StepByStepRouteViewController
{
    int index;
    NSArray *colors;
    NSMutableArray *overlays;
    NSArray *stepsArr;
}

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
    [self.mapView setShowsUserLocation:YES];
    index = 0;
    colors = @[[UIColor blackColor], [UIColor blueColor], [UIColor redColor], [UIColor redColor]];
    overlays = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)drawAndDirectRoute:(NSArray *) routeArr withDestinationAnnotation:(MKPointAnnotation *)annotationView;
{
    self.locationArray = routeArr;
    self.pointAnnotation = annotationView;
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.locationArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        MKRoute *route = obj;
        
        MKPolyline *line = [route polyline];
        [self.mapView addOverlay:line];
        
        stepsArr = [route steps];
    }];
    
    [self placeAnnotationOnMap:self.pointAnnotation];
}


#pragma mark - MKDelegate for rendering paths

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]
                                        initWithPolyline:(MKPolyline*)overlay];
        renderer.strokeColor = [UIColor redColor];
        renderer.strokeColor = [colors objectAtIndex:index];
        index = index == 3 ? 0 : index+1;
        renderer.lineWidth = 1;
        [overlays addObject:renderer];
        return renderer;
    }
    return nil;
}

-(void)removeOverlays
{
    [self.mapView removeOverlays:overlays];
    [overlays removeAllObjects];
}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stepsArr count];
}

-(UITableViewCell *)tableView:(UITableView *)localTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReusableCellId = @"DirectionsCell";
    UITableViewCell *cell = [localTableView dequeueReusableCellWithIdentifier:cellReusableCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellReusableCellId];
    }
    
    cell.textLabel.text = [[stepsArr objectAtIndex:indexPath.row] instructions];
    
    return cell;
}

#pragma mark - UITableViewDataDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLLocationCoordinate2D stepCoordinate = [[[stepsArr objectAtIndex:indexPath.row] polyline] coordinate];
    MKMapCamera *camera = [MKMapCamera
                           cameraLookingAtCenterCoordinate:stepCoordinate
                           fromEyeCoordinate:stepCoordinate
                           eyeAltitude:500.0];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.mapView setCamera:camera];
    }];
}


#pragma mark- Google API decode string into smooth routes
// Google decode the google smoth path
+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString
{
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
    free(coords);
    
    return polyline;
}



@end
