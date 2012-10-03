//
//  FacebookUser.m
//  MineCraft
//
//  Created by Leonard Ryan Crews on 10/2/12.
//  Copyright (c) 2012 Leonard Ryan Crews. All rights reserved.
//

#import "FacebookUser.h"

#import "NSObject+utils.h"


@implementation FacebookUser
{
    NSString * notificationName_;
}


- (BOOL)isPerson;
{
    return _first_name != nil;
}


- (id)initWithDictionary:(NSDictionary *)dictionary;
{
    self = [super init];
    
    if (dictionary != nil
     && [dictionary isKindOfClass:[NSDictionary class]])
    {
        [self setMyValuesForKeysWithDictionary:dictionary];
    }
    
    return self;
}


- (void)requestFacebookUserFromURLRequestString:(NSString *)urlRequestString
                withCompletionNotificationNamed:(NSString *)notificationName;
{
    [self setId:nil];
    [self setFirst_name:nil];
    [self setLast_name:nil];
    [self setGender:nil];
    [self setName:nil];
    [self setLikes:nil];
    [self setCategory:nil];
    
    
    notificationName_ = notificationName;
    
    
    RCWebServicesDataHandler * fbAquirer = [[RCWebServicesDataHandler alloc] init];
    
    [fbAquirer setDelegate:self];
    [fbAquirer requestDataForURLRequestString:urlRequestString];
}


#pragma mark -
#pragma mark RCWebServicesDataHandlerDelegate methods

- (void)handler:(RCWebServicesDataHandler *)handler
     loadedData:(id)data;
{
    if ([data respondsToSelector:@selector(objectForKey:)]) // Safety first
    {
        [self setMyValuesForKeysWithDictionary:data];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName_
                                                        object:self
                                                      userInfo:nil];
}


@end
