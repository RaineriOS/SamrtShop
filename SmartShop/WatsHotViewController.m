//
//  WatsHotViewController.m
//  SmartShop
//
//  Created by Batman on 21/11/2013.
//  Copyright (c) 2013 Batman. All rights reserved.
//

#import "WatsHotViewController.h"

#import "AppDelegate.h"
#import "NSMapping.h"
#import "PostFromJSON.h"
#import "MapSnapshotsController.h"
#import "GoogleAPIShop.h"
#import "Location.h"
#import "WatsHotCell.h"

@interface WatsHotViewController ()

@property (strong, nonatomic) NSMutableArray *postsArr;
@property (strong, nonatomic) NSMutableArray *locationImageArr;
@property (strong, nonatomic) NSMutableArray *clothesImageArr;

@end

@implementation WatsHotViewController
{
    NSMutableArray *shopsArr;
}
@synthesize postsArr;
@synthesize locationImageArr;
@synthesize clothesImageArr;

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
    postsArr = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    // TODO make it run from a differnt thread
    [super viewWillAppear:animated];
    [postsArr removeAllObjects];
    NSString *jsonPath = @"http://localhost:3000/post";
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:jsonPath]];
    NSURLResponse *returingResponse = nil;
    NSError *connError = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                  returningResponse:&returingResponse
                                                              error:&connError];
    if (!responseData) {
        // Handle gracefully
        return;
    }
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData // 1
                          options:kNilOptions
                          error:&error];
    
    NSDictionary *locationMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     @"lat", @"lat",
                                     @"lng", @"lng",
                                     nil];
    NSDictionary *shopMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"SName", @"name",
                                 
                                 @{
                                   @"property": @"location", // The name in the class
                                   @"class": [Location class],
                                   @"mapping": locationMapping
                                   }, @"location",
                                 nil];
    NSDictionary *postMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"post_id", @"id",
                                 @"image_name", @"image_name",
                                 @"content", @"content",
                                 @"hot", @"hot",
                                 @"cool", @"cool",
                                 @"freezing", @"freezing",
                                 @{
                                   @"property": @"shop", // The name in the class
                                   @"class": [GoogleAPIShop class],
                                   @"mapping": shopMapping
                                   }, @"shop",
                                 nil];
    shopsArr = [[NSMutableArray alloc] init];
    clothesImageArr = [[NSMutableArray alloc] init];
    for (NSDictionary *postDict in [json objectForKey:@"results"]) {
        PostFromJSON *newPost = [NSMapping makeObject:[PostFromJSON class] WithMapping:postMapping fromJSON:postDict];
        [postsArr addObject:newPost];
        [shopsArr addObject:newPost.shop];
        NSString *urlString = [[NSString alloc] initWithFormat:@"http://localhost:3000/media/%@", newPost.image_name, nil];
        NSLog(@"%@", urlString);
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:data];
        [clothesImageArr addObject:image];
    }
    MapSnapshotsController *snapshotImages = [[MapSnapshotsController alloc] initWithShops:shopsArr withMapView:self.mapView];
    snapshotImages.delegate = self;
    locationImageArr = snapshotImages.imagesArr;
    [self.collectionView reloadData];
    [self.mapView setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View data sourece
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WatsHotCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    // cell.backgroundColor=[UIColor greenColor];
    PostFromJSON *post = [postsArr objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.post = post;
    cell.postId = post.post_id;
    cell.contentLabel.text = post.content;
    cell.shopNameLabel.text = post.shop.SName;
    cell.clothImageView.image = [clothesImageArr objectAtIndex:indexPath.row];
    cell.hotLabel.text = [NSString stringWithFormat:@"%@", post.hot];
    cell.coolLabel.text = [NSString stringWithFormat:@"%@", post.cool];
    cell.freezingLabel.text = [NSString stringWithFormat:@"%@", post.freezing];
    if ([[locationImageArr objectAtIndex:indexPath.row] isKindOfClass:[UIImage class]]) {
        cell.locationImageView.image = [locationImageArr objectAtIndex:indexPath.row];
    } else if (locationImageArr.count < indexPath.row) {
        MapSnapshotsController *snapshotImages = [[MapSnapshotsController alloc] initWithShops:shopsArr withMapView:self.mapView];
        snapshotImages.delegate = self;
        locationImageArr = snapshotImages.imagesArr;
    }
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [postsArr count];
}

-(void)updateView
{
    [self.collectionView reloadData];
}

@end
