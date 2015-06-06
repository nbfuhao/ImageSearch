//
//  ISNetworkManager.m
//  ImageSearch
//
//  Created by Admim on 6/5/15.
//  Copyright (c) 2015 EddieFu. All rights reserved.
//

#import "ISNetworkManager.h"

@implementation ISNetworkManager

#pragma mark create a singleton
+ (id)sharedSyncController
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
    }
    return self;
}
@end
