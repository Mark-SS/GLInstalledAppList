//
//  GLDetailViewController.h
//  InstalledAppList
//
//  Created by gongliang on 14/9/29.
//  Copyright (c) 2014年 GL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

