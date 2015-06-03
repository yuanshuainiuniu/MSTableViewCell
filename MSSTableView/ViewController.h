//
//  ViewController.h
//  MSSTableView
//
//  Created by Marshal on 26/12/13.
//  Copyright (c) 2013 Marshal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSTableView.h"

@interface ViewController : UIViewController <MSSTableViewDelegate>

@property (nonatomic, weak) IBOutlet MSSTableView *tableView;

@end
