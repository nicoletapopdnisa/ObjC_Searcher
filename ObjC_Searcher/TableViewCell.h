//
//  TableViewCell.h
//  ObjC_Searcher
//
//  Created by user148651 on 1/20/19.
//  Copyright © 2019 user148651. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDAnimatedImageView+WebCache.h>
#import <SDWebImage/SDAnimatedImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet SDAnimatedImageView *gifImage;

@end

NS_ASSUME_NONNULL_END
