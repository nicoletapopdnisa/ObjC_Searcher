//
//  TableViewController.h
//  ObjC_Searcher
//
//  Created by user148651 on 1/20/19.
//  Copyright © 2019 user148651. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AFNetworking.h>

#define GIF_URL   @"https://api.tenor.com/v1/search?"
#define API_KEY   @"AWMHIP5GIBF3"

NS_ASSUME_NONNULL_BEGIN

@interface TableViewController : UITableViewController<UISearchBarDelegate>

@property (nonatomic, assign) int nextOne;
@property (nonatomic, retain) NSMutableArray *gifs;
@property (nonatomic, retain) NSMutableDictionary *params;
@property (nonatomic, retain) NSString *stringToSearch;
@property (nonatomic, retain) NSCache *imageCache;

-(void)initalizeParameters;
-(void)setUpSearchBar;
-(void)getGifData;
-(void)processJSON:(id) responseObject;

@end

NS_ASSUME_NONNULL_END
