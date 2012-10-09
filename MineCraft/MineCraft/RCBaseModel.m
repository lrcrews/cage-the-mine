//
//  RCBaseModel.m
//  MineCraft
//
//  Copyright (c) 2012 Leonard Ryan Crews
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Have a nice day.
//

#import "RCBaseModel.h"

#import "NSObject+utils.h"


// Of course you could put all this in each of your models, but that wouldn't be very DRY.

@implementation RCBaseModel


- (NSString *)notificationName
{
    if (_notificationName == nil)
    {
        _notificationName = kNotification_GenericDataLoadCompletedOrFailed;
    }
    
    return _notificationName;
}


// Implement in your model if you have nested objects.
//  Do not call [super initWithDictionary:] if you need to implement your own.
//
- (id)initWithDictionary:(NSDictionary *)dictionary;
{
    self = [super init];
    
    if (dictionary != nil
     && [dictionary isKindOfClass:[NSDictionary class]])
    {
        // If you have nested objects you'll need something like the following
        //  in YOUR model (in addition to the stuff above this comment).
        //
        // This is just here to provide the idea.
        
        /******************************************
        NSMutableDictionary * mutableCopy = [dictionary mutableCopy];
        
        NSDictionary * myNestedObjectAsADictionary = [mutableCopy objectForKey:@"my_nested_objects_key"];
        if (myNestedObjectAsADictionary != nil)
        {
            [self setYourObjectsNestedObject:[[ANestedObject alloc] initWithDictionary:myNestedObjectAsADictionary]];
        }
        [mutableCopy removeObjectForKey:@"my_nested_objects_key"];
        
        
        [self setMyValuesForKeysWithDictionary:mutableCopy];
        ******************************************/
        
        [self setMyValuesForKeysWithDictionary:dictionary];
    }
    
    return self;    // and this, you'll want this too.
}


#pragma mark -
#pragma mark RCWebServicesDataHandlerDelegate methods

- (void)handler:(RCWebServicesDataHandler *)handler
     loadedData:(id)data;
{
    [self setConnectionSuccessful:YES];
    
    if ([data respondsToSelector:@selector(objectForKey:)])
    {
        [self setMyValuesForKeysWithDictionary:data];
    }
    else
    {
        NSLog(@"WARNING: your model didn't receive the hash (NSDictionary) it was expecting."); // I'd replace this with your logging system (if applicable)
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName]
                                                        object:self
                                                      userInfo:nil];
}


- (void)dataFailedToLoadFromHandler:(RCWebServicesDataHandler *)handler;
{
    NSLog(@"WARNING: data failed to load.  Oh noes!!"); // I'd replace this with your logging system (if applicable)
    
    [self setConnectionSuccessful:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName]
                                                        object:self
                                                      userInfo:nil];
}


@end
