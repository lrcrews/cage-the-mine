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

#import "RCWebServicesRequestCache.h"


@interface ViewController ()


@property (nonatomic, retain) IBOutlet UITextField * facebookUserName;

@property (nonatomic, retain) IBOutlet UILabel * facebookId;
@property (nonatomic, retain) IBOutlet UILabel * facebookFirstNameOrCompanyName;
@property (nonatomic, retain) IBOutlet UILabel * facebookLastNameOrLikes;
@property (nonatomic, retain) IBOutlet UILabel * facebookGenderOrCategory;


@end


@implementation ViewController
{
    FacebookUser * displayedUser_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    displayedUser_ = [[FacebookUser alloc] init];
    [displayedUser_ requestFacebookUserFromURLRequestString:@"https://graph.facebook.com/LRyanCrews"
                                        withCompletionBlock:^{ [self updateFBUserDisplay]; }];
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
                                        withCompletionBlock:^{ [self updateFBUserDisplay]; }];
}


@end
