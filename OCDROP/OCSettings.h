//
//  OCSettings.h
//  OCDROP
//
//  Created by Lars Schwegmann on 21.04.14.
//  Copyright (c) 2014 Lars Schwegmann. All rights reserved.
//

//-------------------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

#import <RFKeychain/RFKeychain.h>

//-------------------------------------------------------------------------------------------------------------

@interface OCSettings : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *subdirectoryPath;
@property (nonatomic, assign) BOOL trustSelfSignedCertificates;
@property (nonatomic, assign) BOOL shortenURLs;

+ (instancetype)sharedInstance;

@end

//-------------------------------------------------------------------------------------------------------------