//
//  OCSettings.m
//  OCDROP
//
//  Created by Lars Schwegmann on 21.04.14.
//  Copyright (c) 2014 Lars Schwegmann. All rights reserved.
//

//-------------------------------------------------------------------------------------------------------------

#import "OCSettings.h"

//-------------------------------------------------------------------------------------------------------------

@implementation OCSettings

//-------------------------------------------------------------------------------------------------------------
#pragma mark - Shared Instance
//-------------------------------------------------------------------------------------------------------------

+ (instancetype)sharedInstance
{
    static OCSettings *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OCSettings alloc] init];
    });
    
    return sharedInstance;
}

//-------------------------------------------------------------------------------------------------------------
#pragma mark - Getters
//-------------------------------------------------------------------------------------------------------------

- (NSString *)username
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
}

- (NSString *)password
{
    return [RFKeychain passwordForAccount:self.username service:@"owncloud"];
}

- (NSString *)baseURL
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"baseURL"];
}

- (NSString *)subdirectoryPath
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"subdirectoryPath"];
}

- (BOOL)trustSelfSignedCertificates
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"trustSelfSignedCertificates"];
}

- (BOOL)shortenURLs
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"shortenURLs"];
}

//-------------------------------------------------------------------------------------------------------------
#pragma mark - Setters
//-------------------------------------------------------------------------------------------------------------

- (void)setUsername:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
}

- (void)setPassword:(NSString *)password
{
    [RFKeychain setPassword:password account:self.username service:@"owncloud"];
}

- (void)setBaseURL:(NSString *)baseURL
{
    [[NSUserDefaults standardUserDefaults] setObject:baseURL forKey:@"baseURL"];
}

- (void)setSubdirectoryPath:(NSString *)subdirectoryPath
{
    [[NSUserDefaults standardUserDefaults] setObject:subdirectoryPath forKey:@"subdirectoryPath"];
}

- (void)setTrustSelfSignedCertificates:(BOOL)trustSelfSignedCertificates
{
    [[NSUserDefaults standardUserDefaults] setBool:trustSelfSignedCertificates forKey:@"trustSelfSignedCertificates"];
}

- (void)setShortenURLs:(BOOL)shortenURLs
{
    [[NSUserDefaults standardUserDefaults] setBool:shortenURLs forKey:@"shortenURLs"];
}

@end

//-------------------------------------------------------------------------------------------------------------
