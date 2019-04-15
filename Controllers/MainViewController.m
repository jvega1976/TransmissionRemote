//
//  MainViewController.m
//  TransmissionRemote
//
//  Created by  on 2/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "MainViewController.h"
#import "WindowController.h"
#import "StatisticsController.h"
#import "AddTorrentController.h"
#import "CreatorWindowController.h"
#import "AddTorrentController.h"
#import "TorrentActivityController.h"
#import "TorrentSettingsController.h"
#import "TorrentPeersController.h"
#import "TorrentTrackersController.h"
#import "TorrentFilesController.h"
#import "TorrentInfoController.h"
#import "PredicateViewController.h"
#import "PreferencesController.h"
#import <UserNotifications/UserNotifications.h>
#import "AppDelegate.h"
#import "CategorizationKitExtensions.h"
#import "TransmissionRPCExtensions.h"
#import "ServerConfigController.h"
#import "URLConfig.h"
#import "RPCServerConfigDB.h"


#define MyDataType @"MyDataType"

MainViewController *mainViewController;

@implementation TRInfo (TRInfoEditing)

BOOL isEditable = NO;

-(BOOL)isNameEditable {
    if (self.trId == mainViewController.trEditing) {
 //       [self setIsNameEditable:YES] ;
        return YES;
    }
    else {
//        [self setIsNameEditable:NO] ;
        return NO;
    }
}


-(void)setIsNameEditable:(BOOL)isNameEditable {
    
    isEditable = isNameEditable;
}

@end



@interface MainViewController ()

@property (nonatomic) PreferencesController *preferencesController;
@property (nonatomic) PredicateViewController *predicateController;
@property (strong) IBOutlet NSView *filterEditorView;

@property (strong) IBOutlet NSView *dockView;
@property (nonatomic) BOOL isActiveUpl;
@property (nonatomic) BOOL isActiveDown;
@property (strong) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSVisualEffectView *categoryView;
@property (nonatomic) IBOutlet NSTextField *errorMessage;
@property (nonatomic) BOOL errorExists;

@property (strong) IBOutlet NSTextField *uploadRate;
@property (strong) IBOutlet NSTextField *downloadRate;
@property (strong) NSString *drate;
@property (strong) NSString *urate;

@property (weak) IBOutlet NSButton *sideBarButton;

@end

@implementation MainViewController
{
    NSDockTile               *dockTile;
    StatisticsController     *_statisticsController;
    BOOL                    _showCheckItems;              // allows to see "checking" status
    BOOL                    _showErrorItems;              // allows to see "error" status
    TRSessionInfo           *_sessionInfo;
    NSArray                 *_prevDownTorrents;                // holds the previous torrents info
    
    TorrentInfoController *_torrentInfoController;
    TorrentFilesController *_torrentFilesController;
    TorrentActivityController *_torrentActivityController;
    TorrentSettingsController *_torrentSettingsController;
    TorrentPeersController *_torrentPeersController;
    TorrentTrackersController *_torrentTrackersController;

    NSRect _entryRect;
    NSIndexSet *sourceIndex;
  
    NSURL *previousURL;
    
    NSString *_torrentActualName;
    BOOL stopRefresh;
    
    BOOL _displayFreeSpace;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    mainViewController = self;
    [self setErrorExists:NO];
    dockTile = [NSDockTile alloc];
    dockTile = [[NSApplication sharedApplication] dockTile];
    [_dockView awakeFromNib];
    [dockTile setContentView:_dockView];
    [dockTile display];
    // Do view setup here.
 
    _splitView.arrangesAllSubviews = YES;
    _splitView.autoresizesSubviews=YES;
    _userPredicate = [NSPredicate predicateWithFormat:@"name like '*' AND (dateAdded > %@ OR dateAdded < %@)",[NSDate dateWithTimeIntervalSinceReferenceDate:1],[NSDate dateWithTimeIntervalSinceReferenceDate:63082281599]];
    
    _statisticsController = instantiateController(@"StatisticsController");
    _torrentInfoController = instantiateController(@"TorrentInfoController");
    _torrentFilesController = instantiateController(@"TorrentFilesController");
    _torrentActivityController = instantiateController(@"TorrentActivityController");
    _torrentSettingsController = instantiateController(@"TorrentSettingsController");
    _torrentPeersController = instantiateController(@"TorrentPeersController");
    _torrentTrackersController = instantiateController(@"TorrentTrackersController");
    _predicateController = instantiateController(@"PredicateController");
    _trEditing = -1;
    _torrentActualName = [NSString string];
    [_torrentListView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [_torrentListView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    [_torrentListView registerForDraggedTypes:[NSArray arrayWithObjects:@"public.text",@"public.data",NSPasteboardTypeFileURL, nil]];
    [self setSortCriteria: [NSMutableArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"sortValue" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"queuePosition" ascending:YES],nil]];
    _torrentListView.doubleAction = @selector(editClickedTorrentName:);
    
    _search.searchMenuTemplate.itemArray[0].tag = NSSearchFieldRecentsTitleMenuItemTag;
    _search.searchMenuTemplate.itemArray[1].tag = NSSearchFieldRecentsMenuItemTag;
    _search.searchMenuTemplate.itemArray[2].tag = NSSearchFieldClearRecentsMenuItemTag;
    [RPCServerConfigDB.sharedDB loadDB];
    [self startRefreshingWithConfig:[RPCServerConfigDB.sharedDB defaultConfig]];
    [self addChildViewController:_statisticsController];
    [Categorization.shared setGroupLabel:[GroupLabel torrentLabels]];
    [self setTorrents:Categorization.shared];
    [_labelsArrayController setSelectionIndex:0];
}


-(void)viewDidDisappear{
    [super viewDidDisappear];
    [_refreshTimer invalidate];
}

-(void)startInitialWizard{
    ServerConfigController *serverConfigController = instantiateController(@"ServerConfigController");
    serverConfigController.wizardMode = YES;
    serverConfigController.mainViewController = self;
    [self presentViewControllerAsModalWindow:serverConfigController];
}


- (void)startRefreshingWithConfig:(RPCServerConfig*)config {
    if(!config)
        [self startInitialWizard];
    else {
        _config = config;
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:TR_URL_DEFAULTS];
        [RPCConnector.sharedConnector initWithURL:_config.configURL requestTimeout:_config.requestTimeout andDelegate:self];
        _connector = RPCConnector.sharedConnector;
        [self setSessionURL:_config.urlString];
        [self setUserSession:[NSString stringWithFormat:@"%@ at",_urlConfig.user]];
        _connector.delegate =self;
        [_connector getAllTorrents];
        [_connector getSessionInfo];
        [_connector getSessionStats];
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:_config.refreshTimeout target:self selector:@selector(autorefreshTimerUpdateHandler) userInfo:nil repeats:YES];
        
        [defaults setObject:_config.plist forKey:TR_URL_ACTUAL_KEY];
        [defaults synchronize];
    }
}

- (void)startRefreshingWithURL:(NSURL*)url refreshTime:(int)refreshTime andRequestTime:(int)requestTime {
    _urlConfig = url;
    [RPCConnector.sharedConnector initWithURL:_urlConfig requestTimeout:(requestTime ? requestTime : 10) andDelegate:self];
    _connector = RPCConnector.sharedConnector;
    [self setSessionURL:[NSString stringWithFormat:@"%@://%@:%@%@", _urlConfig.scheme,_urlConfig.host,_urlConfig.port,_urlConfig.path]];
    [self setUserSession:[NSString stringWithFormat:@"%@ at",_urlConfig.user]];
    _connector.delegate =self;
    [_connector getSessionInfo];
    [_connector getSessionStats];
    [_connector getAllTorrents];
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:(refreshTime ? refreshTime : 10) target:self selector:@selector(autorefreshTimerUpdateHandler) userInfo:nil repeats:YES];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:TR_URL_DEFAULTS];
    [defaults setURL:_urlConfig forKey:TR_URL_ACTUAL_KEY];
    [defaults synchronize];
}


- (void)stopRefreshing {
    [_refreshTimer invalidate];
    [_connector stopRequests];
}


- (void)showFinishedTorrentsWithInfo
{
    // show torrents in list controller (update)
    // find torrents that are finished downloading
    //TRInfos *prev = _torrentController.torrents;
    if( _prevDownTorrents )
    {
        NSArray *dtors = _prevDownTorrents;
        NSArray *stors = [[_torrents.groupLabel labelWithTitle:TR_GL_TITLE_SEED] items];
        
        for (TRInfo* dt in dtors)
        {
            for( TRInfo* st in stors )
            {
                if( st.trId == dt.trId )
                {
                    // we have found finished torrent need to
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    
                    content.title = [NSString localizedUserNotificationStringForKey:@"Torrent Finished" arguments:nil];
                    
                    content.body = [NSString localizedUserNotificationStringForKey:@"\"%@\" finished downloading" arguments: @[st.name]];
                    
                    content.sound = [UNNotificationSound defaultSound];
                    
                    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                                  triggerWithTimeInterval:1 repeats:NO];
                    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"Now" content:content trigger:trigger];
                    
                    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
                            if(error)
                                NSLog(@"Notification for torrent: %@ failed with Error: %@",st.name,error.localizedDescription);
                        }];
                    });
                    if(!NSApplication.sharedApplication.active) {
                        NSDockTile *dockTile =[[NSApplication sharedApplication] dockTile];
                        [dockTile setBadgeLabel: [NSString stringWithFormat:@"%ld", [dockTile.badgeLabel integerValue] + 1]];
                        [dockTile display];
                    }
                }
            }
        }
        
         }
    _prevDownTorrents = [[_torrents.groupLabel labelWithTitle:TR_GL_TITLE_DOWN] items];;
}


-(void)autorefreshTimerUpdateHandler{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0),^{
        self.connector.delegate = self;
        [self.connector getAllTorrents];
        [self.connector getSessionInfo];
        [self.connector getSessionStats];
        if(self->_displayFreeSpace)
            [self.connector getFreeSpaceWithDownloadDir:self.trSessionInfo.downloadDir];
    });
}


#pragma mark - Interface Actions

-(IBAction)toggleCategorySideBar:(id)sender {
    
    
    if(_categoryView.isHidden) {
        [_categoryView setFrameSize:CGSizeMake(270, 783)];
        _categoryView.hidden = NO;
        NSMenuItem *menuItem = [[[[NSApplication sharedApplication] menu] itemWithTitle:@"View"].submenu itemWithTitle:@"Show Sidebar"];
        _sideBarButton.toolTip = @"Hide Sidebar";
        menuItem.title = @"Hide Sidebar";
    }
    else {
        _categoryView.hidden = YES;
        NSMenuItem *menuItem = [[[[NSApplication sharedApplication] menu] itemWithTitle:@"View"].submenu itemWithTitle:@"Hide Sidebar"];
        _sideBarButton.toolTip = @"Show Sidebar";
        menuItem.title = @"Show Sidebar";
    }
}


-(IBAction)toggleSessionAltLimitMode:(id)sender {
//    NSButton *button = (NSButton*)sender;
     _connector.delegate = self;
//    if (button.state == NSControlStateValueOn)
    if (!_trSessionInfo.altLimitEnabled)
        [_connector toggleAltLimitMode:YES];
    else
        [_connector toggleAltLimitMode:NO];
}


- (IBAction)createFile: (id) sender
{
    [CreatorWindowController createTorrentFile];
}


-(IBAction)addTorrentFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.allowsMultipleSelection = YES;
    panel.canChooseDirectories = NO;
    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            for (NSURL *i in [panel URLs]){
                AddTorrentController  *addTorrentController = instantiateController(@"AddTorrentController");
                TorrentFile *file = [TorrentFile torrentFileWithURL:i];
                addTorrentController.torrentFile = file;
                [self presentViewControllerAsSheet:addTorrentController];
            }
        }
    }];
}


-(IBAction)addTorrentMagnet:(id)sender {
    MagnetURL *magnetURL;
    NSArray *classes = [NSArray arrayWithObject:[NSString class]];
    NSDictionary *options =  [NSDictionary dictionary];
    NSPasteboard *paste = [NSPasteboard generalPasteboard];
    NSArray *objects = [paste readObjectsForClasses:classes options:options];
    if ([objects count] > 0) {
        NSURL *url = [NSURL URLWithString:[objects objectAtIndex:0]];
        if( [MagnetURL isMagnetURL:url] )
            magnetURL = [MagnetURL magnetWithURL:url];
        self->_connector.delegate = self;
        [self->_connector addTorrentWithMagnet:magnetURL.urlString priority:1 startImmidiately:YES];
    }
    
}


-(IBAction)displayStatistics:(id)sender {
    
    NSRect rect = [_splitView convertRect:_splitView.bounds toView:_splitView];
   
    [_statisticsController setTrSessionStats:_trSessionStats];
    
    [self presentViewController:_statisticsController asPopoverRelativeToRect:rect ofView:_splitView preferredEdge:nil behavior:NSPopoverBehaviorTransient];
}


- (IBAction)displayPreferencesWindow:(id)sender {
    _preferencesController = instantiateController(@"PreferencesController");
//    [self addChildViewController:_preferencesController];
    _preferencesController.mainViewController = self;
    [self presentViewControllerAsModalWindow:_preferencesController];
}


-(IBAction)startAllTorrents:(id)sender {
    _connector.delegate = self;
    [_connector resumeAllTorrents];
}


-(IBAction)stopAllTorrents:(id)sender {
    _connector.delegate = self;
    [_connector stopAllTorrents];
}


- (IBAction)startSelectedTorrents:(id)sender {
    NSIndexSet *rows = [_torrentListView selectedRowIndexes];
    NSMutableArray __block *trIdList = [NSMutableArray array];
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TRInfo *torrent = [self->_torrentArrayController.arrangedObjects objectAtIndex:idx];
        [trIdList addObject:[NSNumber numberWithInt:torrent.trId]];
    }];
    [_connector resumeTorrent:trIdList];
}


- (IBAction)startNowSelectedTorrents:(id)sender {
    NSIndexSet *rows = [_torrentListView selectedRowIndexes];
    NSMutableArray __block *trIdList = [NSMutableArray array];
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TRInfo *torrent = [self->_torrentArrayController.arrangedObjects objectAtIndex:idx];
        [trIdList addObject:[NSNumber numberWithInt:torrent.trId]];
    }];
    [_connector resumeNowTorrent:trIdList];
}


- (IBAction)stopSelectedTorrents:(id)sender {
    NSIndexSet *rows = [_torrentListView selectedRowIndexes];
    NSMutableArray __block *trIdList = [NSMutableArray array];
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TRInfo *torrent = [self->_torrentArrayController.arrangedObjects objectAtIndex:idx];
        [trIdList addObject:[NSNumber numberWithInt:torrent.trId]];
    }];
    [_connector stopTorrents:trIdList];
}


- (IBAction)reannounceSelectedTorrents:(id)sender{
    NSIndexSet *rows = [_torrentListView selectedRowIndexes];
    NSMutableArray __block *trIdList = [NSMutableArray array];
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TRInfo *torrent = [self->_torrentArrayController.arrangedObjects objectAtIndex:idx];
        [trIdList addObject:[NSNumber numberWithInt:torrent.trId]];
    }];
    [_connector reannounceTorrent:trIdList];
}


- (IBAction)verifySelectedTorrents:(id)sender{
    NSIndexSet *rows = [_torrentListView selectedRowIndexes];
    NSMutableArray __block *trIdList = [NSMutableArray array];
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TRInfo *torrent = [self->_torrentArrayController.arrangedObjects objectAtIndex:idx];
        [trIdList addObject:[NSNumber numberWithInt:torrent.trId]];
    }];
    [_connector verifyTorrent:trIdList];
}


- (IBAction)deleteSelectedTorrents:(id)sender{
    NSIndexSet *rows = [_torrentListView selectedRowIndexes];
    NSMutableArray __block *trIdList = [NSMutableArray array];
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TRInfo *torrent = [self->_torrentArrayController.arrangedObjects objectAtIndex:idx];
        [trIdList addObject:[NSNumber numberWithInt:torrent.trId]];
    }];
    [_connector deleteTorrentWithId:trIdList deleteWithData:NO];
}


- (IBAction)deleteSelectedTorrentsWithData:(id)sender{
    NSIndexSet *rows = [_torrentListView selectedRowIndexes];
    NSMutableArray __block *trIdList = [NSMutableArray array];
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TRInfo *torrent = [self->_torrentArrayController.arrangedObjects objectAtIndex:idx];
        [trIdList addObject:[NSNumber numberWithInt:torrent.trId]];
    }];
    [_connector deleteTorrentWithId:trIdList deleteWithData:YES];
}

-(IBAction)editClickedTorrentName:(id)sender {
    [self stopRefreshing];
    NSUInteger row;
    NSObject *object = (NSObject *)sender;
    
   if ([object.className isEqualToString:@"NSMenuItem"])
        row = [_torrentListView selectedRow];
    else
        row = [_torrentListView clickedRow];
   
    self.trEditing = ((TRInfo*)_torrentArrayController.arrangedObjects[row]).trId;
    [(TRInfo*)_torrentArrayController.arrangedObjects[row] setIsNameEditable:YES];
    [_torrentListView.window makeFirstResponder:[_torrentListView rowViewAtRow:row makeIfNecessary:NO].subviews.firstObject.subviews.firstObject];
}


-(void)controlTextDidBeginEditing:(NSNotification *)notification {
    NSTextField *textField = notification.object;
    _torrentActualName = textField.stringValue;
}


- (IBAction)renameTorrent:(id)sender {
    NSTextField *name = (NSTextField*)sender;
    _entryRect = [name convertRect:name.bounds
                            toView:_torrentListView];
    NSInteger row = [_torrentListView rowAtPoint:_entryRect.origin];
    TRInfo *trInfo = [_torrentArrayController.arrangedObjects objectAtIndex:row];
    _connector.delegate = self;
    if([name.stringValue isNotEqualTo:_torrentActualName])
        [_connector renameTorrent:trInfo.trId withName:name.stringValue andPath:_torrentActualName];
    self.trEditing = -1;
    _torrentActualName = @"";
    [(TRInfo*)_torrentArrayController.arrangedObjects[row] setIsNameEditable:NO];
    [self startRefreshingWithConfig:_config];
}


- (IBAction)queueUp:(id)sender{
    NSIndexSet *rows = [_torrentListView selectedRowIndexes];
    NSMutableArray __block *trIdList = [NSMutableArray array];
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TRInfo *torrent = [self->_torrentArrayController.arrangedObjects objectAtIndex:idx];
        [trIdList addObject:@(torrent.trId)];
        if( (torrent.queuePosition-1) <= [(TRInfo*)[self->_torrentArrayController.arrangedObjects objectAtIndex:(idx-1)] queuePosition]){
            [self->_torrentArrayController removeObjectAtArrangedObjectIndex:idx];
            [self->_torrentArrayController insertObject:torrent atArrangedObjectIndex:idx-1];
            //           [self->_torrentListView beginUpdates];
            //           [self->_torrentListView moveRowAtIndex:idx toIndex:(idx-1)];
            //           [self->_torrentListView endUpdates];
        }
    }];
    [_connector moveTorrentUp:trIdList];
}


-(IBAction)queueDown:(id)sender{
    NSIndexSet *rows = [_torrentListView selectedRowIndexes];
    NSMutableArray __block *trIdList = [NSMutableArray array];
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TRInfo *torrent = [self->_torrentArrayController.arrangedObjects objectAtIndex:idx];
        [trIdList addObject:[NSNumber numberWithInt:torrent.trId]];
        if( (torrent.queuePosition+1) >= [(TRInfo*)[self->_torrentArrayController.arrangedObjects objectAtIndex:(idx+1)] queuePosition]){
            [self->_torrentListView beginUpdates];
            [self->_torrentListView moveRowAtIndex:idx toIndex:(idx+1)];
            [self->_torrentListView endUpdates];
        }
    }];
    [_connector moveTorrentDown:trIdList];
}


-(IBAction)queueTop:(id)sender{
    NSIndexSet *rows = [_torrentListView selectedRowIndexes];
    NSMutableArray __block *trIdList = [NSMutableArray array];
    NSInteger __block i = (NSInteger) -1;
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TRInfo *torrent = [self->_torrentArrayController.arrangedObjects objectAtIndex:idx];
        [trIdList addObject:[NSNumber numberWithInt:torrent.trId]];
        
        [self->_torrentListView beginUpdates];
        [self->_torrentListView moveRowAtIndex:idx toIndex:(i+1)];
        [self->_torrentListView endUpdates];
        i++;
    }];
    [_connector moveTorrentTop:trIdList];
}


-(IBAction)queueBottom:(id)sender{
    NSIndexSet *rows = [_torrentListView selectedRowIndexes];
    NSMutableArray __block *trIdList = [NSMutableArray array];
    NSInteger __block i = [_torrentArrayController.arrangedObjects count];
    
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        TRInfo *torrent = [self->_torrentArrayController.arrangedObjects objectAtIndex:idx];
        [trIdList addObject:[NSNumber numberWithInt:torrent.trId]];
        
        [self->_torrentListView beginUpdates];
        [self->_torrentListView moveRowAtIndex:idx toIndex:(i-1)];
        [self->_torrentListView endUpdates];
        i--;
    }];
    [_connector moveTorrentBottom:trIdList];
}

-(IBAction)displayTorrentDetailedInfo:(id)sender{
    
    if (_torrentInfoController.viewAppeared) {
        [_torrentInfoController dismissViewController:_torrentInfoController];
    }
    
    NSButton *button = sender;
    _entryRect = [button convertRect:button.bounds
                              toView:_torrentListView];
    NSInteger row = [_torrentListView rowAtPoint:_entryRect.origin];
    _torrentInfoController.trId = [_torrentArrayController.arrangedObjects[row] trId];
    _connector.delegate = self;
    [_connector getDetailedInfoForTorrentWithId:_torrentInfoController.trId];
}


-(IBAction)displayTorrentPeers:(id)sender{
    NSButton *button = sender;
    _entryRect = [button convertRect:button.bounds
                              toView:_torrentListView];
    NSInteger row = [_torrentListView rowAtPoint:_entryRect.origin];
    _torrentPeersController.connector = _connector;
    _torrentPeersController.trId = [_torrentArrayController.arrangedObjects[row] trId];
    _connector.delegate = self;
    [_connector getAllPeersForTorrentWithId:[_torrentArrayController.arrangedObjects[row] trId]];
}


-(IBAction)displayTorrentTrackers:(id)sender{
    NSButton *button = sender;
    _entryRect = [button convertRect:button.bounds
                              toView:_torrentListView];
    NSInteger row = [_torrentListView rowAtPoint:_entryRect.origin];
    _torrentTrackersController.connector = _connector;
    _torrentTrackersController.trId = [_torrentArrayController.arrangedObjects[row] trId];
    _connector.delegate = self;
    [_connector getAllTrackersForTorrentWithId:_torrentTrackersController.trId];
}



- (IBAction)displayTorrentFiles:(id)sender {
    _torrentFilesController.connector = _connector;
    NSButton *button = sender;
    _entryRect = [button convertRect:button.bounds
                              toView:_torrentListView];
    NSInteger row = [_torrentListView rowAtPoint:_entryRect.origin];
    TRInfo *trInfo = _torrentArrayController.arrangedObjects[row];
    [_torrentFilesController setTorrentId:trInfo.trId];
    _connector.delegate = self;
    [_connector getAllFilesForTorrentWithId:trInfo.trId];
}


- (IBAction)displayTorrentActivity:(id)sender {
    //    _torrentActivityController.connector = _connector;
    _connector.delegate = self;
    NSButton *button = sender;
    _entryRect = [button convertRect:button.bounds
                              toView:_torrentListView];
    NSInteger row = [_torrentListView rowAtPoint:_entryRect.origin];
    TRInfo *trInfo = _torrentArrayController.arrangedObjects[row];
    _torrentActivityController.pieceSize = trInfo.pieceSize;
    _torrentActivityController.piecesCount = trInfo.piecesCount;
    _torrentActivityController.torrentId = trInfo.trId;
    [_connector getPiecesBitMapForTorrent:trInfo.trId];
}

- (IBAction)setTorrentSettings:(id)sender{
    NSButton *button = sender;
    _entryRect = [button convertRect:button.bounds
                              toView:_torrentListView];
    NSInteger row = [_torrentListView rowAtPoint:_entryRect.origin];
    _torrentSettingsController.trInfo =  _torrentArrayController.arrangedObjects[row];
    _torrentSettingsController.trId = [_torrentArrayController.arrangedObjects[row] trId];
    [self presentViewController:_torrentSettingsController asPopoverRelativeToRect:_entryRect ofView:_torrentListView preferredEdge:nil behavior:NSPopoverBehaviorTransient];
}


-(IBAction)sortTorrentList:(id)sender {
    
    stopRefresh =YES;
    NSMenuItem *menuItem = (NSMenuItem*)sender;
    NSSortDescriptor *descriptor;
    NSString *ascendingString = [NSString string];
    if(!_sortCriteria) {
        _sortCriteria = [NSMutableArray array];
        descriptor = [[NSSortDescriptor alloc] init];
    }
    else
        descriptor = [_sortCriteria firstObject];
    
    switch (menuItem.tag) {
        case SortName:
            if([descriptor.key isEqual:@"name"]) {
                descriptor = [descriptor reversedSortDescriptor];
                ascendingString = @"↓";
            }
            else {
                descriptor = [descriptor initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                ascendingString = @"↑";
            }
            break;
        case SortPosition:
            if([descriptor.key isEqual:@"queuePosition"]) {
                descriptor = [descriptor reversedSortDescriptor];
                ascendingString = @"↓";
            }
            else {
                descriptor = [descriptor initWithKey:@"queuePosition" ascending:YES selector:@selector(compare:)];
                ascendingString = @"↑";
            }
            break;
        case SortSize:
            if([descriptor.key isEqual:@"totalSize"]) {
                descriptor = [descriptor reversedSortDescriptor];
                ascendingString = @"↓";
            }
            else {
                descriptor = [descriptor initWithKey:@"totalSize" ascending:YES selector:@selector(compare:)];
                ascendingString = @"↑";
            }
            break;
        case SortETA:
            if([descriptor.key isEqual:@"etaTimeString"]) {
                descriptor = [descriptor reversedSortDescriptor];
                ascendingString = @"↓";
            }
            else {
                //descriptor = [descriptor initWithKey:@"etaTimeString" ascending:YES selector:@selector(compare:)];
                descriptor = [descriptor initWithKey:@"etaTimeString" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
                    NSString *string1 = obj1;
                    NSString *string2 = obj2;
                    if([string1 isEqualToString:@""]) {
                        if ([string2 isEqualToString:@""])
                            return NSOrderedSame;
                        else
                            return NSOrderedDescending;
                    }
                    else {
                        if ([string2 isEqualToString:@""])
                            return NSOrderedAscending;
                        else if (string1.doubleValue < string2.doubleValue)
                            return NSOrderedDescending;
                        else if (string1.doubleValue > string2.doubleValue)
                            return NSOrderedAscending;
                        else
                            return NSOrderedSame;
                    }
                    return NSOrderedSame;
                }];
                ascendingString = @"↑";
            }
            break;
        case SortDone:
            if([descriptor.key isEqual:@"percentsDone"]) {
                descriptor = [descriptor reversedSortDescriptor];
                ascendingString = @"↓";
            }
            else {
                descriptor = [descriptor initWithKey:@"percentsDone" ascending:YES selector:@selector(compare:)];
                ascendingString = @"↑";
            }
            break;
        case SortPeers:
            if([descriptor.key isEqual:@"peersConnected"]) {
                descriptor = [descriptor reversedSortDescriptor];
                ascendingString = @"↓";
            }
            else {
                descriptor = [descriptor initWithKey:@"peersConnected" ascending:YES selector:@selector(compare:)];
                ascendingString = @"↑";
            }
            break;
        case SortSeeds:
            if([descriptor.key isEqual:@"peersSendingToUs"]) {
                descriptor = [descriptor reversedSortDescriptor];
                ascendingString = @"↓";
            }
            else {
                descriptor = [descriptor initWithKey:@"peersSendingToUs" ascending:YES selector:@selector(compare:)];
                ascendingString = @"↑";
            }
            break;
        case SortDownRate:
            if([descriptor.key isEqual:@"downloadRate"]) {
                descriptor = [descriptor reversedSortDescriptor];
                ascendingString = @"↓";
            }
            else {
                descriptor = [descriptor initWithKey:@"downloadRate" ascending:YES selector:@selector(compare:)];
                ascendingString = @"↑";
            }
            break;
        case SortUpRate:
            if([descriptor.key isEqual:@"uploadRate"]) {
                descriptor = [descriptor reversedSortDescriptor];
                ascendingString = @"↓";
            }
            else {
                descriptor = [descriptor initWithKey:@"uploadRate" ascending:YES selector:@selector(compare:)];
                ascendingString = @"↑";
            }
            break;
        case SortDateAdded:
            if([descriptor.key isEqual:@"dateAdded"]) {
                descriptor = [descriptor reversedSortDescriptor];
                ascendingString = @"↓";
            }
            else {
                descriptor = [descriptor initWithKey:@"dateAdded" ascending:YES selector:@selector(compare:)];
                ascendingString = @"↑";
            }
            break;
        case SortDateDone:
            if([descriptor.key isEqual:@"dateDone"]) {
                descriptor = [descriptor reversedSortDescriptor];
                ascendingString = @"↓";
            }
            else {
                descriptor = [descriptor initWithKey:@"dateDone" ascending:YES selector:@selector(compare:)];
                ascendingString = @"↑";
            }
            break;
        default:
            break;
    }
    
    if(descriptor)
        [self setSortCriteria: [NSMutableArray arrayWithObject:descriptor]];
    else
        [self setSortCriteria: [NSMutableArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"sortValue" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"queuePosition" ascending:YES],nil]];
    NSMenu *menu = menuItem.menu;
    NSArray *menuItems = menu.itemArray;
    [menuItems makeObjectsPerformSelector:@selector(setState:) withObject:(__bridge id)(void*)NSControlStateValueOff];
    [menuItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx)
            [(NSMenuItem*)obj setTitle:[(NSMenuItem*)obj identifier]];
    }];
    menuItem.state = NSControlStateValueOn;
    menuItem.title = [NSString stringWithFormat:@"%@%@",menuItem.identifier,ascendingString];
    stopRefresh = NO;
}


- (IBAction)searchPredicate:(id)sender {
   
    if ([((NSMenuItem*)sender).title isEqualToString:@"Advanced..."]) {
        _predicateController.mainViewController = self;
        [self presentViewControllerAsSheet:_predicateController];
    }
    else
        _search.placeholderString = ((NSMenuItem*)sender).identifier;
    
}


- (IBAction)controlTextDidEndEditing:(id)sender {
    
    if (sender == _search) {
        if(_search.stringValue.length > 0 )
            _userPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@",_search.stringValue];
            
        else
            _userPredicate = [NSPredicate predicateWithFormat:@"name like '*' OR (dateAdded >= %@ AND dateAdded < %@)",[NSDate dateWithTimeIntervalSinceReferenceDate:1],[NSDate dateWithTimeIntervalSinceReferenceDate:63082281599]];
        
//        [TRInfos.sharedTRInfos setUserFilter:_userPredicate];
        [self.torrents setSearchPredicate:_userPredicate];
//        [self setPredicate:[TRInfos.sharedTRInfos predicateForKey:statusKey]];
        [_connector getAllTorrents];
    }
}


#pragma mark - RPCConnectorDelegate

- (void)gotAllTorrents:(TRInfos *)torrents {
    if(!stopRefresh) {
        [self setErrorExists:NO];
        [_uploadRate setStringValue:torrents.totalUploadRateString];
        [_downloadRate setStringValue: torrents.totalDownloadRateString];
        NSIndexSet *indexes = [[_torrentArrayController selectionIndexes] copy];
        [_torrents setItems:torrents.items];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [[self.torrentArrayController.arrangedObjects objectAtIndex:idx] setIsSelected:YES];
        }];
        [_torrentArrayController setSelectionIndexes:indexes];
        [self showFinishedTorrentsWithInfo];
    }
}


-(void)gotTorrentAdded {
    _connector.delegate = self;
    [_connector getAllTorrents];
}


- (void)gotAllTorrentsStopped
{
    _connector.delegate = self;
    [_connector getAllTorrents];
}


- (void)gotAlltorrentsResumed
{   _connector.delegate = self;
    [_connector getAllTorrents];
}


- (void)gotTorrentsVerified
{   _connector.delegate = self;
    [_connector getAllTorrents];
}


- (void)gotTorrentsReannounced
{   _connector.delegate = self;
    [_connector getAllTorrents];
}

- (void)gotTorrentsDeleted
{   _connector.delegate = self;
    [_connector getAllTorrents];
}

-(void)gotTorrentRenamed:(int)torrentId withName:(NSString *)name andPath:(NSString *)path {
    _connector.delegate = self;
    [_connector getAllTorrents];
}

- (void)gotTorrentsMoved
{   _connector.delegate = self;
    [_connector getAllTorrents];
}



-(void)gotToggledAltLimitMode:(BOOL)altLimitEnabled {
    _connector.delegate = self;
    [_connector getSessionInfo];
}


-(void)gotSessionWithInfo:(TRSessionInfo *)info {
    [self setErrorExists:NO];
    [self setTrSessionInfo:info];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label == 'Alt Speed'"];
    NSToolbarItem *toolbarItem = [[self.view.window.toolbar.items filteredArrayUsingPredicate:predicate] firstObject];
    if (info.altLimitEnabled) {
        //Update Toogle Alt Toolbar Item state
        [toolbarItem.view performSelector:@selector(setState:) withObject:(__bridge id)(void*)NSControlStateValueOn];
        //Update Toogle Alt Dock Menu Item state
        [[(AppDelegate*)[[NSApplication sharedApplication] delegate] toggleAltMenuItem] setState:NSControlStateValueOn];
    }
    else {
        //Update Toogle Alt Toolbar Item state
        [toolbarItem.view performSelector:@selector(setState:) withObject:(__bridge id)(void*)NSControlStateValueOff];
        //Update Toogle Alt Dock Menu Item state
        [[(AppDelegate*)[[NSApplication sharedApplication] delegate] toggleAltMenuItem] setState:NSControlStateValueOff];
    }
    if(_displayFreeSpace)
        [_connector getFreeSpaceWithDownloadDir:info.downloadDir];
}


-(void)gotSessionWithStats:(TRSessionStats *)stats {
    [self setErrorExists:NO];
    [self setTrSessionStats:stats];
    [self setUploadedBytes:[NSString stringWithFormat:@"↑UL: %@",formatByteCount(stats.currentUploadedBytes)]];
    [self setDownloadedBytes:[NSString stringWithFormat:@"↓DL: %@",formatByteCount(stats.currentdownloadedBytes)]];
    [self setSecondsActive:[NSString stringWithFormat:@"Duration: %@",formatHoursMinutes(stats.currentSecondsActive)]];
    if(!_displayFreeSpace) {
        [self setFilesAdded:[NSString stringWithFormat:@"Files Added: %ld",stats.currentFilesAdded]];
    }
    [self setTorrentsCount:[NSString stringWithFormat:@"Session: %ld",stats.torrentCount]];
    [self setActiveTorrentsCount:[NSString stringWithFormat:@"Active: %d",stats.activeTorrentCount]];
    [self setPausedTorrentsCount:[NSString stringWithFormat:@"Paused: %d",stats.pausedTorrentCount]];
    [self setIsActiveUpl:(stats.uploadSpeed > 0)];
    [self setIsActiveDown:(stats.downloadSpeed > 0)];
    [self setUploadSpeed:[NSString stringWithFormat:@"↑%@",formatByteRate(stats.uploadSpeed)]];
    [self setDownloadSpeed:[NSString stringWithFormat:@"↓%@",formatByteRate(stats.downloadSpeed)]];
    [dockTile display];
}


-(void)gotTorrentAddedWithResult:(NSDictionary*)jsonResponse {
    if ([[jsonResponse descriptionInStringsFileFormat] containsString:@"torrent-duplicate"]) {
        NSDictionary *userError = @{NSLocalizedDescriptionKey: @"Torrent Duplicated",
                                    NSHelpAnchorErrorKey: @"Torrent already exists."};
        NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:20400 userInfo:userError];
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    };
    [self dismissController:self];
}


-(void)gotTorrentDetailedInfo:(TRInfo*)torrentInfo {
    [_torrentInfoController setTrInfo:torrentInfo];
    [self presentViewController:_torrentInfoController asPopoverRelativeToRect:_entryRect ofView:_torrentListView preferredEdge:nil behavior:NSPopoverBehaviorTransient];
}


-(void)gotAllFiles:(FSDirectory *)directory forTorrentWithId:(int)torrentId {
    _torrentFilesController.torrentFiles = directory;
    if (!_torrentFilesController.viewAppeared) {
        //         _torrentDetailsController.viewTab = Files;
        [self presentViewController:_torrentFilesController asPopoverRelativeToRect:_entryRect ofView:_torrentListView preferredEdge:nil behavior:NSPopoverBehaviorTransient];
        //        [self presentViewControllerAsSheet:_torrentFilesController];
    }
}


-(void)gotPiecesBitmap:(NSData *)piecesBitmap forTorrentWithId:(int)torrentId {
    [_torrentActivityController setPiecesBitmap:piecesBitmap];
    if (!_torrentActivityController.viewAppeared) {
        //         _torrentDetailsController.viewTab = Files;
        [self presentViewController:_torrentActivityController asPopoverRelativeToRect:_entryRect ofView:_torrentListView preferredEdge:nil behavior:NSPopoverBehaviorTransient];
        //        [self presentViewControllerAsSheet:_torrentFilesController];
    }
}


-(void)gotAllTrackers:(NSArray *)trackerStats forTorrentWithId:(int)torrentId {
    [_torrentTrackersController setTrTrackers:trackerStats];
    [_torrentTrackersController setTrId:torrentId];
    if (!_torrentTrackersController.viewAppeared)
        [self presentViewController:_torrentTrackersController asPopoverRelativeToRect:_entryRect ofView:_torrentListView preferredEdge:nil behavior:NSPopoverBehaviorTransient];
}


-(void)gotAllPeers:(NSArray *)peerInfos withPeerStat:(TRPeerStat *)stat forTorrentWithId:(int)torrentId {
    [_torrentPeersController setTrPeerInfos:peerInfos];
    [_torrentPeersController setTrPeerStat:stat];
    if (!_torrentPeersController.viewAppeared)
        [self presentViewController:_torrentPeersController asPopoverRelativeToRect:_entryRect ofView:_torrentListView preferredEdge:nil behavior:NSPopoverBehaviorTransient];
}

-(void)gotFreeSpaceString:(NSString *)freeSpace
{
    [self setFilesAdded:[NSString stringWithFormat:@"Free Space: %@",freeSpace]];
}


-(void)connector:(RPCConnector *)cn complitedRequestName:(NSString *)requestName fromURL:(NSURL*)url withError:(NSString *)errorMessage {
    [self.errorMessage setStringValue:[NSString stringWithFormat:@"%@: %@",url.host,errorMessage]];
    [self setErrorExists:YES];
    [_torrents setItems:[NSArray array]];
    NSLog(@"Transmission Remote: %@: %@ - %@",url,requestName,errorMessage);
}


#pragma mark - TableViewDataSource


- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSError * _Nullable error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes requiringSecureCoding: NO error:&error];
    [pboard declareTypes:[NSArray arrayWithObject:MyDataType] owner:self];
    [pboard setData:data forType:MyDataType];
    sourceIndex = rowIndexes;
    return YES;
}


- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if(tableView == _torrentListView) {
        //Get Torrent Id
        if (info.draggingSource) {
            //        NSPasteboard *p = [info draggingPasteboard];
            //        NSArray *pItems = [p pasteboardItems];
            
            NSMutableIndexSet *indexToRemove = [NSMutableIndexSet indexSet];
            NSMutableIndexSet *indexToAdd = [NSMutableIndexSet indexSet];
            NSMutableArray *trIdList = [NSMutableArray array];
            NSMutableArray *positions = [NSMutableArray array];
            NSMutableArray *trToAdd = [NSMutableArray array];
            
            TRInfo *trInfoDest = _torrentArrayController.arrangedObjects[row];
            int pos = trInfoDest.queuePosition;
            
            NSArray *sourceTRInfos = [_torrentArrayController.arrangedObjects objectsAtIndexes:sourceIndex];
            
            int i = 0;
            
            for (TRInfo *trInfoSrc in sourceTRInfos) {
                
                //int trID = [(NSString*)[[pItems objectAtIndex:i] stringForType:@"public.text"] intValue];
                int trID = [trInfoSrc trId];
                NSInteger srcIndex = [_torrentArrayController.arrangedObjects indexOfObject:trInfoSrc];
                
                //Get Torrent queue position from current torrent in target row
                
                NSNumber *posDest = [NSNumber numberWithInt:pos+i];
                
                if(trInfoSrc) {
                    
                    if (srcIndex < row+i)
                        [indexToRemove addIndex:srcIndex];
                    else
                        [indexToRemove addIndex:srcIndex+1];
                    
                    [(TRInfo*)[_torrentArrayController.arrangedObjects objectAtIndex:srcIndex] setQueuePosition: [posDest intValue]];
                    [trToAdd addObject:trInfoSrc];
                    [indexToAdd addIndex:row+i];
                    [trIdList addObject:@(trID)];
                    [positions addObject:posDest];
                }
                i++;
            }
            
            [_torrentArrayController insertObjects:trToAdd atArrangedObjectIndexes:indexToAdd];
            [_torrentArrayController removeObjectsAtArrangedObjectIndexes:indexToRemove];
            [_connector moveTorrentQueue:trIdList toPosition:positions];
            [_torrentListView reloadData];
            return NSDragOperationEvery;
        }
        else {
            NSPasteboard *p = [info draggingPasteboard];
            if ([[p types] containsObject:NSPasteboardTypeFileURL]) {
                
                NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
                NSDictionary *options =  [NSDictionary dictionary];
                NSArray *objects = [p readObjectsForClasses:classes options:options];
                for (int i=0; i < [objects count]; i++) {
                    if([[objects objectAtIndex:i] isNotEqualTo:previousURL]){
                        AddTorrentController *addTorrentController = instantiateController(@"AddTorrentController");
                        NSURL *url = [NSURL fileURLWithPath:[[objects objectAtIndex:i] path]];
                        TorrentFile *file = [TorrentFile torrentFileWithURL:url];
                        addTorrentController.torrentFile = file;
                        previousURL = [objects objectAtIndex:i];
                        [self presentViewControllerAsSheet:addTorrentController];
                    }
                }
            }
            return NSDragOperationPrivate;
        }
    }
    return NSDragOperationNone;
}



- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {

    return YES;
}


#pragma mark - TableViewDelegate


- (void)tableViewSelectionIsChanging:(NSNotification *)notification {
     if (notification.object == _torrentListView) {
         NSIndexSet *indexNew = [_torrentListView selectedRowIndexes];
         NSIndexSet *indexOld = [_torrentArrayController selectionIndexes];
         [indexNew enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
             if(![indexOld containsIndex:idx])
                 [(TRInfo*)[self.torrentArrayController.arrangedObjects objectAtIndex:idx] setIsSelected:YES];
         }];
         [indexOld enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
             if(![indexNew containsIndex:idx])
                 [(TRInfo*)[self.torrentArrayController.arrangedObjects objectAtIndex:idx] setIsSelected:NO];
         }];
    }
     else if(notification.object == _statusCategoriesView) {
         NSIndexSet *indexOld = [_torrentArrayController selectionIndexes];
         [indexOld enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
             [(TRInfo*)[self.torrentArrayController.arrangedObjects objectAtIndex:idx] setIsSelected:NO];
         }];
         [_torrentArrayController setSelectionIndexes:[NSIndexSet indexSet]];
     }
        
}



- (NSArray<NSTableViewRowAction *> *)tableView:(NSTableView *)tableView rowActionsForRow:(NSInteger)row edge:(NSTableRowActionEdge)edge {
    if(tableView == _torrentListView) {
        
        if (edge == NSTableRowActionEdgeTrailing) {
            NSTableViewRowAction *delete = [NSTableViewRowAction rowActionWithStyle:NSTableViewRowActionStyleDestructive title:@"Remove" handler:^(NSTableViewRowAction * action, NSInteger row) {
                TRInfo *trInfo = [[self->_torrentArrayController arrangedObjects] objectAtIndex:row];
                //           [self->_torrentListView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationSlideLeft];
                [self->_torrentArrayController removeObjectAtArrangedObjectIndex:row];
                [self->_connector deleteTorrentWithId:[NSArray arrayWithObject:[NSNumber numberWithInt:trInfo.trId]] deleteWithData:NO];
            }];
            delete.image = [NSImage imageNamed:@"RemoveTemplate"];
            NSTableViewRowAction *deleteWithData = [NSTableViewRowAction rowActionWithStyle:NSTableViewRowActionStyleDestructive title:@"Remove\rwith Data" handler:^(NSTableViewRowAction * action, NSInteger row) {
                TRInfo *trInfo = [[self->_torrentArrayController arrangedObjects] objectAtIndex:row];
                //            [self->_torrentListView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationSlideLeft];
                [self->_torrentArrayController removeObjectAtArrangedObjectIndex:row];
                [self->_connector deleteTorrentWithId:[NSArray arrayWithObject:[NSNumber numberWithInt:trInfo.trId]] deleteWithData:YES];
                
            }];
            deleteWithData.image = [NSImage imageNamed:@"CleanupTemplate"];
            deleteWithData.backgroundColor = [NSColor colorWithSRGBRed:0.822 green:0.116 blue:0.008 alpha:1];
            return [NSArray arrayWithObjects:delete,deleteWithData,nil];
            
        }
        else if (edge == NSTableRowActionEdgeLeading) {
            TRInfo *trInfo = [[self->_torrentArrayController arrangedObjects] objectAtIndex:row];
            if (trInfo.isStopped || trInfo.isFinished) {
                NSTableViewRowAction *start = [NSTableViewRowAction rowActionWithStyle:NSTableViewRowActionStyleRegular title:@"Start" handler:^(NSTableViewRowAction *action, NSInteger row) {
                    self->_torrentListView.rowActionsVisible=NO;
                    [self->_connector resumeTorrent:[NSArray arrayWithObject:[NSNumber numberWithInt:trInfo.trId]]];
                }];
                start.image = [NSImage imageNamed:@"StartTemplate"];
                start.backgroundColor = [NSColor systemGreenColor];
                NSTableViewRowAction *forceStart = [NSTableViewRowAction rowActionWithStyle:NSTableViewRowActionStyleRegular title:@"Start\rNow" handler:^(NSTableViewRowAction *action, NSInteger row) {
                    self->_torrentListView.rowActionsVisible=NO;
                    [self->_connector resumeNowTorrent:[NSArray arrayWithObject:[NSNumber numberWithInt:trInfo.trId]]];
                }];
                forceStart.image = [NSImage imageNamed:@"iconPlay"];
                forceStart.backgroundColor = [NSColor colorWithSRGBRed:0.000 green:0.560 blue:0.000 alpha:1];
                return [NSArray arrayWithObjects:start,forceStart,nil];
            }
            else {
                if (trInfo.isWaiting) {
                    NSTableViewRowAction *forcestart = [NSTableViewRowAction rowActionWithStyle:NSTableViewRowActionStyleRegular title:@"Start\rNow" handler:^(NSTableViewRowAction *action, NSInteger row) {
                        self->_torrentListView.rowActionsVisible=NO;
                        [self->_connector resumeNowTorrent:[NSArray arrayWithObject:[NSNumber numberWithInt:trInfo.trId]]];
                    }];
                    forcestart.image = [NSImage imageNamed:@"iconPlay"];
                    forcestart.backgroundColor = [NSColor systemGreenColor];
                    NSTableViewRowAction *stop = [NSTableViewRowAction rowActionWithStyle:NSTableViewRowActionStyleRegular title:@"Stop" handler:^(NSTableViewRowAction *action, NSInteger row) {
                        self->_torrentListView.rowActionsVisible=NO;
                        [self->_connector stopTorrents:[NSArray arrayWithObject:[NSNumber numberWithInt:trInfo.trId]]];
                    }];
                    stop.image = [NSImage imageNamed:@"iconStop36x36"];
                    stop.backgroundColor = [NSColor systemBlueColor];
                    return [NSArray arrayWithObjects:forcestart,stop,nil];
                }
                else {
                    NSTableViewRowAction *stop = [NSTableViewRowAction rowActionWithStyle:NSTableViewRowActionStyleRegular title:@"Stop" handler:^(NSTableViewRowAction *action, NSInteger row) {
                        self->_torrentListView.rowActionsVisible=NO;
                        [self->_connector stopTorrents:[NSArray arrayWithObject:[NSNumber numberWithInt:trInfo.trId]]];
                    }];
                    stop.image= [NSImage imageNamed:@"iconStop36x36"];
                    stop.backgroundColor = [NSColor systemBlueColor];
                    NSTableViewRowAction *reannounce = [NSTableViewRowAction rowActionWithStyle:NSTableViewRowActionStyleRegular title:@"Reannounce" handler:^(NSTableViewRowAction *action, NSInteger row) {
                        self->_torrentListView.rowActionsVisible=NO;
                        [self->_connector reannounceTorrent:[NSArray arrayWithObject:[NSNumber numberWithInt:trInfo.trId]]];
                    }];
                    reannounce.image= [NSImage imageNamed:@"iconRefresh16x16"];
                    reannounce.image.size = NSMakeSize(24,24);
                    reannounce.backgroundColor = [NSColor systemOrangeColor];
                    
                    return [NSArray arrayWithObjects:stop,reannounce,nil];
                    
                }
            }
        }
    }
    return  [NSArray array];
}


#pragma mark - NSSplitViewDelegate

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    if(subview == _categoryView)
        return YES;
    return NO;
}
    

@end

