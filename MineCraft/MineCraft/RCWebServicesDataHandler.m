//
//  RCWebServicesDataHandler.m
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

#import "RCWebServicesDataHandler.h"
#import "RCWebServicesRequestCache.h"


#pragma mark -
#pragma mark Magical Values You May Want To Alter

#define kRC_TimeoutInterval (300)


#pragma mark -
#pragma mark Private Declarations

@interface RCWebServicesDataHandler ()


@property (nonatomic, retain) NSURLConnection * urlConnection;
@property (nonatomic, retain) NSMutableData * responseData;

@property (nonatomic, copy) ExecutionBlock connectionSuccessfulBlock;
@property (nonatomic, copy) ExecutionBlock connectionFailureBlock;


@end


#pragma mark -
#pragma mark Less Private Implementation

@implementation RCWebServicesDataHandler
{
    BOOL responseIsCacheable_;
    BOOL requestInProgress_;
    
    NSString * urlRequestString_;
}


- (id)init
{
    self = [super init];
    
    [self setResponseData:[[NSMutableData alloc] init]];
    
    return self;
}


#pragma mark -
#pragma mark Entry Methods

- (void)requestDataForURLRequestString:(NSString *)urlRequestString
                   responseIsCacheable:(BOOL)responseIsCacheable
             successfulCompletionBlock:(ExecutionBlock)successBlock
           unsuccessfulCompletionBlock:(ExecutionBlock)failureBlock;
{
    assert(urlRequestString != nil);
    assert(successBlock != nil);
    
    
    // Let's set some stuff
    
    responseIsCacheable_    = responseIsCacheable;
    urlRequestString_       = [urlRequestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self setConnectionSuccessfulBlock:successBlock];
    [self setConnectionFailureBlock:failureBlock];
    
    
    // Let's reset some stuff
    
    if (requestInProgress_)
    {
        [_urlConnection cancel];
    }
    _urlConnection = nil;
    
    [_responseData resetBytesInRange:NSMakeRange(0, _responseData.length)];
    
    
    // Let's see if we have that stuff, or need that stuff
    
    id responseData = [[RCWebServicesRequestCache sharedInstance] responseForKey:urlRequestString_];
    
    if (responseData != nil
     && responseIsCacheable_)
    {
        if ([self connectionSuccessfulBlock] != nil)    // Safety first
        {
            ((void (^)(id data))self.connectionSuccessfulBlock)(responseData);
        }
        [self setConnectionSuccessfulBlock:nil];
    }
    else
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        requestInProgress_ = YES;
        
        _urlConnection = [[NSURLConnection alloc] initWithRequest:[self buildUrlRequest]
                                                         delegate:self
                                                 startImmediately:YES];
    }
}


#pragma mark -
#pragma mark Hulk Help Puny Code

- (NSURLRequest *)buildUrlRequest;
{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    
    [request setTimeoutInterval:kRC_TimeoutInterval];
    [request setURL:[NSURL URLWithString:urlRequestString_]];
    
    
    /*  There are cases where you may want to post some data too.
     *
     *  Well, there's some more plumbing involved, and I like to keep
     *  this base class simple, but below is the gist to setting up the
     *  NSURLRequest properly.
     *
     
    if (this_is_a_post)
    {
        [request setHTTPMethod:@"POST"];
        
        [request setValue:@"application/json"
       forHTTPHeaderField:@"content-type"];
        
        [request setValue:@"application/json"
       forHTTPHeaderField:@"accept"];
        
        
        NSError * error = nil;
        NSData * bodyData = [NSJSONSerialization dataWithJSONObject:your_post_data
                                                            options:0
                                                              error:&error];
        
        if (error)
        {
            [_delegate call_a_post_failed_delegate_method];
            return nil;
        }
        
        
        [request setHTTPBody:bodyData];
    }
     
     *
     */
    
    
    return request;
}


#pragma mark -
#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([self connectionFailureBlock] != nil)
    {
        ((void (^)(id data))self.connectionFailureBlock)(@{ @"error" : error });
    }
    [self setConnectionSuccessfulBlock:nil];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
    id responseData = nil;
    responseData = [NSJSONSerialization JSONObjectWithData:[self responseData]
                                                   options:kNilOptions
                                                     error:nil];
    NSLog(@"response object is:\n\n%@\n\n", [responseData description]);    // Debugging.
    
    
    if (responseIsCacheable_)
    {
        [[RCWebServicesRequestCache sharedInstance] addResponse:responseData
                                                         forKey:urlRequestString_];
    }
    
    
    if ([self connectionSuccessfulBlock] != nil)    // Safety first
    {
        ((void (^)(id data))self.connectionSuccessfulBlock)(responseData);
    }
    [self setConnectionSuccessfulBlock:nil];
}


@end
