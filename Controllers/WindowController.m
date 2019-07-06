//
//  MainWindowController.m
//  TransmissionRPClient
//
//  Created by Johnny Vega on 1/26/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import "WindowController.h"
#import <NSTransmissionRPC/NSTransmissionRPC.h>

@interface WindowController () <NSToolbarDelegate>


@end

@implementation WindowController

- (void)windowDidLoad {

    [super windowDidLoad];

    [self.toolbar setVisible:YES];

}
- (BOOL)windowShouldClose:(id)sender {
    [NSApp hide:nil];
    return NO;
}


@end
