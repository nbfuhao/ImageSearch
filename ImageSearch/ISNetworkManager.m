//
//  ISNetworkManager.m
//  ImageSearch
//
//  Created by Admim on 6/5/15.
//  Copyright (c) 2015 EddieFu. All rights reserved.
//

#import "ISNetworkManager.h"

#define kBaseImageURL @"https://ajax.googleapis.com/ajax/services/search/images"

@implementation ISNetworkManager

// Create a singleton object
+ (id)sharedNetworkManager
{
    static ISNetworkManager *sharedNetworkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetworkManager = [[self alloc] init];
    });
    return sharedNetworkManager;
}

- (id)init {
    if (self = [super init]) {
        self.searchManager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}

// Fetch image URLS using AFNetworking
- (void)fetchImagesWithPageNumber:(int)page WithSearchTerm:(NSString *)searchTerm WithCompletion:(void (^)(NSMutableArray *imageURLsArray))completion
{
    // Make sure the images do not overlap
    NSString *pageNumber = [NSString stringWithFormat:@"%d", page*8];
    [self.searchManager GET:kBaseImageURL parameters:@{
                                           @"q": searchTerm,
                                           @"v": @"1.0",
                                           @"rsz": @"8",
                                           @"start": pageNumber,
                                           @"as_filetype":@"jpg",
                                           @"imgsz":@"small"
                                           }
         success:^(AFHTTPRequestOperation *operation, id responseObject){
             NSMutableArray *imageURLsArray = [NSMutableArray array];
             NSDictionary *responseDic = responseObject[@"responseData"];
             if (![responseDic isKindOfClass:[NSNull class]]) {
                 NSDictionary *resultDic = responseDic[@"results"];
                 for (NSDictionary *imageDic in resultDic) {
                     NSString *imageURLStr = imageDic[@"url"];
                     NSURL *imageURL = [NSURL URLWithString:imageURLStr];
                     [imageURLsArray addObject:imageURL];
                 }
             }
             completion(imageURLsArray);
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

@end
