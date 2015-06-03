//
//  MyIndexPath.h
//  MSSTableView
//
//  Created by GoBeta on 15/6/3.
//  Copyright (c) 2015年 Sakkaras. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyIndexPath : NSObject<NSCopying>

@property (nonatomic ,assign) NSInteger section;
@property (nonatomic ,assign) NSInteger row;
@property (nonatomic ,assign) NSInteger subRow;

@end
