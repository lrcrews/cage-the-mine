//
//  RCWebServicesDataHandler.h
//  MineCraft
//
//
//  A class that centralizes the NSURLConnection code, accepting blocks
//  from other classes utilizing it to act upon the received data.
//
//  This class assumes the data is a JSON response (just fyi).
//
//  This class also interacts with a caching class "RCWebServicesRequestCache".
//  The provided implementation of the cache combines a LRU queue with a 'lifetime'
//  concept.  It is meant as a base caching system, simple and easy to extend.
//
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

#import <Foundation/Foundation.h>


typedef void(^ExecutionBlock)(id data);


@interface RCWebServicesDataHandler : NSObject <NSURLConnectionDelegate>


//  A request for JSON data from a given web service URL that
//  utilizes blocks for the on-success & on-failure scenarios
//  to improve code maintainability.
//
//  Executing this method will cancel (if applicable) the
//  currently in progress request of this instance, display the
//  Network Activity Indicator, perform NSJSONSerialization,
//  cache the response (if responseIsCacheable == YES), and
//  execute the given successBlock.
//
//  If the request resulted in connection failure the failureBlock
//  will be executed (if provided).
//
//
//  @param urlRequestString
//      NSString *
//      an unescaped string representing the url of the web service
//      must be present (enforced by an assertion)
//
//  @param responseIsCacheable
//      BOOL
//      denotes whether ot not the response should be cached
//
//  @param successBlock
//      void(^)(id data) block object,
//      must be present (enforced by an assertion)
//
//  @param failureBlock
//      void(^)(id data) block object,
//      may be nil
//
- (void)requestDataForURLRequestString:(NSString *)urlRequestString
                   responseIsCacheable:(BOOL)responseIsCacheable
             successfulCompletionBlock:(ExecutionBlock)successBlock
           unsuccessfulCompletionBlock:(ExecutionBlock)failureBlock;


@end
