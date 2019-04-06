//
//  PreferencesOtherController.m
//  Transmission Remote
//
//  Created by Johnny Vega on 3/24/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "PreferencesOtherController.h"
#import "PreferencesController.h"

#define REMOTE_DIR_KEY  @"remoteDirectory"
#define LOCAL_DIR_KEY  @"localDirectory"



@implementation NSMutableArray (NSDictionaryCreation)

-(NSArray*)arrayOfPlist {
    NSMutableArray *array = [NSMutableArray array];
    for (DirectoryMapping *object in self) {
            [array addObject:object.plist];
    }
    return array;
}

+(NSMutableArray*)arrayOfDirectoryMappings:(NSArray*)array {
    NSMutableArray *newArray = [NSMutableArray array];
    for (NSMutableDictionary *object in array) {
            [newArray addObject:[DirectoryMapping mappingFromPlist:object]];
    }
    return newArray;
}

@end


@implementation DirectoryMapping

- (instancetype)initWithRemote:(NSString *)remote andLocal:(NSString *)local {
    self = [super init];
    
    if(self) {
        self.remoteDirectory = remote;
        self.localDirectory = local;
    }
    return self;
}

- (instancetype)initFromPlist:(NSDictionary*)plist {
    self = [super init];
    
    if(self) {
        self.remoteDirectory = plist[REMOTE_DIR_KEY] ? plist[REMOTE_DIR_KEY] : nil;
        self.localDirectory = plist[LOCAL_DIR_KEY] ? plist[LOCAL_DIR_KEY] : nil;
    }
    
    return self;
}

+(DirectoryMapping *)mappingtWithRemote:(NSString *)remote andLocal:(NSString *)local {
    return [[DirectoryMapping alloc] initWithRemote:remote andLocal:local];
}

+(DirectoryMapping*)mappingFromPlist:(NSDictionary *)plist {
    return [[DirectoryMapping alloc] initFromPlist:plist];
}

-(NSDictionary*)plist {
    NSMutableDictionary *pList;
    pList = [NSMutableDictionary dictionary];
    [pList setObject:self.remoteDirectory forKey:REMOTE_DIR_KEY];
    [pList setObject:self.localDirectory forKey:LOCAL_DIR_KEY];
    return pList;
}



@end

@interface PreferencesOtherController ()

@property (nonatomic) IBOutlet NSPopUpButton *videoApplicationsPopUp;
@property (nonatomic) NSMenuItem *selectedItem;
@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic) NSMutableArray *directoryList;
@property (nonatomic) IBOutlet NSTableView *directoryTableView;
@property (nonatomic) BOOL openFilesWithDoubleClick;
@property (strong) IBOutlet NSArrayController *directoryMappingArrayController;

@end

@implementation PreferencesOtherController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSURL* url = [[NSBundle mainBundle] URLForResource:nil withExtension:@"mp4"];
    CFArrayRef urls = LSCopyApplicationURLsForURL((__bridge CFURLRef)url, kLSRolesViewer);
    NSArray *appUrls = CFBridgingRelease(urls);
   
    for (url in appUrls) {
        NSString *appName = [url.lastPathComponent stringByDeletingPathExtension];
        NSImage *appImage = [[NSWorkspace sharedWorkspace] iconForFile:url.path];
        appImage.name =appName;
        [_videoApplicationsPopUp addItemWithTitle:appName];
        [[_videoApplicationsPopUp itemWithTitle:appName] setImage:appImage];
    }

    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"TransmissionRemote"];
    NSString *selectedApp = [defaults stringForKey:@"videoApplication"];
    
    
    if(selectedApp && [selectedApp isNotEqualTo:@"none"]) {
        [_videoApplicationsPopUp selectItemWithTitle:selectedApp];
        [_videoApplicationsPopUp synchronizeTitleAndSelectedItem];
    }
    else {
        [_videoApplicationsPopUp selectItemAtIndex:0];
        [_videoApplicationsPopUp synchronizeTitleAndSelectedItem];
    }
    
    [_videoApplicationsPopUp synchronizeTitleAndSelectedItem];
    
    NSArray *array = [defaults arrayForKey:@"DirectoryMapping"];
    if(array)
        [self setDirectoryList:[NSMutableArray arrayOfDirectoryMappings:array]];
    else
        [self setDirectoryList:[NSMutableArray array]];
    [self setOpenFilesWithDoubleClick: [defaults boolForKey:@"openFilesWithDoubleClick"]];
}
    
-(void)viewWillAppear {
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor =  [NSColor windowBackgroundColor].CGColor;
}

-(IBAction)savePreferences:(id)sender {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"TransmissionRemote"];

    [defaults setObject:[_directoryList arrayOfPlist] forKey:@"DirectoryMapping"];
    [defaults setBool:_openFilesWithDoubleClick forKey:@"openFilesWithDoubleClick"];
    [defaults synchronize];
    [((PreferencesController*)self.parentViewController) performSelector:@selector(setTorrentSessionInfo:) withObject:self];
}



-(IBAction)selectVideoApp:(id)sender {
    NSMenuItem *menuItem = [((NSPopUpButton*)sender) selectedItem];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"TransmissionRemote"];
    [defaults setObject:[_videoApplicationsPopUp titleOfSelectedItem] forKey:@"videoApplication"];
    [defaults synchronize];
    [_videoApplicationsPopUp selectItem:menuItem];
    [_videoApplicationsPopUp synchronizeTitleAndSelectedItem];
}


-(IBAction)setLocalDirectory:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setTitle: NSLocalizedString(@"Local Directory", "Select Local Directory")];
    [panel setPrompt: NSLocalizedString(@"Select", "Select directory")];
    [panel setAllowsMultipleSelection: NO];
    [panel setCanChooseFiles: NO];
    [panel setCanChooseDirectories: YES];
    [panel setCanCreateDirectories: YES];
    [panel setMessage: @"Select a folder for the Mapping Directory."];
    BOOL success = [panel runModal] == NSModalResponseOK;
    if(success) {
        NSButton *button = sender;
        NSRect entryRect = [button convertRect:button.bounds
                                  toView:_directoryTableView];
        NSInteger row = [_directoryTableView rowAtPoint:entryRect.origin];
    
        [(DirectoryMapping*)_directoryMappingArrayController.arrangedObjects[row] setLocalDirectory:((NSURL*)[panel URLs][0]).path];
    }
}

@end
