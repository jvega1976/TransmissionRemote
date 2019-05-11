//
//  AppDelegate.m
//  TransmissionRPClient
//
//  Created by Johnny Vega on 1/26/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "AppDelegate.h"
#import <NSTransmissionRPC/NSTransmissionRPC.h>
#import "WindowController.h"
#import "AddTorrentController.h"
#import "NSApplicationAdditions.h"
#import <UserNotifications/UserNotifications.h>
#import "URLConfig.h"

@interface AppDelegate()

@property (strong, nonatomic) NSStatusItem *statusBar;

@end

@implementation AppDelegate {
    
    WindowController *_windowController;
    AddTorrentController  *addTorrentController;
    NSMutableArray<TorrentFile*>* torrentFiles;
    BOOL haveFilesToOpen;
    NSUserDefaults *defaults;
}

- (void) awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.statusBar.button.image = [NSImage imageNamed: @"statusBarIcon"];
    self.statusBar.menu = _menuBar;
}

-(void)applicationWillFinishLaunching:(NSNotification *)notification {
    torrentFiles = [NSMutableArray array];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    defaults = [[NSUserDefaults alloc] initWithSuiteName:TR_URL_DEFAULTS];
//    [defaults removeObjectForKey:@"SpeedMenuItems"];
//    [defaults synchronize];
    NSDictionary *dict = @{@"name":@"TheServer",@"host":@"hostname",@"port":@(9091),@"userName":@"jdoe",@"userPassword":@"*****",@"useSSL":@(NO),@"requireAuth":@(NO),@"defaultServer":@(NO),@"rpcPath":@"/transmission/rpc"};
    NSArray *configArray = [NSArray arrayWithObject:dict];
    NSMutableDictionary *appDefaults = [NSMutableDictionary dictionaryWithObject:configArray forKey:TR_URL_CONFIG_KEY];
    [appDefaults setValue:@(-1) forKey:TR_URL_ACTUAL_KEY];
    [appDefaults setValue:@(10) forKey:TR_URL_CONFIG_REQUEST];
    [appDefaults setValue:@(10) forKey:TR_URL_CONFIG_REFRESH];
    [appDefaults setValue:@"none" forKey:@"videoApplication"];
    [appDefaults setValue:[NSArray array] forKey: @"DirectoryMapping"];
    [appDefaults setObject:@[@{@"rate":@(50)},@{@"rate":@(100)},@{@"rate":@(250)},@{@"rate":@(500)},@{@"rate":@(1024)}] forKey:@"SpeedMenuItems"];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge + UNAuthorizationOptionProvisional) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error)
                NSLog(@"%@",error.localizedDescription);
            // Enable or disable features based on authorization.
    }];
    
    [[NSNotificationCenter defaultCenter]
        addObserver: self
        selector: @selector(storeChanged:)
        name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
        object: [NSUbiquitousKeyValueStore defaultStore]];
    // get changes that might have happened while this
    // instance of your app wasn't running
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    if(torrentFiles.count > 0) {
        NSLog(@"Running Application DidFinishLaunching");
        addTorrentController = instantiateController(@"AddTorrentController");
        NSLog(@"Add Controller: %@",addTorrentController.identifier);
        NSLog(@"Number of files to open: %lu",torrentFiles.count);
        for(TorrentFile *file in torrentFiles) {
            NSLog(@"Opening File: %@",file.name);
            addTorrentController.torrentFile = file;
            [NSApplication.sharedApplication.mainWindow.contentViewController presentViewControllerAsSheet:addTorrentController];
        }
    }
    
    [self loadSpeedLimitMenuItems];
}


-(void)loadSpeedLimitMenuItems {
    
    NSArray *speedItems = [defaults arrayForKey:@"SpeedMenuItems"];
    [_maximumDownloadSpeedSubmenu removeAllItems];
    [_maximumUploadSpeedSubmenu removeAllItems];
    for (NSDictionary *i in speedItems) {
        NSMenuItem *menuItemDownload = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ Kb/s", i[@"rate"]]  action:@selector(limitDownloadRateWithSpeed:) keyEquivalent:@""];
        menuItemDownload.tag = [i[@"rate"] integerValue];
        [_maximumDownloadSpeedSubmenu addItem:menuItemDownload];
        NSMenuItem *menuItemUpload = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ Kb/s", i[@"rate"]] action:@selector(limitUploadRateWithSpeed:) keyEquivalent:@""];
        menuItemUpload.tag = [i[@"rate"] integerValue];
        [_maximumUploadSpeedSubmenu addItem:menuItemUpload];
    }
}


- (void)storeChanged:(NSNotification*)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *reason = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    
    if (reason!=nil) {
        NSInteger reasonValue = [reason integerValue];
        NSLog(@"storeChanged with reason %ld", (long)reasonValue);
        
        if ((reasonValue == NSUbiquitousKeyValueStoreServerChange) ||
            (reasonValue == NSUbiquitousKeyValueStoreInitialSyncChange)) {
            
            NSArray *keys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
            NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:TR_URL_DEFAULTS];
            
            for (NSString *key in keys) {
                id value = [store objectForKey:key];
                [userDefaults setObject:value forKey:key];
                NSLog(@"storeChanged updated value for %@",key);
                [userDefaults synchronize];
            }
        }
    }
}

-(void)applicationDidBecomeActive:(NSNotification *)notification {
    NSApplication.sharedApplication.dockTile.badgeLabel = @"";
    [NSApplication.sharedApplication.dockTile display];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    if (![NSApp keyWindow])
        [_windowController showWindow:self];
    return YES;
}


- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames {
    addTorrentController = instantiateController(@"AddTorrentController");
    NSLog(@"Is running Open File method.");
    for (NSString *filename in filenames){
        NSURL *url = [NSURL fileURLWithPath:filename];
        NSLog(@"URL for filename %@: %@",filename,url.absoluteString);
        TorrentFile *file = [TorrentFile torrentFileWithURL:url];
        if(sender.isActive) {
            addTorrentController.torrentFile = file;
            [NSApplication.sharedApplication.mainWindow.contentViewController presentViewControllerAsSheet:addTorrentController];
        }
        else
            [torrentFiles addObject:file];
    }
    [sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}


@end
