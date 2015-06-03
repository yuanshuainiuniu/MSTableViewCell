//
//  MyCell.m
//  MSSTableView
//
//  Created by niuniu on 15-6-2.
//  Copyright (c) 2015年 Sakkaras. All rights reserved.
//

#import "MyCell.h"

@implementation MyCell


- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    
    if (isSelected) {
        self.imageView.image = [UIImage imageNamed:@"selected"];
    }else{
        self.imageView.image = [UIImage imageNamed:@"normal"];
    }
}
@end
