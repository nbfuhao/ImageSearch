//
//  ViewController.m
//  ImageSearch
//
//  Created by Admim on 6/5/15.
//  Copyright (c) 2015 EddieFu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UISearchControllerDelegate>
@property (nonatomic, strong) UICollectionView *imageCollectionView;
@property (nonatomic, strong) UIBarButtonItem *searchItem;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Image Search";
    [self setupImageCollectionView];
    [self setupSearchBarItem];
}

#pragma mark - Set Up imageCollectionVC
- (void)setupImageCollectionView
{
    // set a flow layout for the collection view
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setItemSize:CGSizeMake(100, 100)];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [aFlowLayout setMinimumInteritemSpacing:5];
    [aFlowLayout setSectionInset:UIEdgeInsetsMake(15, 5, 15, 5)];
    
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
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"imageCell";
    [self.imageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    UICollectionViewCell *cell = [self.imageCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - Set Up Search BarItem
- (void)setupSearchBarItem
{
    self.searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                    target:self
                                                                    action:@selector(activateSearch:)];
    self.navigationItem.rightBarButtonItem = self.searchItem;
}

- (void)activateSearch:(id)sender
{
    NSLog(@"search btn clicked");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
