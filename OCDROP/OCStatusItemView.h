//
//  OCStatusItemView.h
//  OCDROP
//
//  Created by Lars Schwegmann on 21.04.14.
//  Copyright (c) 2014 Lars Schwegmann. All rights reserved.
//

//-------------------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

#import <DAVKit/DAVKit.h>
#import <AFNetworking/AFNetworking.h>

#import "OCSettings.h"

//-------------------------------------------------------------------------------------------------------------

@interface OCStatusItemView : NSView <NSMenuDelegate, DAVRequestDelegate, NSXMLParserDelegate>

@property (nonatomic, strong) DAVSession *davSession;

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImageView *cloudImageView;
@property (nonatomic, assign) BOOL isMenuVisible;

@end

//-------------------------------------------------------------------------------------------------------------
