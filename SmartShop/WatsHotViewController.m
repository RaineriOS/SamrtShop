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
#import "WatsHotCell.h"

@interface WatsHotViewController ()

@property (strong, nonatomic) NSMutableArray *postsArr;

@end

@implementation WatsHotViewController

@synthesize postsArr;
@synthesize collectionView;
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
    [super viewWillAppear:animated];
    [postsArr removeAllObjects];
    NSString *jsonPath = @"http://localhost:3000/post";
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:jsonPath]];
    NSURLResponse *returingResponse = nil;
    NSError *connError = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                  returningResponse:&returingResponse
                                                              error:&connError];
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData // 1
                          options:kNilOptions
                          error:&error];
    
    NSDictionary *postMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"image_name", @"image_name",
                                 @"content", @"content",
                                 nil];
    for (NSDictionary *postDict in [json objectForKey:@"results"]) {
        PostFromJSON *newPost = [NSMapping makeObject:[PostFromJSON class] WithMapping:postMapping fromJSON:postDict];
        [postsArr addObject:newPost];
    }
    [collectionView reloadData];
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
    cell.contentLabel.text = [[postsArr objectAtIndex:indexPath.row] content];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [postsArr count];
}


@end
