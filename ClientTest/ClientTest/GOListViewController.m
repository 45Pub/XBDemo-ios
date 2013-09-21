//
//  GOListViewController.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-28.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOListViewController.h"
#import "PPCore.h"
#import "GOSearchBar.h"

@interface GOListViewController ()

@property (nonatomic, retain, readwrite) NSMutableDictionary *selectedIndexPathsHash;
@property (nonatomic, retain, readwrite) UISearchDisplayController *searchController;

@end

@implementation GOListViewController

- (void)dealloc
{
    PP_RELEASE(_selectedIndexPathsHash);
    PP_RELEASE(_searchController)
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView.allowsSelectionDuringEditing = YES;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableDictionary *)selectedIndexPathsHash
{
    if (_selectedIndexPathsHash == nil) {
        _selectedIndexPathsHash = [[NSMutableDictionary alloc] init];
    }
    
    return _selectedIndexPathsHash;
}

#pragma mark - Setters to launch features

- (void)setMultiSelect:(BOOL)multiSelect
{
    [self view]; // before setEditing, must load view.
    
    if (self.multiSelect != multiSelect)
        multiSelect == YES ? [self multiSelectingWillBegin] : [self multiSelectingWillEnd];
    
    _multiSelect = multiSelect;
    [self.tableView setEditing:multiSelect animated:YES];
    [self.searchController.searchResultsTableView setEditing:multiSelect animated:YES];
    
    for (NSIndexPath *key in [self.selectedIndexPathsHash allKeys]) {
        [self.selectedIndexPathsHash setObject:[NSNumber numberWithBool:NO] forKey:key];
    }
    
    if (self.tableView.visibleCells.count && multiSelect == NO) {
        // reload visible cells so that next round of edit won't display wrong result
        [self performSelector:@selector(reloadVisibleRows) withObject:nil afterDelay:0.3];
    }
}

- (void)setSearchable:(BOOL)searchable
{
    _searchable = searchable;
    
    if (_searchable && self.searchController == nil) {
        GOSearchBar *searchBar = [[GOSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 44.0)];
        UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        self.searchController = searchController;
        self.tableView.tableHeaderView = searchBar;
        
        [searchBar release];
        [searchController release];
        
        self.searchController.delegate = self;
        self.searchController.searchResultsDelegate = self;
        self.searchController.searchResultsDataSource = self;
        self.searchController.searchBar.delegate = self;
    }
    else if (_searchable == NO && self.searchController != nil) {
        self.searchController = nil;
    }
}

#pragma mark - Helper Methods

- (void)multiSelectingWillBegin
{
    // implement by subclasses
}

- (void)multiSelectingWillEnd
{
    // implement by subclasses
}

- (void)searchDidCommitWithString:(NSString *)string duringTextChanging:(BOOL)isChanging
{
    // implement by subclasses
}

- (void)cellDidBeDeletedForIndexPath:(NSIndexPath *)indexPath
{
    // implement by subclasses
}

- (void)reloadVisibleRows
{
    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
}

- (void)configureForMultiSelectCell:(GOMultiSelectCell *)msCell forIndexPath:(NSIndexPath *)indexPath additionalBlock:(void (^)(BOOL))aBlock
{
    __block typeof(self) weakSelf = self;
    msCell.multiSelectedBlock = ^(BOOL mSelected){
        [weakSelf.selectedIndexPathsHash setObject:[NSNumber numberWithBool:mSelected] forKey:indexPath];
        
        if (aBlock) {
            aBlock(mSelected);
        }
    };
    
    BOOL mSelected = [self.selectedIndexPathsHash[indexPath] boolValue];
    msCell.multiSelected = mSelected;
}

- (NSArray *)multiSelectedIndexPaths
{
    if ([self isMultiSelecting] == NO) {
        return nil;
    }
    
    NSMutableArray *selectedIndexPathsContainer = [[NSMutableArray alloc] init];
    
    [self.selectedIndexPathsHash enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        BOOL mSelected = [obj boolValue];
        if (mSelected) {
            [selectedIndexPathsContainer addObject:key];
        }
    }];
    
    [selectedIndexPathsContainer sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2];
    }];
    
    NSArray *arrayToReturn = [selectedIndexPathsContainer copy];
    [selectedIndexPathsContainer release];
    
    return [arrayToReturn autorelease];
}

#pragma mark - UITableView DataSource Methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return self.isSearchable || self.isDeletable || self.multiSelect;
    }
    else {
        return self.multiSelect;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self cellDidBeDeletedForIndexPath:indexPath];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    if ([cell isKindOfClass:[GOMultiSelectCell class]]) {
        [self configureForMultiSelectCell:(GOMultiSelectCell *)cell forIndexPath:indexPath additionalBlock:nil];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // can be overiden
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (tableView == self.tableView) {
        if ([cell isKindOfClass:[GOMultiSelectCell class]] && self.isMultiSelecting) {
            GOMultiSelectCell *msc = (GOMultiSelectCell *)cell;
            if (msc.canMultiSelectThroughSelect) {
                [msc setMultiSelected:!msc.multiSelected animated:YES];
            }
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (!self.tableView.isEditing && self.isDeletable)
            return UITableViewCellEditingStyleDelete;
        else
            return UITableViewCellEditingStyleNone;
    }
    
    return UITableViewCellEditingStyleNone;
}

#pragma mark - UISearchDisplayDelegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // can be overiden
    self.isSearchLoading = YES;
    [self searchDidCommitWithString:searchString duringTextChanging:YES];
    return YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
	self.isSearchLoading = NO;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    GOSearchBar *g = (GOSearchBar *)controller.searchBar;
    [g setCancelButton];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.isSearchLoading = YES;
    [self searchDidCommitWithString:searchBar.text duringTextChanging:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
	self.isSearchLoading = NO;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
//    GOSearchBar *g = (GOSearchBar *)searchBar;
//    [g setCancelButton];
}

@end