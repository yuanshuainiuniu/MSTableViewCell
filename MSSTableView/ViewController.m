//
//  ViewController.m
//  MSSTableView
//
//  Created by Marshal on 26/12/13.
//  Copyright (c) 2013 Marshal. All rights reserved.
//

#import "ViewController.h"
#import "MSSTableView.h"
#import "MSSTableViewCell.h"
#import "MyCell.h"
@interface ViewController ()

@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSMutableArray *selectedDataArr;

@end

@implementation ViewController

- (NSMutableArray *)selectedDataArr{
    if (!_selectedDataArr) {
        self.selectedDataArr = [[NSMutableArray alloc] init];
    }
    return _selectedDataArr;
}

- (NSArray *)contents
{
    if (!_contents)
    {
        _contents = @[
                      @[
                          @[@"Section0_Row0", @"Row0_Subrow1",@"Row0_Subrow2"],
                          @[@"Section0_Row1", @"Row1_Subrow1", @"Row1_Subrow2", @"Row1_Subrow3", @"Row1_Subrow4", @"Row1_Subrow5", @"Row1_Subrow6", @"Row1_Subrow7", @"Row1_Subrow8", @"Row1_Subrow9", @"Row1_Subrow10", @"Row1_Subrow11", @"Row1_Subrow12"],
                          @[@"Section0_Row2"]],
                      @[
                          @[@"Section1_Row0", @"Row0_Subrow1", @"Row0_Subrow2", @"Row0_Subrow3"],
                          @[@"Section1_Row1"],
                          @[@"Section1_Row2", @"Row2_Subrow1", @"Row2_Subrow2", @"Row2_Subrow3", @"Row2_Subrow4", @"Row2_Subrow5"],
                          @[@"Section1_Row3"],
                          @[@"Section1_Row4"],
                          @[@"Section1_Row5"],
                          @[@"Section1_Row6"],
                          @[@"Section1_Row7"],
                          @[@"Section1_Row8"],
                          @[@"Section1_Row9"],
                          @[@"Section1_Row10"],
                          @[@"Section1_Row11"]]
                      ];
    }
    
    return _contents;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.MSSTableViewDelegate = self;
    self.tableView.sectionFooterHeight = 10;
    self.tableView.sectionHeaderHeight = 0;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(commit)];
    self.navigationItem.rightBarButtonItem = right;
    
    // In order to expand just one cell at a time. If you set this value YES, when you expand an cell, the already-expanded cell is collapsed automatically.
//    self.tableView.shouldExpandOnlyOneCell = YES;
    
}
- (void)commit{
    NSLog(@"%@",self.selectedDataArr);
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.contents count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contents[section] count];
}

- (NSInteger)tableView:(MSSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [self.contents[indexPath.section][indexPath.row] count] - 1;
}

#pragma mark -- 初始化时是否展开
- (BOOL)tableView:(MSSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        return YES;
    }
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MSSTableViewCell";
    
    MSSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[MSSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = self.contents[indexPath.section][indexPath.row][0];
    cell.expandable = YES;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        
        cell = [[MyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.contents[indexPath.section][indexPath.row][indexPath.subRow];
    return cell;
}

- (CGFloat)tableView:(MSSTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Section: %ld, Row:%ld, Subrow:%ld", (long)indexPath.section, (long)indexPath.row, (long)indexPath.subRow);
    
}

- (void)tableView:(MSSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Section: %ld, Row:%ld, Subrow:%ld", (long)indexPath.section, (long)indexPath.row, (long)indexPath.subRow);
    MyCell *cell = (MyCell *)[tableView cellForRowAtIndexPath:tableView.selectedIndexPath];
    
    if (!cell.isSelected) {
        [self.selectedDataArr addObject:self.contents[indexPath.section][indexPath.row][indexPath.subRow]];
    }else{
        [self.selectedDataArr removeObject:self.contents[indexPath.section][indexPath.row][indexPath.subRow]];
    }
}


@end
