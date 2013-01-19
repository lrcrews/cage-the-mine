//
//  FacebookUser.m
//  MineCraft
//
//  Created by Leonard Ryan Crews on 10/2/12.
//  Copyright (c) 2012 Leonard Ryan Crews. All rights reserved.
//

#import "FacebookUser.h"


@implementation FacebookUser


- (BOOL)isPerson;
{
    return _first_name != nil;
}


- (void)requestFacebookUserFromURLRequestString:(NSString *)urlRequestString
                            withCompletionBlock:(void (^)())completionBlock;
{
    [self setId:nil];
    [self setFirst_name:nil];
    [self setLast_name:nil];
    [self setGender:nil];
    [self setName:nil];
    [self setLikes:nil];
    [self setCategory:nil];
    
    
    RCWebServicesDataHandler * fbAquirer = [[RCWebServicesDataHandler alloc] init];
    [fbAquirer requestDataForURLRequestString:urlRequestString
                        withRequestParameters:nil
                          responseIsCacheable:YES
                    successfulCompletionBlock:^(id data)
                    {
                        [self setValuesForKeysWithHash:data];
                        ((void (^)())completionBlock)();
                    }
                  unsuccessfulCompletionBlock:nil];
}


@end
