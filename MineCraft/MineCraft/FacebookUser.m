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
    
    
    [self setCompletionBlock:completionBlock];
    
    
    RCWebServicesDataHandler * fbAquirer = [[RCWebServicesDataHandler alloc] init];
    
    [fbAquirer setDelegate:self];
    [fbAquirer requestDataForURLRequestString:urlRequestString];
}


@end
