//
//  TableViewController.m
//  ObjC_Searcher
//
//  Created by user148651 on 1/20/19.
//  Copyright © 2019 user148651. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"

@interface TableViewController ()

@end

@implementation TableViewController

@synthesize nextOne;
@synthesize gifs;
@synthesize params;
@synthesize stringToSearch;
@synthesize imageCache;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nextOne = 0;
    
    self.gifs = [[NSMutableArray alloc] init];
    
    self.params = [[NSMutableDictionary alloc] init];
    [self initalizeParameters];
    
    self.stringToSearch = @"";
    
    self.imageCache = SDImageCache.sharedImageCache;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 300.0;
        self.tableView.layer.masksToBounds = true;
    });
    
    [self setUpSearchBar];
    
    [self.params setObject:[NSString stringWithFormat:@"%d", self.nextOne] forKey:@"pos"];
    
    [self getGifData];
    
}

#pragma mark - API URL parameters initialization

- (void)initalizeParameters {
    [self.params setObject:@"" forKey:@"q"];
    [self.params setObject:API_KEY forKey:@"key"];
    [self.params setObject:@"20" forKey:@"limit"];
    [self.params setObject:@"0" forKey:@"pos"];
    
}

#pragma mark - SearchBar setup

- (void)setUpSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width/1.5, 100.0)];
    
    searchBar.searchBarStyle = UISearchBarStyleProminent;
    searchBar.placeholder = @"Search...";
    searchBar.delegate = self;
    searchBar.hidden = true;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
        self.navigationItem.leftBarButtonItem = leftBarButton;
    });
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self getGifData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar endEditing:true];
}

- (IBAction)searchButtonPressed:(id)sender {
    UIBarButtonItem *barButtonItem = self.navigationItem.leftBarButtonItem;
    
    if(barButtonItem) {
        UISearchBar *searchBar = barButtonItem.customView;
        
        if(searchBar) {
            if(searchBar.isHidden) {
                searchBar.hidden = false;
                [searchBar endEditing:false];
                [searchBar becomeFirstResponder];
            }
            else {
                searchBar.hidden = true;
                [searchBar endEditing:true];
            }
        
        }
            
    }
    
}

#pragma mark - Searchbar delegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.stringToSearch = searchText;
    SEL reloadSelector = @selector(reload);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:reloadSelector object:nil];
    [self performSelector:reloadSelector withObject:nil afterDelay:0.3];
}

- (void)reload {
    [self.gifs removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    self.nextOne = 0;
    [self.imageCache clearMemory];
    
    [self.params setObject:[NSString stringWithFormat:@"%d", self.nextOne] forKey:@"pos"];
    [self.params setObject:self.stringToSearch forKey:@"q"];
    
    [self getGifData];
    
}
    
#pragma mark - Networking
    
- (void)getGifData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:GIF_URL parameters:self.params progress:nil
    
      success:^(NSURLSessionTask *task, id responseObject) {
          NSLog(@"Success! Got data.\n");
          [self processJSON:responseObject];
        
          dispatch_async(dispatch_get_main_queue(), ^{
              [self.tableView reloadData];
          });
          
          self.nextOne = self.nextOne + 20;
          [self.params setObject:[NSString stringWithFormat:@"%d", self.nextOne] forKey:@"pos"];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - JSON parsing

- (void)processJSON:(id)responseObject {
    NSArray *gifResult = [responseObject valueForKey:@"results"];
    for(NSDictionary *element in gifResult) {
        NSString *gifUrl = [[[element objectForKey:@"media"][0] objectForKey:@"gif"] objectForKey:@"url"];
        [self.gifs addObject:gifUrl];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.gifs count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myTableViewCell" forIndexPath:indexPath];
    TableViewCell *myCell = (TableViewCell*) cell;
    [myCell.gifImage setImage:[[UIImage alloc] init]];
    
    SDAnimatedImage *image = (SDAnimatedImage *)[imageCache imageFromMemoryCacheForKey:[self.gifs objectAtIndex:indexPath.row]];
    
    if(!image) {
        [myCell.gifImage sd_setImageWithURL:[self.gifs objectAtIndex:indexPath.row] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            BOOL isValid = [self.tableView numberOfSections] > indexPath.section &&
            [self.tableView numberOfRowsInSection:indexPath.section] > indexPath.row;
            
            if (isValid) {
                [self->imageCache storeImageToMemory:myCell.gifImage.image forKey:[self.gifs objectAtIndex:indexPath.row]];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            
        }];
    }
    
    else {
        myCell.gifImage.image = image;
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger totalNumberOfRows = [tableView numberOfRowsInSection:indexPath.section];
    
    if(indexPath.row == totalNumberOfRows - 1) {
        [self getGifData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300.0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - ScrollView delegate methods

/*
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
        [self getGifData];
    }
}
 */

@end
