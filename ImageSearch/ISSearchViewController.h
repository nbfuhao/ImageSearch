//
//  ISSearchViewController.h
//  ImageSearch
//
//  Created by Eddie Fu on 9/7/15.
//  Copyright (c) 2015 EddieFu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SearchViewControllerDelegate;
@interface ISSearchViewController : UIViewController
@property (nonatomic, weak)id<SearchViewControllerDelegate>delegate;
@end

@protocol SearchViewControllerDelegate <NSObject>

@required

- (void)searchViewControllerDidGetSearchTerm:(ISSearchViewController *)searchViewController term:(NSString *)term;

@end
