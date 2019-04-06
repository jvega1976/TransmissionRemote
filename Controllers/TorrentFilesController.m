//
//  TorrentsFileController.m
//  TransmissionRemote
//
//  Created by Johnny Vega on 2/10/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "TorrentFilesController.h"
#import "PreferencesOtherController.h"
#import "MainViewController.h"


@interface TorrentFilesController () <RPCConnectorDelegate,
                                      NSTextFieldDelegate>

@property (strong) IBOutlet NSTreeController *filesTreeController;

@property (strong,nonatomic) IBOutlet NSMenu *filesMenu;
@property (strong,nonatomic) IBOutlet NSOutlineView *torrentFilesView;
@property (strong) IBOutlet NSTextField *fileLocation;
@property (strong) IBOutlet NSView *fileLocationView;
@property (nonatomic) NSMutableArray<DirectoryMapping *> *directoryMapping;
@property (nonatomic) BOOL openFilesWithDoubleClick;
@property (nonatomic) NSString *selectedApp;

@end

@implementation TorrentFilesController
{
    NSArray *selectedFiles;
    BOOL isNameEditable;
    NSTimer *_refreshTimer;
    FSDirectory *_newFilesInfo;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self setConnector:[RPCConnector sharedConnector]];
    
}


- (void)rightMouseDown:(NSEvent *)theEvent {
    [NSMenu popUpContextMenu:_filesMenu withEvent:theEvent forView:_torrentFilesView];
}


-(void)viewWillAppear {
    _torrentFilesView.doubleAction = @selector(renameFile:);
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"TransmissionRemote"];
    _selectedApp = [defaults stringForKey:@"videoApplication"];
    _openFilesWithDoubleClick = [defaults boolForKey:@"openFilesWithDoubleClick"];
    if(_openFilesWithDoubleClick) {
        NSArray *array = [defaults arrayForKey:@"DirectoryMapping"];
        if(array)
            _directoryMapping = [NSMutableArray arrayOfDirectoryMappings:array];
        else
            _directoryMapping = [NSMutableArray array];
        _torrentFilesView.doubleAction = @selector(openFile:);
    }
    selectedFiles = [NSArray array];
        _connector.delegate = self;
            [_connector getAllFilesForTorrentWithId:_torrentId];
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(autorefreshTimerUpdateHandler) userInfo:nil repeats:YES];
}

-(void)autorefreshTimerUpdateHandler{
    _connector.delegate = self;
    [_connector getAllFilesForTorrentWithId:_torrentId];
}


-(void)viewDidAppear {
    _viewAppeared = YES;
    
}


-(void)viewDidDisappear {
    _viewAppeared = NO;
    [_refreshTimer invalidate];
}


-(IBAction)wantedUnwantedFiles:(id)sender {
   NSInteger row;
    if([[sender className] isEqualToString:@"NSMenuItem"]) {
        NSMenuItem *menuItem = (NSMenuItem*)sender;
        NSArray *files = [_filesTreeController selectedObjects];
        if (menuItem.state == NSControlStateValueOn)
            for (FSItem *file in files) {
                if (file.isFile)
                    
                    [_connector stopDownloadingFilesWithIndexes:@[@(file.rpcIndex)] forTorrentWithId:_torrentId];
                else
                    [_connector stopDownloadingFilesWithIndexes:file.rpcFileIndexesUnwanted forTorrentWithId:_torrentId];
            }
        else
            for (FSItem *file in files) {
                if (file.isFile)
                    [_connector resumeDownloadingFilesWithIndexes:@[@(file.rpcIndex)] forTorrentWithId:_torrentId];
                else
                    [_connector resumeDownloadingFilesWithIndexes:file.rpcFileIndexesWanted forTorrentWithId:_torrentId];
            }
    }
    else {
        NSButton *checkbox = (NSButton*)sender;
        NSRect entryRect = [checkbox convertRect:checkbox.bounds toView:_torrentFilesView];
        row = [_torrentFilesView rowAtPoint:entryRect.origin];
        FSItem *fItem = [_torrentFiles itemAtIndex:row];
        _connector.delegate = self;
        if(checkbox.state == NSControlStateValueOn) {
            if (fItem.isFile)
                
                [_connector resumeDownloadingFilesWithIndexes:@[@(fItem.rpcIndex)] forTorrentWithId:_torrentId];
            else
                [_connector resumeDownloadingFilesWithIndexes:fItem.rpcFileIndexesWanted forTorrentWithId:_torrentId];
        }
        else {
        
            if (fItem.isFile)
                
                [_connector stopDownloadingFilesWithIndexes:@[@(fItem.rpcIndex)] forTorrentWithId:_torrentId];
            else
                [_connector stopDownloadingFilesWithIndexes:fItem.rpcFileIndexesUnwanted forTorrentWithId:_torrentId];
        }
    }
}


-(IBAction)setPriority:(id)sender {
    NSMenuItem *menuItem = (NSMenuItem*)sender;
    
    selectedFiles = [_filesTreeController selectedObjects];
    NSMutableArray *rpcIndexes = [NSMutableArray array];
    for (NSInteger i=0; i < selectedFiles.count;i++) {
        FSItem *file = [selectedFiles objectAtIndex:i];
        if (file.isFile) {
            NSNumber *rpcIndex = [NSNumber numberWithInt:file.rpcIndex];
            [rpcIndexes addObject:rpcIndex];
        }
    }
    _connector.delegate = self;
    [_connector setPriority:(int)menuItem.tag forFilesWithIndexes:rpcIndexes forTorrentWithId:_torrentId];
}


-(IBAction)renameSelectedFile:(id)sender {
    [self renameFile:sender];
}


-(void)renameFile:(id)sender {
    NSInteger row = [_torrentFilesView clickedRow];
//    [[_torrentFiles itemAtIndex:row] setIsEditable:YES];
    [_torrentFilesView editColumn:0 row:row withEvent:nil select:YES];
}


-(IBAction)nameFile:(id)sender{
    FSItem *file = [_torrentFiles itemAtIndex:[_torrentFilesView selectedRow]];
    NSTextField *name = (NSTextField*)sender;
    _connector.delegate = self;
    [_connector renameTorrent:_torrentId withName:name.stringValue andPath:file.fullName];
}


-(void)updateFilesInfo:(FSItem*)files{

    FSItem *itemToUpdate;
    if (files.isFile) {
        itemToUpdate = [_torrentFiles itemAtIndex:[_newFilesInfo indexForItem:files]];
        if (itemToUpdate.rpcIndex == files.rpcIndex) {
            [itemToUpdate setName:files.name];
            [itemToUpdate setFullName:files.fullName];
            [itemToUpdate setDownloadProgress:files.downloadProgress];
            [itemToUpdate setDownloadProgressString:files.downloadProgressString];
            [itemToUpdate setPriority:files.priority];
            [itemToUpdate setWanted:files.wanted];
            [itemToUpdate setBytesComplited:files.bytesComplited];
            [itemToUpdate setBytesComplitedString:files.bytesComplitedString];
        }
    }
    else {
        for (FSItem *i in files.items) {
            [self updateFilesInfo:i];
        }
    
    }
}

-(void)openFile:(id)sender {
    NSString *downloadDirectory = [TRSessionInfo sharedTRSessionInfo].downloadDir;
    NSInteger row = [_torrentFilesView clickedRow];
    FSItem *file = [_torrentFiles itemAtIndex:row];
    if(_openFilesWithDoubleClick) {
        if(file.isFile) {
            NSInteger index = [_directoryMapping indexOfObjectPassingTest:^BOOL(DirectoryMapping * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FSItem *parentDir = file.parent;
                while(parentDir.fullName) {
                    if([((DirectoryMapping*)obj).remoteDirectory isEqualToString:parentDir.fullName])
                        return YES;
                    parentDir = parentDir.parent;
                }
                if([((DirectoryMapping*)obj).remoteDirectory isEqualToString:downloadDirectory])
                        return YES;
                return NO;
            }];
            if(index != NSNotFound) {
                NSString *path = [[NSString stringWithFormat:@"%@/%@",downloadDirectory,file.fullName] stringByReplacingOccurrencesOfString:[_directoryMapping objectAtIndex:index].remoteDirectory withString:[_directoryMapping objectAtIndex:index].localDirectory];
                if(_selectedApp)
                    [[NSWorkspace sharedWorkspace] openFile:path withApplication:_selectedApp];
                else
                    [[NSWorkspace sharedWorkspace] openFile:path];
            }
            else {
                NSError *error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier code:90200 userInfo:@{NSLocalizedDescriptionKey:@"There is not a Directory mapping for remote location."}];
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
            }
        }
        else {
            NSInteger index = [_directoryMapping indexOfObjectPassingTest:^BOOL(DirectoryMapping * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FSItem *parentDir = file;
                while(parentDir.fullName) {
                    if([((DirectoryMapping*)obj).remoteDirectory isEqualToString:parentDir.fullName])
                        return YES;
                    parentDir = parentDir.parent;
                }
                if([((DirectoryMapping*)obj).remoteDirectory isEqualToString:downloadDirectory])
                        return YES;
                return NO;
            }];
            if(index != NSNotFound) {
                NSString *path = [[NSString stringWithFormat:@"%@/%@",downloadDirectory,file.fullName] stringByReplacingOccurrencesOfString:[_directoryMapping objectAtIndex:index].remoteDirectory withString:[_directoryMapping objectAtIndex:index].localDirectory];
                [[NSWorkspace sharedWorkspace] openFile:path];
            }
            else {
                NSError *error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier code:90200 userInfo:@{NSLocalizedDescriptionKey:@"There is not a Directory mapping for remote location."}];
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
            }
        }
    }
}

#pragma -- RPCConnectorDelegate

-(void) gotAllFiles:(FSDirectory *)directory forTorrentWithId:(int)torrentId {
    _newFilesInfo = directory;
    [_newFilesInfo recalcRowIndexes];
    [_torrentFiles recalcRowIndexes];
    [self updateFilesInfo:_newFilesInfo.rootItem];
//    [_torrentFilesView expandItem:nil expandChildren:YES];
}


-(void)gotTorrentRenamed:(int)torrentId withName:(NSString *)name andPath:(NSString *)path {
    _connector.delegate = self;
    [_connector getAllFilesForTorrentWithId:_torrentId];
}

@end
