//
//  MSSTableView.m
//  MSSTableView
//
//  Created by Sakkaras on 26/12/13.
//  Copyright (c) 2013 Sakkaras. All rights reserved.
//

#import "MSSTableView.h"
#import "MSSTableViewCell.h"
#import "MSSTableViewCellIndicator.h"
#import <objc/runtime.h>

#import "MyCell.h"
#import "MyIndexPath.h"

static NSString * const kIsExpandedKey = @"isExpanded";
static NSString * const kSubrowsKey = @"subrowsCount";
CGFloat const kDefaultCellHeight = 44.0f;

#pragma mark - MSSTableView

@interface MSSTableView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSMutableDictionary *expandableCells;


- (NSInteger)numberOfExpandedSubrowsInSection:(NSInteger)section;

- (NSIndexPath *)correspondingIndexPathForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)setExpanded:(BOOL)isExpanded forCellAtIndexPath:(NSIndexPath *)indexPath;

- (IBAction)expandableButtonTouched:(id)sender event:(id)event;

- (NSInteger)numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) NSMutableArray *selectedIndexPathArr;
@end

@implementation MSSTableView

- (NSMutableArray *)selectedIndexPathArr{
    if (!_selectedIndexPathArr) {
        self.selectedIndexPathArr = [[NSMutableArray alloc] init];
    }
    return _selectedIndexPathArr;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _shouldExpandOnlyOneCell = NO;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _shouldExpandOnlyOneCell = NO;
    }
    
    return self;
}

- (void)setMSSTableViewDelegate:(id<MSSTableViewDelegate>)MSSTableViewDelegate
{
    self.dataSource = self;
    self.delegate = self;
    
//    [self setSeparatorColor:[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0]];
    
    if (MSSTableViewDelegate)
        _MSSTableViewDelegate = MSSTableViewDelegate;
}

#pragma mark --设置指示器颜色
- (void)setSeparatorColor:(UIColor *)separatorColor
{
    [super setSeparatorColor:separatorColor];
    
    [MSSTableViewCellIndicator setIndicatorColor:separatorColor];
}

- (NSMutableDictionary *)expandableCells
{
    if (!_expandableCells)
    {
        _expandableCells = [NSMutableDictionary dictionary];
        
        NSInteger numberOfSections = [self.MSSTableViewDelegate numberOfSectionsInTableView:self];
        for (NSInteger section = 0; section < numberOfSections; section++)
        {
            NSInteger numberOfRowsInSection = [self.MSSTableViewDelegate tableView:self
                                                             numberOfRowsInSection:section];
            
            NSMutableArray *rows = [NSMutableArray array];
            for (NSInteger row = 0; row < numberOfRowsInSection; row++)
            {
                NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                NSInteger numberOfSubrows = [self.MSSTableViewDelegate tableView:self
                                                      numberOfSubRowsAtIndexPath:rowIndexPath];
                BOOL isExpandedInitially = NO;
                if ([self.MSSTableViewDelegate respondsToSelector:@selector(tableView:shouldExpandSubRowsOfCellAtIndexPath:)])
                {
                    isExpandedInitially = [self.MSSTableViewDelegate tableView:self shouldExpandSubRowsOfCellAtIndexPath:rowIndexPath];
                }
                
                NSMutableDictionary *rowInfo = [NSMutableDictionary dictionaryWithObjects:@[@(isExpandedInitially), @(numberOfSubrows)]
                                                                                  forKeys:@[kIsExpandedKey, kSubrowsKey]];

                [rows addObject:rowInfo];
            }
            
            [_expandableCells setObject:rows forKey:@(section)];
        }
    }
    
    return _expandableCells;
}

- (void)refreshData
{
    self.expandableCells = nil;
    
    [super reloadData];
}

- (void)refreshDataWithScrollingToIndexPath:(NSIndexPath *)indexPath
{
    [self refreshData];
    
    if (indexPath.section < [self numberOfSections] && indexPath.row < [self numberOfRowsInSection:indexPath.section])
    {
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - UITableViewDataSource

#pragma mark - Required

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_MSSTableViewDelegate tableView:tableView numberOfRowsInSection:section] + [self numberOfExpandedSubrowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
    
    if ([correspondingIndexPath subRow] == 0)
    {
        MSSTableViewCell *expandableCell = (MSSTableViewCell *)[_MSSTableViewDelegate tableView:tableView cellForRowAtIndexPath:correspondingIndexPath];
        if ([expandableCell respondsToSelector:@selector(setSeparatorInset:)])
        {
            expandableCell.separatorInset = UIEdgeInsetsZero;
        }
        
        BOOL isExpanded = [self.expandableCells[@(correspondingIndexPath.section)][correspondingIndexPath.row][kIsExpandedKey] boolValue];
        
        if (expandableCell.isExpandable)
        {
            expandableCell.expanded = isExpanded;
            
            UIButton *expandableButton = (UIButton *)expandableCell.accessoryView;
            [expandableButton addTarget:tableView
                                 action:@selector(expandableButtonTouched:event:)
                       forControlEvents:UIControlEventTouchUpInside];
            
            if (isExpanded)
            {
                expandableCell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
            }
            else
            {
                if ([expandableCell containsIndicatorView])
                {
                    [expandableCell removeIndicatorView];
                }
            }
        }
        else
        {
            expandableCell.expanded = NO;
            expandableCell.accessoryView = nil;
            [expandableCell removeIndicatorView];
        }
        
       return expandableCell;
    }
    else
    {
        MyCell *cell = (MyCell *)[_MSSTableViewDelegate tableView:(MSSTableView *)tableView cellForSubRowAtIndexPath:correspondingIndexPath];
        cell.indentationLevel = 2;
        cell.isSelected = NO;
        for (MyIndexPath *selectPath in self.selectedIndexPathArr) {
            
            if (selectPath.section == correspondingIndexPath.section && selectPath.row == correspondingIndexPath.row && selectPath.subRow == correspondingIndexPath.subRow) {
                cell.isSelected = YES;
                break;
            }
        }

        return cell;
    }
}


#pragma mark - Optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_MSSTableViewDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)])
    {
        return [_MSSTableViewDelegate numberOfSectionsInTableView:tableView];
    }
    
    return 1;
}



#pragma mark - UITableViewDelegate

#pragma mark - Optional

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedIndexPath = indexPath;
    
    MSSTableViewCell *cell = (MSSTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(isExpandable)])
    {
        if (cell.isExpandable)
        {
            cell.expanded = !cell.isExpanded;
        
            NSIndexPath *_indexPath = indexPath;
            NSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
            if (cell.isExpanded && _shouldExpandOnlyOneCell)
            {
                _indexPath = correspondingIndexPath;
                [self collapseCurrentlyExpandedIndexPaths];
            }
        
            if (_indexPath)
            {
                NSInteger numberOfSubRows = [self numberOfSubRowsAtIndexPath:correspondingIndexPath];
            
                NSMutableArray *expandedIndexPaths = [NSMutableArray array];
                NSInteger row = _indexPath.row;
                NSInteger section = _indexPath.section;
            
                for (NSInteger index = 1; index <= numberOfSubRows; index++)
                {
                    NSIndexPath *expIndexPath = [NSIndexPath indexPathForRow:row+index inSection:section];
                    [expandedIndexPaths addObject:expIndexPath];
                }
            
                if (cell.isExpanded)
                {
                    [self setExpanded:YES forCellAtIndexPath:correspondingIndexPath];
                    [self insertRowsAtIndexPaths:expandedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                }
                else
                {
                    [self setExpanded:NO forCellAtIndexPath:correspondingIndexPath];
                    [self deleteRowsAtIndexPaths:expandedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                }
            
                [cell accessoryViewAnimation];
            }
        }
        
        if ([_MSSTableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        {
            NSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
            
            if (correspondingIndexPath.subRow == 0)
            {
                [_MSSTableViewDelegate tableView:tableView didSelectRowAtIndexPath:correspondingIndexPath];
            }
            else
            {
                [_MSSTableViewDelegate tableView:self didSelectSubRowAtIndexPath:correspondingIndexPath];
            }
        }
    }
    else
    {
        if ([_MSSTableViewDelegate respondsToSelector:@selector(tableView:didSelectSubRowAtIndexPath:)])
        {
            NSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
            
            [_MSSTableViewDelegate tableView:self didSelectSubRowAtIndexPath:correspondingIndexPath];
            
            MyCell *selectedCell = (MyCell *)cell;
            if (selectedCell.isSelected) {
                selectedCell.isSelected = NO;
                
//                [self.selectedIndexPathArr removeObject:correspondingIndexPath];
                for (MyIndexPath *indexp in self.selectedIndexPathArr) {
                    if (indexp.section == correspondingIndexPath.section && indexp.row == correspondingIndexPath.row && indexp.subRow == correspondingIndexPath.subRow) {
                        [self.selectedIndexPathArr removeObject:indexp];
                        break;
                    }
                }
                
            }else{
                selectedCell.isSelected = YES;
                
//                [self.selectedIndexPathArr addObject:correspondingIndexPath];
                MyIndexPath *indexp = [[MyIndexPath alloc] init];
                indexp.section = correspondingIndexPath.section;
                indexp.row = correspondingIndexPath.row;
                indexp.subRow = correspondingIndexPath.subRow;
                [self.selectedIndexPathArr addObject:indexp];
            }
//            NSLog(@"%ld,%ld,%ld",(long)correspondingIndexPath.section,(long)correspondingIndexPath.row,(long)correspondingIndexPath.subRow);
//            NSLog(@"%lu",(unsigned long)[self.selectedIndexPathArr count]);
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([_MSSTableViewDelegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)])
        [_MSSTableViewDelegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    
    [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
    if ([correspondingIndexPath subRow] == 0)
    {
        if ([_MSSTableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
        {
            return [_MSSTableViewDelegate tableView:tableView heightForRowAtIndexPath:correspondingIndexPath];
        }
        
        return kDefaultCellHeight;
    }
    else
    {
        if ([_MSSTableViewDelegate respondsToSelector:@selector(tableView:heightForSubRowAtIndexPath:)])
        {
            return [_MSSTableViewDelegate tableView:self heightForSubRowAtIndexPath:correspondingIndexPath];
        }
        
        return kDefaultCellHeight;
    }
}
#pragma mark - MSSTableViewUtils

- (NSInteger)numberOfExpandedSubrowsInSection:(NSInteger)section
{
    NSInteger totalExpandedSubrows = 0;
    
    NSArray *rows = self.expandableCells[@(section)];
    for (id row in rows)
    {
        if ([row[kIsExpandedKey] boolValue] == YES)
        {
            totalExpandedSubrows += [row[kSubrowsKey] integerValue];
        }
    }
    
    return totalExpandedSubrows;
}

- (IBAction)expandableButtonTouched:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self];
    
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:currentTouchPosition];
    
    if (indexPath)
        [self tableView:self accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (NSInteger)numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return [_MSSTableViewDelegate tableView:self numberOfSubRowsAtIndexPath:indexPath];
}

- (NSIndexPath *)correspondingIndexPathForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block NSIndexPath *correspondingIndexPath = nil;
    __block NSInteger expandedSubrows = 0;
    
    NSArray *rows = self.expandableCells[@(indexPath.section)];
    [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        BOOL isExpanded = [obj[kIsExpandedKey] boolValue];
        NSInteger numberOfSubrows = 0;
        if (isExpanded)
        {
            numberOfSubrows = [obj[kSubrowsKey] integerValue];
        }
        
        NSInteger subrow = indexPath.row - expandedSubrows - idx;
        if (subrow > numberOfSubrows)
        {
            expandedSubrows += numberOfSubrows;
        }
        else
        {
             correspondingIndexPath = [NSIndexPath indexPathForSubRow:subrow
                                                                inRow:idx
                                                            inSection:indexPath.section];
            
            *stop = YES;
        }
    }];
    
    return correspondingIndexPath;
}

- (void)setExpanded:(BOOL)isExpanded forCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *cellInfo = self.expandableCells[@(indexPath.section)][indexPath.row];
    [cellInfo setObject:@(isExpanded) forKey:kIsExpandedKey];
}

- (void)collapseCurrentlyExpandedIndexPaths
{
    NSMutableArray *totalExpandedIndexPaths = [NSMutableArray array];
    NSMutableArray *totalExpandableIndexPaths = [NSMutableArray array];
    
    [self.expandableCells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       
        __block NSInteger totalExpandedSubrows = 0;
        
        [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           
            NSInteger currentRow = idx + totalExpandedSubrows;
            
            BOOL isExpanded = [obj[kIsExpandedKey] boolValue];
            if (isExpanded)
            {
                NSInteger expandedSubrows = [obj[kSubrowsKey] integerValue];
                for (NSInteger index = 1; index <= expandedSubrows; index++)
                {
                    NSIndexPath *expandedIndexPath = [NSIndexPath indexPathForRow:currentRow + index
                                                                        inSection:[key integerValue]];
                    [totalExpandedIndexPaths addObject:expandedIndexPath];
                }
                
                [obj setObject:@(NO) forKey:kIsExpandedKey];
                totalExpandedSubrows += expandedSubrows;
                
                [totalExpandableIndexPaths addObject:[NSIndexPath indexPathForRow:currentRow inSection:[key integerValue]]];
            }
        }];
    }];
    
    for (NSIndexPath *indexPath in totalExpandableIndexPaths)
    {
        MSSTableViewCell *cell = (MSSTableViewCell *)[self cellForRowAtIndexPath:indexPath];
        cell.expanded = NO;
        [cell accessoryViewAnimation];
    }
    
    [self deleteRowsAtIndexPaths:totalExpandedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
}

@end

#pragma mark - NSIndexPath (MSSTableView)

static void *SubRowObjectKey;

@implementation NSIndexPath (MSSTableView)

@dynamic subRow;

- (NSInteger)subRow
{
    id subRowObj = objc_getAssociatedObject(self, SubRowObjectKey);
    return [subRowObj integerValue];
}

- (void)setSubRow:(NSInteger)subRow
{
    id subRowObj = [NSNumber numberWithInteger:subRow];
    objc_setAssociatedObject(self, SubRowObjectKey, subRowObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSIndexPath *)indexPathForSubRow:(NSInteger)subrow inRow:(NSInteger)row inSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    indexPath.subRow = subrow;
    
    return indexPath;
}

@end

