cage-the-mine
=============

A sample project showing the two classes I typically use to  interact with web services.  It utilizes blocks to allow for a more maintainable (and readable) code base.


So why this way?
================

Good question.  There’s a slew of minor reasons I like these classes, but the major ones are:
* centralized service code
* simple implementation
* helps keep your code readable and maintainable

A one stop web service shop, eh?
--------------------------------

Indeed.  Most tasks you find yourself repeating throughout your code base should be centralized to a logical area, perhaps a service, or a base class, a factory, or what have you, and this code is no different.  It gives you a central point to make tweaks to how the rest of your code interacts with data outside of your app.

Easy to use?
------------

I hope so.  The simple implementation is just that, simple.  All the service wants to do is give you the data you requested, executing the code you provided when it does.  To that end it takes in two blocks of code along with the request data, a block that runs if it successfully retrieved data for you, and a block that runs if it failed to retrieve the data for you.

Some examples are shown in the next section.

The right code in the right places... I like it.
------------------------------------------------

So do I.  Readability and maintainability (R&M) are very important factors for any code base.  Your code base is no exception.  We can debate the ‘right’ location for certain snippets of code, but I like to repeat this phrase when working on a MVC project:

“I like my Models fat, and my Controllers skinny.”

The completion blocks are a big help on the R&M front, but part of the onus is on you.  With this implementation it is quite simple to keep your purely data driven operations (CRUD operations) in your models, while still having the flexibility to make a web service call from your controller when the need arises.


OK, so how to I use this in my project?
=======================================

Well,

1. Add the RCWebServicesDataHandler.h/.m and RCWebServicesRequestCache.h/.m to your project
2. Ask it for some data

For example,

Let's get an instance of the web service

		RCWebServicesDataHandler * fbAquirer = [[RCWebServicesDataHandler alloc] init];

Then let's ask it to retrieve some data for us

		[fbAquirer requestDataForURLRequestString:@"https://graph.facebook.com/LRyanCrews"
                        withRequestParameters:nil
                          responseIsCacheable:YES
                    successfulCompletionBlock:^(id data)
                    {
                        // We can do fun things with our data here.
                        // check out the example projects and you'll
                        // see in the model I'm setting values
                        // and then calling another block that was passed
                        // in (becuase nesting blocks are cool).
                    }
                  unsuccessfulCompletionBlock:nil];

So that was fun.  We... 
1. requested my FB data 
2. which didn't require any additional parameters 
3. let it know we're fine with the data being cached
4. told it what we want to do when it's done getting the data
5. and told it we don't want to do anything if it fails

The example project itself will show better how this can be utilized, and you'll find the methods are commented thoroughly, and hopefully accurately =)


There's other methods too!  Right?
==================================

Yes there are.  Here are their signatures to give you a quick idea as to what goes into the different calls:

GET

		- (void)requestDataForURLRequestString:(NSString *)urlRequestString
                 		 withRequestParameters:(NSDictionary *)urlRequestParameters
                       responseIsCacheable:(BOOL)responseIsCacheable
                 successfulCompletionBlock:(ExecutionBlock)successBlock
               unsuccessfulCompletionBlock:(ExecutionBlock)failureBlock;

POST

		- (void)postDataForURLPostString:(NSString *)urlPostString
                  withPostParameters:(NSDictionary *)urlPostParameters
           successfulCompletionBlock:(ExecutionBlock)successBlock
         unsuccessfulCompletionBlock:(ExecutionBlock)failureBlock;

PUT

		- (void)putDataForURLPutString:(NSString *)urlPutString
                 withPutParameters:(NSDictionary *)urlPutParameters
         successfulCompletionBlock:(ExecutionBlock)successBlock
       unsuccessfulCompletionBlock:(ExecutionBlock)failureBlock;

DELETE

		- (void)deleteForURLDeleteString:(NSString *)urlDeleteString
           successfulCompletionBlock:(ExecutionBlock)successBlock
         unsuccessfulCompletionBlock:(ExecutionBlock)failureBlock;


Anything else I should know about?
==================================

Probably.  I will mention a few things though...

* The service assumes JSON is the response.  It would be easy to alter it to assume some other type, or to allow for several types, but I find I’m always receiving JSON from web services, and therefore decided to keep it simple for the 90%+ cases.
* If you plan on updating UI in your completion block you may want to ensure you execute that code on the main thread.  Just a heads up as it’s easy to forget that you’re not always on the main thread in this asynchronous world.
* This example is rather spartan, but imagine the pattern throughout your code base.  I cannot describe the improvement in R&M (and performance, though that was likely due to an issue with the previous code and/or the caching) on a rather large project I work on when I switched the web service calls to this.

I hope you enjoyed reading this schizophrenic README file, and I really hope you find this useful.

If you find any bugs or issues, or if you make improvements, please let me know so I may incorporate fixes/new code.

Thank,
~ Ryan =]
