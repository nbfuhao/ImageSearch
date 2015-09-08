//
//  ISSearchViewController.m
//  ImageSearch
//
//  Created by Eddie Fu on 9/7/15.
//  Copyright (c) 2015 EddieFu. All rights reserved.
//

#import "ISSearchViewController.h"
#import "ISSearchRecordsStore.h"
#import "ISSearchRecordsTableViewCell.h"
@interface ISSearchViewController()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
- (IBAction)closeButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchRecordsTableView;
@property (nonatomic, strong) NSMutableArray *searchRecordsArray;
@property (nonatomic, strong) ISSearchRecordsStore *sharedStore;

@end

@implementation ISSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sharedStore = [ISSearchRecordsStore sharedStore];
    self.searchBar.delegate = self;
    self.searchRecordsTableView.dataSource = self;
    self.searchRecordsTableView.delegate = self;
    [self retrieveSearchRecordsArr];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
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
    [self endSearchHandler];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma makr - Search Bar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self retrieveSearchRecordsArr];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self endSearchHandler];
}

#pragma mark - helper methods
- (void)retrieveSearchRecordsArr
{
    self.searchRecordsArray = [self.sharedStore retrieveSearchRecordsArr];
    [self.searchRecordsTableView reloadData];
}

- (void)deleteRecordHandler:(UIButton *)button
{
    [self.sharedStore handleDeleteSearchRecordWithIndex:button.tag];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    [self.searchRecordsTableView beginUpdates];
    [self.searchRecordsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.searchRecordsTableView endUpdates];
}

- (void)endSearchHandler
{
    [self.sharedStore handleAddSearchRecord:self.searchBar.text];
    [self.searchBar resignFirstResponder];
    [self.delegate searchViewControllerDidGetSearchTerm:self term:self.searchBar.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
