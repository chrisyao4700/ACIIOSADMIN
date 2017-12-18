//
//  SubjectRootSelectionDelegate.h
//  ACI Hacienda
//
//  Created by 姚远 on 7/10/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SubjectRootSelectionDelegate <NSObject>
@required
-(void) subjectSelectionDidPickSubject:(NSString *) subjectID;

@end
