//
//  ISSearchRecordsStore.m
//  ImageSearch
//
//  Created by Eddie Fu on 9/3/15.
//  Copyright (c) 2015 EddieFu. All rights reserved.
//

#import "ISSearchRecordsStore.h"

@implementation ISSearchRecordsStore

+ (instancetype)sharedStore
{
    static ISSearchRecordsStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] init];
    });
    return sharedStore;
}

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (NSMutableArray *)retrieveSearchRecordsArr
{
    //Init user defaults
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //For retrieving
    self.searchRecordsArray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"searchRecords"]];
    return self.searchRecordsArray;
}

- (void)handleAddSearchRecord:(NSString *)searchText;
{
    if (![self.searchRecordsArray containsObject:searchText]) {
        [self.searchRecordsArray insertObject:searchText atIndex:0];
        [self syncUserDefaults];
    }
}

- (void)handleDeleteSearchRecordWithIndex:(NSInteger)index
{
    [self.searchRecordsArray removeObjectAtIndex:index];
    [self syncUserDefaults];
}

- (void)syncUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.searchRecordsArray forKey:@"searchRecords"];
    [defaults synchronize];
}
@end
