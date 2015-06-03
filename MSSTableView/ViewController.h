//
//  ViewController.h
//  MSSTableView
//
//  Created by Sakkaras on 26/12/13.
//  Copyright (c) 2013 Sakkaras. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSTableView.h"

@interface ViewController : UIViewController <MSSTableViewDelegate>

@property (nonatomic, weak) IBOutlet MSSTableView *tableView;

@end
