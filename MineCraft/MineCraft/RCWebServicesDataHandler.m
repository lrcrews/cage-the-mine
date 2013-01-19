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

#import "Constants.h"


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
    BOOL requestIsPostPutOrDelete_;
    
    NSString * httpMethod_;
    
    NSMutableString * urlRequestString_;
    NSMutableDictionary * postData_;
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
                 withRequestParameters:(NSDictionary *)urlRequestParameters
                   responseIsCacheable:(BOOL)responseIsCacheable
             successfulCompletionBlock:(ExecutionBlock)successBlock
           unsuccessfulCompletionBlock:(ExecutionBlock)failureBlock;
{
    assert(urlRequestString != nil);
    assert(successBlock != nil);
    
    
    //DebugLog(@"Raw request string: %@", urlRequestString);    // Debugging.  Intensively.
    
    
    // Let's set some stuff
    
    requestIsPostPutOrDelete_ = NO;
    httpMethod_ = @"GET";
    responseIsCacheable_ = responseIsCacheable;
    
    urlRequestString_ = [[urlRequestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    if (urlRequestParameters != nil)
    {
        [urlRequestString_ appendString:@"?"];
        
        for (NSString * currentKey in [urlRequestParameters allKeys])
        {
            [urlRequestString_ appendFormat:@"%@=%@&", currentKey, [urlRequestParameters objectForKey:currentKey]];
        }
        [urlRequestString_ deleteCharactersInRange:NSMakeRange([urlRequestString_ length] - 1, 1)];
    }
    DebugLog(@"Parametered request string: %@", urlRequestString_);
    
    
    [self setConnectionSuccessfulBlock:successBlock];
    [self setConnectionFailureBlock:failureBlock];
    
    
    // Let's reset some stuff
    
    [self resetConnection];
    
    
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


- (void)postDataForURLPostString:(NSString *)urlPostString
              withPostParameters:(NSDictionary *)urlPostParameters
       successfulCompletionBlock:(ExecutionBlock)successBlock
     unsuccessfulCompletionBlock:(ExecutionBlock)failureBlock;
{
    assert(urlPostString != nil);
    assert(successBlock != nil);
    
    
    DebugLog(@"Post string: %@", urlPostString);
    
    
    // Set up
    
    requestIsPostPutOrDelete_ = YES;
    httpMethod_ = @"POST";
    responseIsCacheable_ = NO;
    
    urlRequestString_ = [[urlPostString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
    [self setConnectionSuccessfulBlock:successBlock];
    [self setConnectionFailureBlock:failureBlock];
    
    
    // Set, re
    
    [self resetConnection];
    
    
    // Set off
    
    if (postData_ == nil)
    {
        postData_ = [[NSMutableDictionary alloc] init];
    }
    [postData_ addEntriesFromDictionary:urlPostParameters];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    requestInProgress_ = YES;
    
    _urlConnection = [[NSURLConnection alloc] initWithRequest:[self buildUrlRequest]
                                                     delegate:self
                                             startImmediately:YES];
}


- (void)putDataForURLPutString:(NSString *)urlPutString
             withPutParameters:(NSDictionary *)urlPutParameters
     successfulCompletionBlock:(ExecutionBlock)successBlock
   unsuccessfulCompletionBlock:(ExecutionBlock)failureBlock;
{
    assert(urlPutString != nil);
    assert(successBlock != nil);
    
    
    DebugLog(@"Put string: %@", urlPutString);
    
    
    // We are
    
    requestIsPostPutOrDelete_ = YES;
    httpMethod_ = @"PUT";
    responseIsCacheable_ = NO;
    
    urlRequestString_ = [[urlPutString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
    [self setConnectionSuccessfulBlock:successBlock];
    [self setConnectionFailureBlock:failureBlock];
    
    
    // out of
    
    [self resetConnection];
    
    
    // wine.
    
    if (postData_ == nil)
    {
        postData_ = [[NSMutableDictionary alloc] init];
    }
    [postData_ addEntriesFromDictionary:urlPutParameters];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    requestInProgress_ = YES;
    
    _urlConnection = [[NSURLConnection alloc] initWithRequest:[self buildUrlRequest]
                                                     delegate:self
                                             startImmediately:YES];
}


- (void)deleteForURLDeleteString:(NSString *)urlDeleteString
       successfulCompletionBlock:(ExecutionBlock)successBlock
     unsuccessfulCompletionBlock:(ExecutionBlock)failureBlock;
{
    assert(urlDeleteString != nil);
    assert(successBlock != nil);
    
    
    DebugLog(@"Delete string: %@", urlDeleteString);
    
    
    // It's ok though
    
    requestIsPostPutOrDelete_ = YES;
    httpMethod_ = @"DELETE";
    responseIsCacheable_ = NO;
    
    urlRequestString_ = [[urlDeleteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
    [self setConnectionSuccessfulBlock:successBlock];
    [self setConnectionFailureBlock:failureBlock];
    
    
    // we still have
    
    [self resetConnection];
    
    
    // beer.
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    requestInProgress_ = YES;
    
    _urlConnection = [[NSURLConnection alloc] initWithRequest:[self buildUrlRequest]
                                                     delegate:self
                                             startImmediately:YES];
}


/*
 *  The kill switch.
 */

- (void)cancelDownload;
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
    if (requestInProgress_)
    {
        [_urlConnection cancel];
    }
    requestInProgress_ = NO;
}


#pragma mark -
#pragma mark Hulk Help Puny Code

- (NSURLRequest *)buildUrlRequest;
{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    
    [request setTimeoutInterval:kRC_TimeoutInterval];
    
    [request setValue:DeviceDetails
   forHTTPHeaderField:@"User-Agent"];
    
    [request setURL:[NSURL URLWithString:urlRequestString_]];
    
    [request setHTTPMethod:httpMethod_];
    
    
    if (requestIsPostPutOrDelete_) // then it's not a request.  =]
    {
        [request setValue:@"application/json"
       forHTTPHeaderField:@"content-type"];
        
        [request setValue:@"application/json"
       forHTTPHeaderField:@"accept"];
        
        
        if (postData_ != nil)
        {
            NSError * error = nil;
            NSData * bodyData = [NSJSONSerialization dataWithJSONObject:postData_
                                                                options:0
                                                                  error:&error];
            
            if (error)
            {
                AlwaysLog(@"WARNING: could not create NSData with NSDictionary \"postData_\".");
                return nil;
            }
            
            [request setHTTPBody:bodyData];
        }
        else
        {
            AlwaysLog(@"WARNING: postData_ is nil, are you cool with that?");
        }
    }
    
    
    return request;
}


- (void)resetConnection;
{
    if (requestInProgress_)
    {
        [_urlConnection cancel];
    }
    _urlConnection = nil;
    
    postData_ = nil;
    
    [_responseData resetBytesInRange:NSMakeRange(0, _responseData.length)];
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
    
    AlwaysLog(@"Connection Error::\n\n%@\n\n", error);
    
    if ([self connectionFailureBlock] != nil)
    {
        ((void (^)(id data))self.connectionFailureBlock)(@{ @"error" : error });    // That should be a constant you define somewhere, not a magic string.
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
    //DebugLog(@"response object is:\n\n%@\n\n", [responseData description]);    // Debugging.  Intensively.
    
    
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


// The Authenication Hook
//
-                        (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (_userCredential == nil)
    {
        AlwaysLog(@"WARNING: No user credentials for auth challenge, will try admin/password just for the fun of it.");
        
        _userCredential = [[NSURLCredential alloc] initWithUser:@"admin"
                                                       password:@"password"
                                                    persistence:NSURLCredentialPersistenceNone];
        
    }
    
    DebugLog(@"Credentials exist, using them");
    [challenge.sender useCredential:_userCredential
         forAuthenticationChallenge:challenge];
}


@end