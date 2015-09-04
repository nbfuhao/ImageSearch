//
//  ISSearchRecordsStore.h
//  ImageSearch
//
//  Created by Eddie Fu on 9/3/15.
//  Copyright (c) 2015 EddieFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISSearchRecordsStore : NSObject
@property (nonatomic, strong) NSMutableArray *searchRecordsArray;

+(instancetype)sharedStore;
- (NSMutableArray *)retrieveSearchRecordsArr;
- (void)handleAddSearchRecord:(NSString *)searchText;
- (void)handleDeleteSearchRecordWithIndex:(NSInteger)index;

@end
