//
//  PrefsViewController.h
//  smugsync
//
//  Created by Shane Dickson on 9/27/13.
//  Copyright (c) 2013 Shane Dickson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AppDelegate;



@interface PrefsViewController : NSViewController
{
    
    
}

@property (strong, nonatomic) IBOutlet NSTextField* email;
@property (strong, nonatomic) IBOutlet NSTextField* password;
@property (strong, nonatomic) IBOutlet NSTextField* iPhotoLibrary;



@property (strong, nonatomic) IBOutlet NSButton* showNotifications;
@property (strong, nonatomic) IBOutlet NSButton* openAtLogin;
@property (strong, nonatomic) IBOutlet NSButton* isIphotoDefault;


@property (strong, nonatomic) IBOutlet NSTextView* debugView;




-(IBAction)savePreferences:(id)sender;
-(void) addAppAsLoginItem;
-(IBAction)changeOpenAtLogin:(id)sender;
-(IBAction)changeIsDefaultiPhotoLocation:(id)sender;
-(IBAction)browseForIphotoFile:(id)sender;



@end
