//
//  MainWindowController.h
//  TransmissionRPClient
//
//  Created by Johnny Vega on 1/26/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN

@interface WindowController : NSWindowController

@property (strong) IBOutlet NSWindow *mainWindow;

@property (strong, nonatomic) IBOutlet NSToolbar *toolbar;

@end

NS_ASSUME_NONNULL_END
