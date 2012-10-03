//
//  NSObject+utils.m
//  MineCraft
//
//  Created by Leonard Crews on 6/17/12.
//  Copyright (c) 2012 FeLT LLC. All rights reserved.
//

#import "NSObject+utils.h"


@implementation NSObject (utils)


- (void)setMyValuesForKeysWithDictionary:(NSDictionary *)keyedValues;
{
    for (NSString * currentKey in [keyedValues allKeys])
    {
        NSString * setterName = [NSString stringWithFormat:@"set%@%@:", [[currentKey substringToIndex:1] uppercaseString], [currentKey substringFromIndex:1]];
        
        SEL selector = NSSelectorFromString(setterName);
        if ([self respondsToSelector:selector])
        {
            id currentObject = [keyedValues objectForKey:currentKey];
            if (currentObject == [NSNull null])
            {
                currentObject = nil;
            }
            
            
            [self performSelectorOnMainThread:selector 
                                   withObject:currentObject 
                                waitUntilDone:YES];
        }
        else 
        {
            //AlwaysLog(@"object does not respond to setter name %@", setterName);
        }
    }
}


- (id)aquireCustomNibNamed:(NSString *)nibName;
{
    NSArray * mainBundleObjects = [[NSBundle mainBundle] loadNibNamed:nibName 
                                                                owner:nil 
                                                              options:nil];
    
    for (id currentObject in mainBundleObjects)
    {
        if ([currentObject isKindOfClass:[self class]])
        {
            return currentObject;
        }
    }
    
    
    return nil;
}


@end
