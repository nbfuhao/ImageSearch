//
//  ViewController.m
//  ImageSearch
//
//  Created by Admim on 6/5/15.
//  Copyright (c) 2015 EddieFu. All rights reserved.
//

#import "ViewController.h"
#import "ISNetworkManager.h"
#import "imageCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Reachability/Reachability.h>
#import "ISSearchRecordsTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ISSearchRecordsStore.h"
#import "ISSearchViewController.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, SearchViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *searchRecordsTableView;
@property (nonatomic, strong) ISNetworkManager *networkManager;
@property (nonatomic, strong) NSMutableArray *imageURLsArray;
@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic, strong) NSMutableArray *searchRecordsArray;
@property (nonatomic, assign) int page;
@property (nonatomic, assign) BOOL noMoreItems;
@property (nonatomic, strong) ISSearchRecordsStore *sharedStore;
@property (nonatomic, strong) ISSearchViewController *searchVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL isReachable = [self checkReachability];
    if (isReachable) {
        [self initVariables];
        self.sharedStore = [ISSearchRecordsStore sharedStore];
        [self setupImageCollectionView];
        [self setupSearchBar];
    }
}

#pragma mark - check reachability
-(BOOL)checkReachability
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return reachability.isReachable;
}

#pragma mark - Initialize Variables
- (void)initVariables
{
    self.noMoreItems = false;
    self.page = 0;
    self.imageURLsArray = [NSMutableArray array];
    self.networkManager = [ISNetworkManager sharedNetworkManager];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.searchVC = [sb instantiateViewControllerWithIdentifier:@"searchVC"];
    self.searchVC.delegate = self;
}

#pragma mark - Load Images
- (void)loadImages
{
    [self.networkManager fetchImagesWithPageNumber:self.page WithSearchTerm:self.searchTerm WithCompletion:^(NSMutableArray *imageURLsArray) {
        if (imageURLsArray.count == 0) {
            // Change the noMoreItems flag if the returned array is empty
            self.noMoreItems = true;
        } else {
            NSMutableArray *indexPathsArray = [NSMutableArray array];
            NSInteger previousRowCount = self.imageURLsArray.count;
            for (int i = 0; i < imageURLsArray.count; i++ ) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:previousRowCount+i inSection:0];
                [indexPathsArray addObject:indexPath];
            }
            [self.imageURLsArray addObjectsFromArray:imageURLsArray];
            [self.imageCollectionView insertItemsAtIndexPaths:indexPathsArray];
        }
    }];
}

#pragma mark - Set Up imageCollectionVC
- (void)setupImageCollectionView
{
    // Set a flow layout for the collection view
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setItemSize:CGSizeMake(96,96)];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [aFlowLayout setMinimumInteritemSpacing:10];
    [aFlowLayout setMinimumLineSpacing:15];
    [aFlowLayout setSectionInset:UIEdgeInsetsMake(15, 4, 15, 4)];
    
    // Initialize collection view
//    self.imageCollectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:aFlowLayout];
    self.imageCollectionView.delegate = self;
    self.imageCollectionView.dataSource = self;
    [self.imageCollectionView setBackgroundColor:[UIColor blackColor]];
    
    // Register the custom collection view cell with the view
    UINib *liveNib = [UINib nibWithNibName:@"imageCollectionViewCell" bundle:nil];
    [self.imageCollectionView registerNib:liveNib forCellWithReuseIdentifier:@"imageCell"];
    [self.view addSubview:self.imageCollectionView];
}

#pragma mark - UICollectionView Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageURLsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"imageCell";
    imageCollectionViewCell *cell = [self.imageCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSURL *imageURL = [self.imageURLsArray objectAtIndex:indexPath.row];
    [cell.loadingIndicator startAnimating];
    [cell.itemImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder"] completed: ^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell.loadingIndicator stopAnimating];
        NSLog(@"ended loading");
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0);
{
    NSInteger lastSectionIndex = [collectionView numberOfSections] - 1;
    NSInteger lastRowIndex = [collectionView numberOfItemsInSection:lastSectionIndex] - 4;
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex) && (!self.noMoreItems)) {
        // This is the last cell
        [self loadMore];
    }
}

// Load more images by incrementing page number
- (void)loadMore
{
    self.page += 1;
    [self loadImages];
}

#pragma mark - Set Up searchBar
- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] init];
    // As required by the Google Image Search API docs
    self.searchBar.placeholder = @"Powered by Google";
    self.searchBar.delegate = self;
    [self.navigationItem setTitleView:self.searchBar];
}

#pragma mark - UISearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchVC.modalPresentationStyle = UIModalPresentationFormSheet;
    self.searchVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:self.searchVC animated:YES completion:nil];
}

#pragma mark - ISSearchViewController Delegate
- (void)searchViewControllerDidGetSearchTerm:(ISSearchViewController *)searchViewController term:(NSString *)term
{
    self.searchTerm = term;
    [self.imageURLsArray removeAllObjects];
    [self.imageCollectionView reloadData];
    [self.networkManager.searchManager.operationQueue cancelAllOperations];
    self.page = 0;
    self.searchBar.text = term;
    [self loadImages];
}

// Delete search record from NSUserDefaults
- (void)deleteRecordHandler:(UIButton *)button
{
    [self.sharedStore handleDeleteSearchRecordWithIndex:button.tag];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    [self.searchRecordsTableView beginUpdates];
    [self.searchRecordsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.searchRecordsTableView endUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
