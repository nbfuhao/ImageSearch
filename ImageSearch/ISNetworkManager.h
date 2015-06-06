//
//  ISNetworkManager.h
//  ImageSearch
//
//  Created by Admim on 6/5/15.
//  Copyright (c) 2015 EddieFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISNetworkManager : NSObject

+(id)sharedNetworkManager;

// Method that fetches image URLs
- (void)fetchImagesWithPageNumber:(int)page WithSearchTerm:(NSString *)searchTerm WithCompletion:(void (^) (NSMutableArray *imagesArray))completion;

@end
