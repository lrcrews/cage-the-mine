//
//  FacebookUser.h
//  MineCraft
//
//  Created by Leonard Ryan Crews on 10/2/12.
//  Copyright (c) 2012 Leonard Ryan Crews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCBaseModel.h"


@interface FacebookUser : RCBaseModel


@property (nonatomic, retain) NSString * id;

//  Person
@property (nonatomic, copy) NSString * first_name;
@property (nonatomic, copy) NSString * last_name;
@property (nonatomic, copy) NSString * gender;

//  Company
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * likes;
@property (nonatomic, copy) NSString * category;


- (BOOL)isPerson;

- (void)requestFacebookUserFromURLRequestString:(NSString *)urlRequestString
                completionNotificationNameOrNil:(NSString *)notificationName;


@end
