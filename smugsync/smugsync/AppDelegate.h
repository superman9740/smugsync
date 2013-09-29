//
//  AppDelegate.h
//  smugsync
//
//  Created by Shane Dickson on 9/24/13.
//  Copyright (c) 2013 Shane Dickson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PrefsViewController;
@class Album;
@class Photo;
@class CDEvents;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{

  
    
    
    
    
    
    
}


@property (assign) IBOutlet NSWindow *window;


@property (strong, nonatomic) NSString* emailAddress;
@property (strong, nonatomic) NSString* password;

@property (strong, nonatomic) NSString* apiKey;
@property (strong, nonatomic) NSString* sessionID;
@property (strong, nonatomic) NSString* iphotoLibrary;

@property (strong, nonatomic) NSString*  showNotifications;


@property (strong, nonatomic) PrefsViewController* viewController;


@property (strong, nonatomic) NSStatusItem* statusItem;
@property (strong,nonatomic) IBOutlet NSMenu* statusMenu;


@property (strong, nonatomic) NSMutableArray* albums;
@property (strong, nonatomic) NSMutableArray* photos;

@property (strong, nonatomic) NSMutableArray* syncedAlbums;
@property (strong, nonatomic) NSMutableArray* syncedPhotos;
@property (strong, nonatomic) CDEvents* events;

@property (strong, nonatomic) dispatch_queue_t uploadQueue;


-(IBAction)showPrefs:(id)sender;
-(void)savePrefs;

-(void)uploadPhotos;
-(void)uploadPhoto:(Photo*)photo album:(Album*)album;


-(void)getSmugmugSession;
-(void)checkforFailedUploads;

-(void)sync;
-(IBAction)checkForiPhotoDirectoryChanges:(id)sender;

-(IBAction)exit:(id)sender;



@end
