//
//  PredicateViewController.m
//  Transmission Remote
//
//  Created by Johnny Vega on 3/30/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "PredicateViewController.h"

@interface PredicateViewController ()

@property (weak) IBOutlet NSPredicateEditor *predicateView;
@property (nonatomic) NSPredicate *predicate;
@property (nonatomic) NSString *searchText;

@end

@implementation PredicateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)viewWillAppear {
    _predicate = _mainViewController.torrents.searchPredicate;
    _searchText = _mainViewController.search.stringValue;
}

-(IBAction)savePredicate:(id)sender{
    [_mainViewController.labelsArrayController rearrangeObjects];
    [_mainViewController.connector getAllTorrents];
    [self dismissController:nil];
}

-(IBAction)cancelPredicateEditor:(id)sender{
    [_mainViewController.torrents setSearchPredicate: _predicate];
    _mainViewController.search.stringValue = _searchText;
    //[_mainViewController.torrents setSearchPredicate:_mainViewController.userPredicate];
    [self dismissController:nil];
}

-(IBAction)resetPredicate:(id)sender{
    [_mainViewController.torrents setSearchPredicate: [NSPredicate predicateWithFormat:@"name like '*' AND (dateAdded > %@ OR dateAdded < %@)",[NSDate dateWithTimeIntervalSinceReferenceDate:1],[NSDate dateWithTimeIntervalSinceReferenceDate:63082281599]]];
    _mainViewController.search.stringValue = @"";
//    [TRInfos.sharedTRInfos setUserFilter: _mainViewController.userPredicate];
//    [_mainViewController setPredicate:[TRInfos.sharedTRInfos predicateForKey:_mainViewController.statusKey]];
}
@end
