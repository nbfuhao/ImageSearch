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

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UICollectionView *imageCollectionView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *searchResultsTableView;
@property (nonatomic, strong) ISNetworkManager *networkManager;
@property (nonatomic, strong) NSMutableArray *imageURLsArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Image Search";
    [self setupNetworkManager];
    [self setupImageCollectionView];
    [self setupSearchBar];
    [self setupSearchResultsTableView];
}

#pragma mark - Set Up NetworkManager
- (void)setupNetworkManager
{
    self.imageURLsArray = [NSMutableArray array];
    self.networkManager = [ISNetworkManager sharedNetworkManager];
    [self.networkManager fetchImagesWithPageNumber:0 WithSearchTerm:@"football" WithCompletion:^(NSMutableArray *imageURLsArray) {
        self.imageURLsArray = imageURLsArray;
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
    [self.imageCollectionView registerClass:[imageCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    imageCollectionViewCell *cell = [self.imageCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSURL *imageURL = [self.imageURLsArray objectAtIndex:indexPath.row];
    //[cell.itemImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    //[cell.itemImageView setImage:[UIImage imageNamed:@"placeholder"]];
    cell.backgroundColor = [UIColor greenColor];
    return cell;
}

#pragma mark - Set Up searchBar
- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] init];
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

// add a cancel button in navigation bar to exit the search
- (void)setupCancelButtonWhenSearching
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(exitSearch:)];
    self.navigationItem.leftBarButtonItem = backButton;
}

// exit search and go back to image list
- (void)exitSearch:(id)sender
{
    self.searchBar.text = nil;
    [self.searchBar resignFirstResponder];
    self.navigationItem.leftBarButtonItem = nil;
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

@end
