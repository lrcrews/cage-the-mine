//
//  RCWebServicesRequestCache.m
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

#import "RCWebServicesRequestCache.h"


#define kDataLifeInMinutes      (10)
#define kMaxResponsesToHold     (10)

#define kRequestTimestampKey    [NSString stringWithFormat:@"%@__TIMESTAMP", requestURLString]


#pragma mark -
#pragma mark Privateering

@interface RCWebServicesRequestCache ()


@property (retain) NSMutableDictionary * responseData;
@property (retain) NSMutableArray * lruQueue;


@end


#pragma mark -
#pragma mark Pirate'ing

@implementation RCWebServicesRequestCache


+ (RCWebServicesRequestCache *)sharedInstance;
{
    static RCWebServicesRequestCache * sharedInstance = nil;
    if (sharedInstance == nil)
    {
        sharedInstance = [[RCWebServicesRequestCache alloc] init];
        [sharedInstance setResponseData:[[NSMutableDictionary alloc] init]];
        [sharedInstance setLruQueue:[[NSMutableArray alloc] initWithCapacity:kMaxResponsesToHold]];
    }
    
    return sharedInstance;
}


+ (void)flushCache;
{
    [[RCWebServicesRequestCache sharedInstance].responseData removeAllObjects];
    [[RCWebServicesRequestCache sharedInstance].lruQueue removeAllObjects];
}


- (void)addResponse:(id)response
             forKey:(NSString *)requestURLString;
{
    if (response == nil)
    {
        NSLog(@"nil response, aborting add.");
        return;
    }
    
    
    [_responseData setObject:response
                      forKey:requestURLString];
    
    [_responseData setObject:[NSDate date]
                      forKey:kRequestTimestampKey];
    
    [_lruQueue insertObject:requestURLString
                    atIndex:0];
    
    if ([_lruQueue count] > kMaxResponsesToHold)
    {
        for (int i = kMaxResponsesToHold; i < [_lruQueue count]; i++)
        {
            NSLog(@"Removing cached data for request \"%@\", it has not been used recently enough.", requestURLString);
            [_responseData removeObjectForKey:requestURLString];
            [_responseData removeObjectForKey:kRequestTimestampKey];
        }
        
        [_lruQueue removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(kMaxResponsesToHold, [_lruQueue count] - kMaxResponsesToHold)]];
    }
}


- (id)responseForKey:(NSString *)requestURLString;
{
    NSDate * cachedTime = (NSDate *)[_responseData objectForKey:kRequestTimestampKey];
    if (cachedTime == nil)
    {
        NSLog(@"Response not present, returning nil.");
        return nil;
    }
    
    
    NSDate * now = [NSDate date];
    
    
    NSDateComponents * minuteComponent = [[NSDateComponents alloc] init];
    [minuteComponent setMinute:kDataLifeInMinutes];
    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    
    NSDate * testDate = [calendar dateByAddingComponents:minuteComponent
                                                  toDate:cachedTime
                                                 options:0];
    
    
    if ([testDate compare:now] == NSOrderedDescending)
    {
        NSLog(@"Pulling data for request \"%@\" from the cache.", requestURLString);
        
        [_lruQueue removeObject:requestURLString];
        
        [_lruQueue insertObject:requestURLString
                        atIndex:0];
        
        return [_responseData objectForKey:requestURLString];
    }
    else
    {
        NSLog(@"Removing cached data for request \"%@\", it has expired.", requestURLString);
        [_responseData removeObjectForKey:requestURLString];
        [_responseData removeObjectForKey:kRequestTimestampKey];
        [_lruQueue removeObject:requestURLString];
    }
    
    
    return nil;
}


@end
