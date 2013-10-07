//
//  AppDelegate.h
//  smugsync
//
//  Created by Shane Dickson on 9/24/13.
//  Copyright (c) 2013 Shane Dickson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Album;
@class Photo;
@class CDEvents;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{

  
    
    
    
    
    
    
}

//Prefs

@property (strong, nonatomic) IBOutlet NSTextField* email;
@property (strong, nonatomic) IBOutlet NSTextField* prefsPassword;
@property (strong, nonatomic) IBOutlet NSTextField* iPhotoLibrary;



@property (strong, nonatomic) IBOutlet NSButton* prefsShowNotifications;
@property (strong, nonatomic) IBOutlet NSButton* openAtLogin;
@property (strong, nonatomic) IBOutlet NSButton* isIphotoDefault;



@property (assign) IBOutlet NSWindow *window;


@property (strong, nonatomic) NSString* emailAddress;
@property (strong, nonatomic) NSString* password;

@property (strong, nonatomic) NSString* apiKey;
@property (strong, nonatomic) NSString* sessionID;
@property (strong, nonatomic) NSString* iphotoLibrary;

@property (strong, nonatomic) NSString*  showNotifications;
@property (strong, nonatomic) NSString*  isDefaultIphotoLocation;




@property (strong, nonatomic) NSStatusItem* statusItem;
@property (strong,nonatomic) IBOutlet NSMenu* statusMenu;


@property (strong, nonatomic) NSMutableArray* albums;
@property (strong, nonatomic) NSMutableArray* photos;

@property (strong, nonatomic) NSMutableArray* syncedAlbums;
@property (strong, nonatomic) NSMutableArray* syncedPhotos;
@property (strong, nonatomic) CDEvents* events;

@property (strong, nonatomic) dispatch_queue_t uploadQueue;
@property (strong, nonatomic) NSPipe* pipe;
@property (strong, nonatomic) NSFileHandle* pipeHandle;


@property (nonatomic, assign) double photosToUpload;
@property (nonatomic, assign) double photosUploaded;

@property (strong, nonatomic) IBOutlet NSProgressIndicator* uploadProgressBar;

@property (strong, nonatomic) IBOutlet NSTextField* statusText;


-(IBAction)updateProgess:(id)sender;


-(IBAction)showPrefs:(id)sender;
-(void)savePrefs;

-(void)uploadPhotos;
-(void)uploadPhoto:(Photo*)photo album:(Album*)album;


-(void)getSmugmugSession;
-(void)checkforFailedUploads;

-(void)sync;
-(IBAction)checkForiPhotoDirectoryChanges:(id)sender;

-(IBAction)exit:(id)sender;

-(IBAction)savePreferences:(id)sender;


@end
