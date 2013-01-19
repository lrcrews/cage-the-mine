//
//  ViewController.m
//  MineCraft
//
//  Hello, how are you?
//
//  <reading your thoughts...>
//
//  Well I suppose that is how things go.  I'm fine.
//  Actually I'm fanastic, like a butterfly just waking up
//  amid a wonderful harem (harlem?) of eager female butterflies
//  who appreciate the things I like, and are as equally crazy
//  (f'ed up?) as I am.. but you know, not in a bitchy way.
//
//  <glancing at your soul...>
//
//  Okay, we'll stick with "fine".
//
//  <hearing what should be your next question...>
//
//  Here?  Well, we have a rather hacked together example of how
//  one could use the web service classes I find myself continously
//  using.  I thought I'd share 'em in the hopes that someone is helped
//  and others may help me by improving them.  I try to keep them
//  simple.  They're under the "Helpers and Stuff" group.  Enjoy.
//
//  <listening to Javelin while I should be listening to you... I'll fake it...>
//
//  You too.
//
//  Created by Leonard Ryan Crews on 10/2/12.
//  Copyright (c) 2012 Leonard Ryan Crews. All rights reserved.
//

#import "ViewController.h"

#import "FacebookUser.h"

#import "RCWebServicesDataHandler.h"
#import "RCWebServicesRequestCache.h"


@interface ViewController ()


@property (nonatomic, retain) IBOutlet UITextField * facebookUserName;

@property (nonatomic, retain) IBOutlet UILabel * facebookId;
@property (nonatomic, retain) IBOutlet UILabel * facebookFirstNameOrCompanyName;
@property (nonatomic, retain) IBOutlet UILabel * facebookLastNameOrLikes;
@property (nonatomic, retain) IBOutlet UILabel * facebookGenderOrCategory;


@property (nonatomic, retain) FacebookUser * fbUserForConsoleLoggedExample;


@end


@implementation ViewController
{
    FacebookUser * displayedUser_;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Initial call for UI
    
    displayedUser_ = [[FacebookUser alloc] init];
    [displayedUser_ requestFacebookUserFromURLRequestString:@"https://graph.facebook.com/LRyanCrews"
                                        withCompletionBlock:^{
                                            
                                            [self updateFBUserDisplay];
                                        }];
    
    
    // Log a different kind of web service call example (... too lazt to have more UI)
    
    [self whatDoWeHaveHere];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSLog(@"UNLESS YOU INTERNET IS SLOW, DATA IS:: User of id \"%@\", named \"%@\"", [self.fbUserForConsoleLoggedExample id], [self.fbUserForConsoleLoggedExample name]);
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [RCWebServicesRequestCache flushCache];
}


- (void)updateFBUserDisplay
{
    //  No id implies the user was not found
    
    if ([displayedUser_ id] == nil)
    {
        [[self facebookFirstNameOrCompanyName] setText:[NSString stringWithFormat:@"\"%@\" not found", [self.facebookUserName text]]];
        return;
    }
    
    
    // The Happy Path
    
    if ([displayedUser_ isPerson])
    {
        [[self facebookId] setText:[NSString stringWithFormat:@"ID: %@", [displayedUser_ id]]];
        [[self facebookFirstNameOrCompanyName] setText:[NSString stringWithFormat:@"FIRST NAME: %@", [displayedUser_ first_name]]];
        [[self facebookLastNameOrLikes] setText:[NSString stringWithFormat:@"LAST NAME: %@", [displayedUser_ last_name]]];
        [[self facebookGenderOrCategory] setText:[NSString stringWithFormat:@"GENDER: %@", [displayedUser_ gender]]];
    }
    else
    {
        [[self facebookId] setText:[NSString stringWithFormat:@"ID: %@", [displayedUser_ id]]];
        [[self facebookFirstNameOrCompanyName] setText:[NSString stringWithFormat:@"COMAPNY: %@", [displayedUser_ name]]];
        [[self facebookLastNameOrLikes] setText:[NSString stringWithFormat:@"LIKES: %@", [displayedUser_ likes]]];
        [[self facebookGenderOrCategory] setText:[NSString stringWithFormat:@"CATEGORY: %@", [displayedUser_ category]]];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    [[self facebookId] setText:@""];
    [[self facebookFirstNameOrCompanyName] setText:[NSString stringWithFormat:@"Finding \"%@\"...", [self.facebookUserName text]]];
    [[self facebookLastNameOrLikes] setText:@""];
    [[self facebookGenderOrCategory] setText:@""];
    
    
    [displayedUser_ requestFacebookUserFromURLRequestString:[NSString stringWithFormat:@"https://graph.facebook.com/%@", [self.facebookUserName text]]
                                        withCompletionBlock:^{
                                            
                                            [self updateFBUserDisplay];
                                        }];
}


#pragma mark -
#pragma mark Twain

- (void)whatDoWeHaveHere;
{
    //  Of course not all your web service calls will return a hash version of your model.
    //  Sometimes you expect a result which you must further manipulate or massage.  No
    //  worries, that's easy too...
    
    RCWebServicesDataHandler * indirectDataHandler = [[RCWebServicesDataHandler alloc] init];
    [indirectDataHandler requestDataForURLRequestString:@"https://graph.facebook.com/search?until=yesterday&q=orange&limit=3"
                                  withRequestParameters:nil
                                    responseIsCacheable:NO
                              successfulCompletionBlock:^(id data){
                                  
                                  // You'll know something about your web service, why else
                                  // would you be calling it?  Sure, what I'm about to do is not
                                  // ideal, but you get the point.
                                  
                                  // Safety Check
                                  
                                  if (![data respondsToSelector:@selector(objectForKey:)])
                                  {
                                      NSLog(@"Odd, this used to be a dictionary response...");
                                      return;
                                  }
                                  
                                  
                                  // Paging Data
                                  
                                  NSDictionary * pagingInfo = data[@"paging"];
                                  if (pagingInfo != nil)
                                  {
                                      NSLog(@"PAGING INFO:");
                                      NSLog(@"URL to next page is \"%@\"", pagingInfo[@"next"]);
                                      NSLog(@"URL to previous page is \"%@\"", pagingInfo[@"previous"]);
                                      NSLog(@"\n\n");
                                  }
                                  
                                  
                                  // Some Captions
                                  
                                  NSLog(@"CAPTIONS:");
                                  
                                  NSArray * results = data[@"data"];
                                  for (NSDictionary * fbPostData in results)
                                  {
                                      NSLog(@"%@", fbPostData[@"caption"]);
                                  }
                                  NSLog(@"\n\n");
                                  
                                  
                                  // FacebookUser Model
                                  
                                  NSLog(@"USER DATA:");
                                  
                                  if ([results count] > 0)
                                  {
                                      NSDictionary * post = results[0];
                                      _fbUserForConsoleLoggedExample = [[FacebookUser alloc] initWithDictionary:post[@"from"]];
                                      NSLog(@"User of id \"%@\", named \"%@\"", [self.fbUserForConsoleLoggedExample id], [self.fbUserForConsoleLoggedExample name]);
                                  }
                                  else
                                  {
                                      NSLog(@"No posts?!?!?  Awwww.");
                                  }
                              }
                            unsuccessfulCompletionBlock:^(id data){
                            
                                NSLog(@"Well... this is, unexpected.  The error?  It's %@", data[@"error"]);
                            }];
    
    
    // The block is unlikely to have populated this property yet, hence the data is null here,
    // and, it's logged before the data in the block is logged.  
    
    NSLog(@"SHOULD BE NULL DATA:: User of id \"%@\", named \"%@\"", [self.fbUserForConsoleLoggedExample id], [self.fbUserForConsoleLoggedExample name]);
    
    
    
    
    // And you could nest them too, which I'm not going to show (lazy, slightly drunk), but
    // you've likely nested animation blocks before, so you're good, right?
    
    NSLog(@"THIS LOGGING BROUGHT TO YOU BY.... whatDoWeHaveHere, when you want show something, but UI seems like overkill <the method at the bottom of the ViewController.m>");
}


@end
