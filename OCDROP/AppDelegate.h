//
//  AppDelegate.h
//  OCDROP
//
//  Created by Lars Schwegmann on 21.04.14.
//  Copyright (c) 2014 Lars Schwegmann. All rights reserved.
//

//-------------------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

#import "OCStatusItemView.h"
#import "OCSettings.h"

//-------------------------------------------------------------------------------------------------------------

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, weak) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenuItem *preferencesMenuItem;

@end

//-------------------------------------------------------------------------------------------------------------