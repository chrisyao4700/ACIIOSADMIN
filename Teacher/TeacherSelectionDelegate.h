//
//  TeacherSelectionDelegate.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TeacherSelectionDelegate <NSObject>
@required

-(void) teacherSelectionDidSelectTeacher:(NSString *) teacherID;
@end
