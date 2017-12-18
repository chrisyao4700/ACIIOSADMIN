//
//  GradeRecordDisplayViewController.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+CYViewController.h"
#import "AppDataSocketConnector.h"
#import "CYMultiActionViewController.h"

@interface GradeRecordDisplayViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,AppDataSocketDelegate,CYMultiActionDelegate>

@property NSString * studentID;

@property (strong, nonatomic) IBOutlet UICollectionView *contentTable;

@end
