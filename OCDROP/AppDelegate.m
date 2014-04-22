//
//  AppDelegate.m
//  OCDROP
//
//  Created by Lars Schwegmann on 21.04.14.
//  Copyright (c) 2014 Lars Schwegmann. All rights reserved.
//

//-------------------------------------------------------------------------------------------------------------

#import "AppDelegate.h"

//-------------------------------------------------------------------------------------------------------------

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
}

- (void)awakeFromNib
{
    [[OCSettings sharedInstance] setUsername:@""];
    [[OCSettings sharedInstance] setPassword:@""];
    [[OCSettings sharedInstance] setBaseURL:@""];
    [[OCSettings sharedInstance] setSubdirectoryPath:@""];
    [[OCSettings sharedInstance] setTrustSelfSignedCertificates:YES];
    [[OCSettings sharedInstance] setShortenURLs:YES];
    
    [_preferencesMenuItem setEnabled:YES];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:29];
    [_statusItem setMenu:_statusMenu];
    
    OCStatusItemView *statusItemView = [[OCStatusItemView alloc] init];
    [_statusItem setView:statusItemView];
    statusItemView.menu = _statusMenu;
    statusItemView.statusItem = _statusItem;
    [_statusItem setHighlightMode:YES];
}

@end

//-------------------------------------------------------------------------------------------------------------