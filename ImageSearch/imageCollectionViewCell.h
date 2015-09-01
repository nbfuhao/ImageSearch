//
//  imageCollectionViewCell.h
//  ImageSearch
//
//  Created by Admim on 6/5/15.
//  Copyright (c) 2015 EddieFu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface imageCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end
