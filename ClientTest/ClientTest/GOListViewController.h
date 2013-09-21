//
//  GOListViewController.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-28.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOPlainTableViewController.h"
#import "GOMultiSelectCell.h"

/* GOListViewController is the super class of document VC and contacts VC, supplying customized multi-selection, swipe-to-delete gesture for cells and search bar integration.
 */

@interface GOListViewController : GOPlainTableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

// this dictionary is used to keep multi-selected cells' indexPaths.
@property (nonatomic, retain, readonly) NSMutableDictionary *selectedIndexPathsHash;
// cuz the bug described in http://stackoverflow.com/questions/7679501 . we add this new property.
@property (nonatomic, retain, readonly) UISearchDisplayController *searchController;

@property (nonatomic, assign) BOOL isSearchLoading;

#pragma mark - Setters to launch features
@property (nonatomic, assign, getter = isMultiSelecting) BOOL multiSelect;
@property (nonatomic, assign, getter = isDeletable) BOOL deletable;
@property (nonatomic, assign, getter = isSearchable) BOOL searchable;

#pragma mark - Methods
// for each subclass of GOMultiSelectCell, have to call this method before your custom configuration.
- (void)configureForMultiSelectCell:(GOMultiSelectCell *)msCell
                       forIndexPath:(NSIndexPath *)indexPath
                    additionalBlock:(void (^)(BOOL))aBlock;

- (NSArray *)multiSelectedIndexPaths;

- (void)reloadVisibleRows;

#pragma mark - Status Changing Methods (TO BE OVERIDEN)
// will be called just before begining of multiSelect
- (void)multiSelectingWillBegin;
// will be called just before end of multiSelect
- (void)multiSelectingWillEnd;
// will be called before a cell is deleted
- (void)cellDidBeDeletedForIndexPath:(NSIndexPath *)indexPath;
// will be called when user tapped 'search' key after input in searchBar
- (void)searchDidCommitWithString:(NSString *)string duringTextChanging:(BOOL)isChanging;

@end
