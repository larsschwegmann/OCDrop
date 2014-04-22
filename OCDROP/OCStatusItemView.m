//
//  OCStatusItemView.m
//  OCDROP
//
//  Created by Lars Schwegmann on 21.04.14.
//  Copyright (c) 2014 Lars Schwegmann. All rights reserved.
//

//-------------------------------------------------------------------------------------------------------------

#define StatusItemViewPaddingWidth  4
#define StatusItemViewPaddingHeight 4

//-------------------------------------------------------------------------------------------------------------

#import "OCStatusItemView.h"

//-------------------------------------------------------------------------------------------------------------

@interface OCStatusItemView ()

@property (nonatomic, strong) NSString *uploadedFilePath;

@property (nonatomic, assign) BOOL parserIsInURLElement;
@property (nonatomic, strong) NSString *shareURLString;

@end

//-------------------------------------------------------------------------------------------------------------

@implementation OCStatusItemView

//-------------------------------------------------------------------------------------------------------------
#pragma mark - NSView Methods
//-------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Get drag notifications
        [self registerForDraggedTypes:[NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
        _statusItem = nil;
        _isMenuVisible = NO;
        
        //DAV Setup
        OCSettings *settings = [OCSettings sharedInstance];
        DAVCredentials *credentials = [[DAVCredentials alloc] initWithUsername:settings.username password:settings.password];
        NSString *urlString = [NSString stringWithFormat:@"%@/remote.php/webdav", settings.baseURL];
        if (settings.subdirectoryPath){
            urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"/%@", settings.subdirectoryPath]];
        }
        _davSession = [[DAVSession alloc] initWithRootURL:[NSURL URLWithString:urlString] credentials:credentials];
        _davSession.allowUntrustedCertificate = YES;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Draw status bar background, highlighted if menu is showing
    [_statusItem drawStatusBarBackgroundInRect:[self bounds] withHighlight:_isMenuVisible];
    
    if (_isMenuVisible){
        [[NSImage imageNamed:@"cloud white"] drawInRect:CGRectMake(StatusItemViewPaddingWidth, StatusItemViewPaddingHeight, 21, 13) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }else{
        [[NSImage imageNamed:@"cloud"] drawInRect:CGRectMake(StatusItemViewPaddingWidth, StatusItemViewPaddingHeight, 21, 13) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
}

//-------------------------------------------------------------------------------------------------------------
#pragma mark Click Handling
//-------------------------------------------------------------------------------------------------------------

- (void)mouseDown:(NSEvent *)event
{
    [[self menu] setDelegate:self];
    [_statusItem popUpStatusItemMenu:[self menu]];
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event
{
    // Treat right-click just like left-click
    [self mouseDown:event];
}

//-------------------------------------------------------------------------------------------------------------
#pragma mark - NSMenuDelegate
//-------------------------------------------------------------------------------------------------------------

- (void)menuWillOpen:(NSMenu *)menu
{
    _isMenuVisible = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu
{
    _isMenuVisible = NO;
    [menu setDelegate:nil];
    [self setNeedsDisplay:YES];
}

//-------------------------------------------------------------------------------------------------------------
#pragma mark Drag Handling
//-------------------------------------------------------------------------------------------------------------

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

//perform the drag and log the files that are dropped
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        if (files.count == 1){
            _uploadedFilePath = [[files firstObject] lastPathComponent];
            DAVPutRequest *putRequest = [[DAVPutRequest alloc] initWithPath:[[files firstObject] lastPathComponent]];
            putRequest.delegate = self;
            putRequest.data = [NSData dataWithContentsOfFile:[files firstObject]];
            [_davSession enqueueRequest:putRequest];
        }else{
            NSUserNotification *errorNotification = [[NSUserNotification alloc] init];
            errorNotification.title = @"OCDrop - Error";
            errorNotification.informativeText = @"Only 1 file is supported ATM. Fork -> https://github.com/larsschwegmann/OCDrop";
            errorNotification.soundName = NSUserNotificationDefaultSoundName;
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:errorNotification];
        }
    }
    return YES;
}

//-------------------------------------------------------------------------------------------------------------
#pragma mark - DAVSessionDelegate
//-------------------------------------------------------------------------------------------------------------

// The error can be a NSURLConnection error or a WebDAV error
- (void)request:(DAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSUserNotification *errorNotification = [[NSUserNotification alloc] init];
    errorNotification.title = @"OCDrop - Error";
    errorNotification.informativeText = @"Upload failes. Check your network connection.";
    errorNotification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:errorNotification];
}

// The resulting object varies depending on the request type
- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result
{
    //Share and copy link to clipboard
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFXMLParserResponseSerializer serializer]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:[[OCSettings sharedInstance] username] password:[[OCSettings sharedInstance] password]];
    NSDictionary *params = @{
                             @"path" : [[[[OCSettings sharedInstance] subdirectoryPath] stringByAppendingString:@"/"] stringByAppendingString:_uploadedFilePath],
                             @"shareType" : [NSNumber numberWithInt:3] //Public
                             };
    
    NSString *urlString = [NSString stringWithFormat:@"%@/ocs/v1.php/apps/files_sharing/api/v1/shares", [[OCSettings sharedInstance] baseURL]];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _shareURLString = nil;
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        parser.delegate = self;
        [parser parse];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        NSUserNotification *errorNotification = [[NSUserNotification alloc] init];
        errorNotification.title = @"OCDrop - Error";
        errorNotification.informativeText = @"Could not retrieve URL. Check if the sharing module is enabled in your owncloud.";
        errorNotification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:errorNotification];
    }];
}

- (void)requestDidBegin:(DAVRequest *)aRequest{
    
}

//-------------------------------------------------------------------------------------------------------------
#pragma mark - NSXMLParserDelegate
//-------------------------------------------------------------------------------------------------------------

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"url"]){
        _parserIsInURLElement = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (_parserIsInURLElement){
        if (_shareURLString){
            _shareURLString = [_shareURLString stringByAppendingString:string];
        }else{
            _shareURLString = string;
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"url"]){
        _parserIsInURLElement = NO;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (_shareURLString == nil){
        NSUserNotification *errorNotification = [[NSUserNotification alloc] init];
        errorNotification.title = @"OCDrop - Error";
        errorNotification.informativeText = @"Internal error -> https://github.com/larsschwegmann/OCDrop";
        errorNotification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:errorNotification];
    }else{
        if ([OCSettings sharedInstance].shortenURLs){
            _shareURLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@", _shareURLString]] encoding:NSASCIIStringEncoding error:nil];
        }
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [pasteBoard declareTypes:@[NSStringPboardType] owner:nil];
        [pasteBoard setString:_shareURLString forType:NSStringPboardType];
        
        NSUserNotification *successNotification = [[NSUserNotification alloc] init];
        successNotification.title = @"OCDrop - Success!";
        successNotification.informativeText = @"The link has been copied to your clipboard!";
        successNotification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:successNotification];
    }
}

@end

//-------------------------------------------------------------------------------------------------------------
