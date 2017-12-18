//
//  StudentRootCollectionViewCell.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/9/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentRootCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *idLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *birthLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *studentImage;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@end
