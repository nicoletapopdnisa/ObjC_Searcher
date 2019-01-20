//
//  TableViewCell.m
//  ObjC_Searcher
//
//  Created by user148651 on 1/20/19.
//  Copyright © 2019 user148651. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

@synthesize gifImage;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
