//
//  CourseRootSelectionDelegate.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/10/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CourseRootSelectionDelegate <NSObject>

-(void) courseRootDidSelectCourse:(NSString *) courseID forPrice:(NSString *)price;
@end
