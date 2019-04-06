//
//  MainViewController.h
//  TransmissionRemote
//
//  Created by  on 2/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TransmissionRPC/TransmissionRPC.h>
#import <CategorizationKit/CategorizationKit.h>
#import "CategorizationKitExtensions.h"
#import "TransmissionRPCExtensions.h"
#import "NSApplicationAdditions.h"



NS_ASSUME_NONNULL_BEGIN

@interface TRInfo (TRInfoEditing)

@property (nonatomic) BOOL isNameEditable;

@end


@interface MainViewController : NSViewController <RPCConnectorDelegate,
                                                    NSTableViewDataSource,
                                                    NSTableViewDelegate,
                                                    NSTextFieldDelegate,
                                                    NSSplitViewDelegate>

@property (nonatomic) NSURL     *urlConfig;
@property (nonatomic) RPCConnector *connector;
@property (nonatomic) Categorization *torrents;

@property (strong) IBOutlet NSTableView *statusCategoriesView;
@property (strong) IBOutlet NSTableView *torrentListView;

@property (strong) IBOutlet __block NSArrayController *torrentArrayController;
@property (nonatomic) IBOutlet __block NSArrayController *labelsArrayController;

@property (strong) IBOutlet NSSearchField *search;

@property (nonatomic) NSTimer *refreshTimer;

@property (nonatomic) TRSessionInfo *trSessionInfo;
@property (nonatomic) TRSessionStats *trSessionStats;

@property (nonatomic) NSString *sessionURL;
@property (nonatomic) NSString *userSession;

@property(nonatomic) NSMutableArray *sortCriteria;
@property(nonatomic) NSPredicate *userPredicate;

@property (nonatomic)   NSString *uploadedBytes;
@property (nonatomic)   NSString *downloadedBytes;
@property (nonatomic)   NSString *secondsActive;
@property (nonatomic)   NSString *filesAdded;
@property (nonatomic)   NSString *torrentsCount;
@property (nonatomic)   NSString *activeTorrentsCount;
@property (nonatomic)   NSString *pausedTorrentsCount;
@property (nonatomic)   NSString *downloadSpeed;
@property (nonatomic)   NSString *uploadSpeed;

@property (nonatomic)   int trEditing;

- (void)stopRefreshing;

- (void)startRefreshingWithURL:(NSURL*)url;
- (void)startRefreshingWithURL:(NSURL*)url refreshTime:(int)refreshTime andRequestTime:(int)requestTime;


@end


NS_ASSUME_NONNULL_END
