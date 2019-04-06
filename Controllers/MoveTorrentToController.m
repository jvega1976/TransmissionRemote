//
//  MoveTorrentToController.m
//  Transmission Remote
//
//  Created by Johnny Vega on 3/30/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "MoveTorrentToController.h"
#import "MainViewController.h"
#import <TransmissionRPC/TransmissionRPC.h>

@interface MoveTorrentToController ()
@property (weak) IBOutlet NSTextField *position;

@end

@implementation MoveTorrentToController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(IBAction)moveTorrentTo:(id)sender {
    [_connector moveTorrentQueue:@[[NSNumber numberWithInt:_trId]] toPosition:@[[NSNumber numberWithInteger: _position.integerValue]]];
    [self dismissController:self];
}


@end
