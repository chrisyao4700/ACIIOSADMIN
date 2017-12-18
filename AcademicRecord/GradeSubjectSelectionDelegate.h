//
//  GradeSubjectSelectionDelegate.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GradeSubjectSelectionDelegate <NSObject>
-(void) gradeSubjectDidSelect:(NSString *) gradeSubjectID;
@end
