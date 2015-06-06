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

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UICollectionView *imageCollectionView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *searchResultsTableView;
@property (nonatomic, strong) ISNetworkManager *networkManager;
@property (nonatomic, strong) NSMutableArray *imageURLsArray;
@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic, assign) int page;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Image Search";
    BOOL isReachable = [self checkReachability];
    if (isReachable) {
        [self initVariables];
        //[self loadImages];
        [self setupImageCollectionView];
        [self setupSearchBar];
        [self setupSearchResultsTableView];
    } else {
        [self noInternetHandler];
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
    self.page = 0;
    self.imageURLsArray = [NSMutableArray array];
    self.networkManager = [ISNetworkManager sharedNetworkManager];
}

#pragma mark - Set Up NetworkManager
- (void)loadImages
{
    [self.networkManager fetchImagesWithPageNumber:self.page WithSearchTerm:self.searchTerm WithCompletion:^(NSMutableArray *imageURLsArray) {
        NSLog(@"imageurls array. %@", imageURLsArray);
        [self.imageURLsArray addObjectsFromArray:imageURLsArray];
        [self.imageCollectionView reloadData];
    }];
}

#pragma mark - Set Up imageCollectionVC
- (void)setupImageCollectionView
{
    // set a flow layout for the collection view
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setItemSize:CGSizeMake(115, 115)];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [aFlowLayout setMinimumInteritemSpacing:10];
    [aFlowLayout setMinimumLineSpacing:45];
    [aFlowLayout setSectionInset:UIEdgeInsetsMake(15, 4, 15, 4)];
    
    // initialize collection view
    self.imageCollectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:aFlowLayout];
    self.imageCollectionView.delegate = self;
    self.imageCollectionView.dataSource = self;
    [self.imageCollectionView setBackgroundColor:[UIColor blackColor]];
    
    // register the custom collection view cell with the view
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
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        // This is the last cell
        [self loadMore];
    }
}

- (void)loadMore
{
    self.page += 1;
    [self loadImages];
}

#pragma mark - Set Up searchBar
- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"Powered by Google";
    self.searchBar.delegate = self;
    [self.searchBar sizeToFit];
    [self.navigationItem setTitleView:self.searchBar];
}

#pragma mark - UISearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (![self.searchResultsTableView isDescendantOfView:self.view]) {
        [self.view addSubview:self.searchResultsTableView];
        [self setupCancelButtonWhenSearching];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searchTerm = searchBar.text;
    [self.imageURLsArray removeAllObjects];
    [self.imageCollectionView reloadData];
    [self.searchBar resignFirstResponder];
    self.page = 0;
    [self.searchResultsTableView removeFromSuperview];
    [self loadImages];
}

// add a cancel button in navigation bar to exit the search
- (void)setupCancelButtonWhenSearching
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(exitSearch:)];
    self.navigationItem.rightBarButtonItem = backButton;
}

// exit search and go back to image list
- (void)exitSearch:(id)sender
{
    self.searchBar.text = nil;
    [self.searchBar resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
    [self.searchResultsTableView removeFromSuperview];
}

#pragma mark - set up searchResultsTableView
// initialize searchResultsTableView
- (void)setupSearchResultsTableView
{
    CGRect frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    self.searchResultsTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.searchResultsTableView.delegate = self;
    self.searchResultsTableView.dataSource = self;
}

#pragma mark - UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"searchResultsCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = @"search result";
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)noInternetHandler
{
    UILabel *noInternetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 30)];
    noInternetLabel.text = @"Cannot connect to internet";
    [self.view addSubview:noInternetLabel];
}

@end
