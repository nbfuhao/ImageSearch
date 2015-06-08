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

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UICollectionView *imageCollectionView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *searchRecordsTableView;
@property (nonatomic, strong) ISNetworkManager *networkManager;
@property (nonatomic, strong) NSMutableArray *imageURLsArray;
@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic, strong) NSMutableArray *searchRecordsArray;
@property (nonatomic, assign) int page;
@property (nonatomic, assign) BOOL noMoreItems;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL isReachable = [self checkReachability];
    if (isReachable) {
        [self initVariables];
        [self setupImageCollectionView];
        [self setupSearchBar];
        [self setupSearchResultsTableView];
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
}

#pragma mark - Load Images
- (void)loadImages
{
    [self.networkManager fetchImagesWithPageNumber:self.page WithSearchTerm:self.searchTerm WithCompletion:^(NSMutableArray *imageURLsArray) {
        if (imageURLsArray.count == 0) {
            // Change the noMoreItems flag if the returned array is empty
            self.noMoreItems = true;
        } else {
            [self.imageURLsArray addObjectsFromArray:imageURLsArray];
            [self.imageCollectionView reloadData];
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
    self.imageCollectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:aFlowLayout];
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
    [cell.itemImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
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
    [self.searchBar sizeToFit];
    [self.navigationItem setTitleView:self.searchBar];
}

#pragma mark - UISearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // Check if the view already contains the results table view
    if (![self.searchRecordsTableView isDescendantOfView:self.view]) {
        [self.view addSubview:self.searchRecordsTableView];
        [self setupCancelButtonWhenSearching];
        [self retrieveSearchRecordsArr];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searchTerm = self.searchBar.text;
    [self endSearchHandler];
}

// Get history search records from NSUserdefaults
- (void)retrieveSearchRecordsArr
{
    //Init user defaults
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //For retrieving
    self.searchRecordsArray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"searchRecords"]];
    [self.searchRecordsTableView reloadData];
}

// End search will
//  1, reload collection view with new images
//  2, initialize the variables, including page number and navigation bar
//  3, add search term to NSUserDefaults
//  4, remove search table view
- (void)endSearchHandler
{
    [self.imageURLsArray removeAllObjects];
    [self.imageCollectionView reloadData];
    self.page = 0;
    [self loadImages];
    self.noMoreItems = false;
    self.navigationItem.rightBarButtonItem = nil;
    [self handleAddSearchRecord];
    [self.searchBar resignFirstResponder];
    [self.searchRecordsTableView removeFromSuperview];
}

// Add search term to NSUserDefaults
- (void) handleAddSearchRecord {
    if (![self.searchRecordsArray containsObject:self.searchBar.text]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [self.searchRecordsArray insertObject:self.searchBar.text atIndex:0];
        [defaults setObject:self.searchRecordsArray forKey:@"searchRecords"];
        [defaults synchronize];
    }
}

// Add a cancel button in navigation bar to exit the search
- (void)setupCancelButtonWhenSearching
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(exitSearch:)];
    self.navigationItem.rightBarButtonItem = backButton;
}

// Exit search and go back to image list
- (void)exitSearch:(id)sender
{
    self.searchBar.text = nil;
    [self.searchBar resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
    [self.searchRecordsTableView removeFromSuperview];
}

#pragma mark - set up searchResultsTableView
// initialize searchResultsTableView
- (void)setupSearchResultsTableView
{
    CGRect frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    self.searchRecordsTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.searchRecordsTableView.delegate = self;
    self.searchRecordsTableView.dataSource = self;
}

#pragma mark - UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchRecordsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"searchResultsCell";
    [tableView registerNib:[UINib nibWithNibName:@"ISSearchRecordsTableViewCell" bundle:NULL] forCellReuseIdentifier:cellIdentifier];

    ISSearchRecordsTableViewCell *cell = (ISSearchRecordsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ISSearchRecordsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *searchRecord = [self.searchRecordsArray objectAtIndex:indexPath.row];
    cell.searchRecordLabel.text = searchRecord;
    cell.deleteButton.tag = indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deleteRecordHandler:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *searchRecord = [self.searchRecordsArray objectAtIndex:indexPath.row];
    self.searchBar.text = searchRecord;
    self.searchTerm = searchRecord;
    [self endSearchHandler];
}

// Delete search record from NSUserDefaults
- (void)deleteRecordHandler:(UIButton *)button
{
    [self.searchRecordsArray removeObjectAtIndex:button.tag];
    [self.searchRecordsTableView reloadData];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.searchRecordsArray forKey:@"searchRecords"];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
