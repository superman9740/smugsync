//
//  AppDelegate.m
//  smugsync
//
//  Created by Shane Dickson on 9/24/13.
//  Copyright (c) 2013 Shane Dickson. All rights reserved.
//

#import "AppDelegate.h"
#import "Album.h"
#import "Photo.h"
#import <CDEvents/CDEvents.h>

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    [_statusText setStringValue:@"App starting up..."];
    
    
    if(_photosToUpload == _photosUploaded)
    {
        _uploadProgressBar.minValue = 0;
        _uploadProgressBar.maxValue = 100;
        [_uploadProgressBar setDoubleValue:100];
        
        
    }
    
    
   
    _apiKey = @"ISDKTktZDsg121V26i4wFQfm6IkOAr3A";
    _photosToUpload = 0;
    
   
    //restore user details from defaults
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
   
    _uploadQueue = dispatch_queue_create("com.company.app.uploadQueue", NULL);
    
    
    
    if (standardUserDefaults) {
        _emailAddress = [standardUserDefaults valueForKey:@"email"];
        _password = [standardUserDefaults valueForKey:@"password"];
        //_apiKey = [standardUserDefaults valueForKey:@"apikey"];
        _iphotoLibrary = [standardUserDefaults valueForKey:@"iphotolibrary"];
        _showNotifications = [standardUserDefaults valueForKey:@"shownotifications"];
        _isDefaultIphotoLocation = [standardUserDefaults valueForKey:@"defaultiphotolocation"];
       
        if([_isDefaultIphotoLocation isEqualToString:@"YES"])
        {
            NSString* homePath = [NSString stringWithFormat:@"%@/Pictures/", NSHomeDirectory()];
            _iphotoLibrary = homePath;
            
            
            
        }
        
        
        
    }
   
    [self getSmugmugSession];
    [self createAlbums];
    
    dispatch_async(_uploadQueue, ^{
        
        [self checkForiPhotoDirectoryChanges:self];
        
    });
    

    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    _statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"photo.png"];
    [_statusItem setHighlightMode:YES];
    
    [_statusItem setMenu:_statusMenu];
    

    NSArray *url  = [NSURL URLWithString:[_iphotoLibrary stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSArray *urls = [NSArray arrayWithObject:url];
    self.events   = [[CDEvents alloc] initWithURLs:urls block:
                     ^(CDEvents *watcher, CDEvent *event) {
                         
                         NSString* fileName = event.URL.lastPathComponent;
                         if([fileName rangeOfString:@"photolibrary"].location != NSNotFound)
                         {
                         
                             dispatch_async(_uploadQueue, ^{
                                 NSLog(@"Directory activity:  %@", _iphotoLibrary);
                                 [self checkForiPhotoDirectoryChanges:self];
                                 
                                 
                             });
                         }
                         
                         
                         
                     }];
    
    
}
-(IBAction)checkForiPhotoDirectoryChanges:(id)sender
{
    
    //First check for a photos.xml file.  If it does not exist, this is the first time the app was run, so all photos are sent up to smugmug
   
        NSDictionary* dict = nil;
    
    
    _syncedAlbums = [[NSMutableArray alloc] initWithCapacity:10];
        
    
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.smugmug.com/services/api/json/1.2.2/?method=smugmug.login.withPassword&EmailAddress=%@&Password=%@&APIKey=%@",_emailAddress, _password,_apiKey]]];
    
        // [request setValue:@"32147430" forHTTPHeaderField:@"X-Smug-AlbumID"];
        // [request setValue:@"0784cbead68f65ed1017fe94cbea5c5f" forHTTPHeaderField:@"X-Smug-SessionID"];
        // [request setValue:@"1.3.0" forHTTPHeaderField:@"X-Smug-Version"];
        [request setHTTPMethod:@"GET"];
    
    
    
        
        
        _albums = [[NSMutableArray alloc] initWithCapacity:10];
        NSString* filePath = nil;
        if([_isDefaultIphotoLocation isEqualToString:@"YES"])
        {
                filePath = [NSString stringWithFormat:@"%@iPhoto Library.photolibrary/AlbumData.xml", _iphotoLibrary];
        }
        else
        {
        
            filePath = [NSString stringWithFormat:@"%@/AlbumData.xml", _iphotoLibrary];
            
        }
    
        dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    

    
        NSArray* albumsDict = [dict objectForKey:@"List of Albums"];
        NSDictionary* photosDict = [dict objectForKey:@"Master Image List"];
        
        
        for (NSDictionary* tempDict in albumsDict)
        {
            NSString* albumName = [tempDict valueForKey:@"AlbumName"];
            NSString* albumType = [tempDict valueForKey:@"Album Type"];
            NSArray* photoKeyList = [tempDict valueForKey:@"KeyList"];
            
            if([albumType isEqualToString:@"Regular"])
            {
                if([albumName isEqualToString:@"Last Import"])
                    continue;
                
                Album* album = [[Album alloc] init];
                album.name = albumName;
                
                for (NSString* key in photoKeyList)
                {
                    Photo* photo = [[Photo alloc] init];
                    photo.key = key;
                    
                    NSDictionary* photoDetail = [photosDict valueForKey:key];
                    photo.name = [photoDetail valueForKey:@"Caption"];
                    photo.path = [photoDetail valueForKey:@"ImagePath"];
                    
                    
                    [album.photos addObject:photo];
                }
                [_albums addObject:album];
                
            }
            else if([albumType isEqualToString:@"Event"])
            {
                if([albumName isEqualToString:@"Last Import"])
                    continue;
                
                Album* album = [[Album alloc] init];
                album.name = albumName;
                
                for (NSString* key in photoKeyList)
                {
                    Photo* photo = [[Photo alloc] init];
                    photo.key = key;
                    
                    NSDictionary* photoDetail = [photosDict valueForKey:key];
                    photo.name = [photoDetail valueForKey:@"Caption"];
                    photo.path = [photoDetail valueForKey:@"ImagePath"];
                    
                    
                    [album.photos addObject:photo];
                }
                [_albums addObject:album];
                
            }
            
            
            
        }
    
    NSLog(@"Number of iPhoto albums found:  %lu", (unsigned long)_albums.count);
    
        [self getSmugmugSession];
        [self createAlbums];
    
    
    for (Album* album in _albums)
    {
   
        //Get photos for this album up on smugmug
        NSError* error = nil;
        NSURLResponse* response;
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.smugmug.com/services/api/json/1.2.2/?method=smugmug.images.get&SessionID=%@&AlbumID=%@&AlbumKey=%@",_sessionID, album.smugmugAlbumID, album.smugmugAlbumKEY]]];
        
        NSData* retVal = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:retVal options:0 error:&error];
        NSDictionary* albumRef = [jsonResponse valueForKey:@"Album"];
        NSArray* images = [albumRef valueForKey:@"Images"];
        Album* syncedAlbum = [[Album alloc] init];
        syncedAlbum.name = album.name;
        syncedAlbum.smugmugAlbumID = album.smugmugAlbumID;
        syncedAlbum.smugmugAlbumKEY = album.smugmugAlbumKEY;
        
        
        for (NSDictionary* imageInfo in images)
        {
            NSString* imageID = [imageInfo valueForKey:@"id"];
            NSString* imageKey = [imageInfo valueForKey:@"Key"];
            
            //Now get image detail info
            NSError* error = nil;
            NSURLResponse* response;
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.smugmug.com/services/api/json/1.2.2/?method=smugmug.images.getInfo&SessionID=%@&ImageID=%@&ImageKey=%@",_sessionID, imageID, imageKey]]];
            
            NSData* retVal = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:retVal options:0 error:&error];
            NSDictionary* imageDetail = [jsonResponse valueForKey:@"Image"];
            
            NSString* filename = [imageDetail valueForKey:@"FileName"];
            
            Photo* photo = [[Photo alloc] init];
            photo.name = filename;
            [syncedAlbum.photos addObject:photo];
            
            
            
        }
        
    
        [_syncedAlbums addObject:syncedAlbum];
    }
    

[self sync];

}

-(void)checkforFailedUploads
{
    
    
}


-(void)sync
{
    BOOL wereAnyPhotosUploaded = NO;
    
    
    
    _photosUploaded = 0;
    _photosToUpload = 0;
    
    _statusItem.image = [NSImage imageNamed:@"camera_arrow_down.png"];

    
    for (Album* album in _albums)
    {
        for (Album* uploadedAlbum in _syncedAlbums)
        {
            if([album.name isEqualToString:uploadedAlbum.name])
            {
                //This album has already been uploaded, now check the images
                for (Photo* photo in album.photos)
                {
                    BOOL photoWasFound = NO;
                    for (Photo* uploadedPhoto in uploadedAlbum.photos)
                    {
                        if([photo.name isEqualToString:uploadedPhoto.name])
                        {
                            photoWasFound = YES;
                            
                        }
                        
                
                    }
                
                
                        //This photo was never uploaded.  Upload it now.
                    if(!photoWasFound)
                    {
                        _photosToUpload++;
                      
                    }
                
                
                
                }
            }
            
            
        }
    }
    
    
 
    
    
    for (Album* album in _albums)
    {
        for (Album* uploadedAlbum in _syncedAlbums)
        {
            if([album.name isEqualToString:uploadedAlbum.name])
            {
                //This album has already been uploaded, now check the images
                for (Photo* photo in album.photos)
                {
                    BOOL photoWasFound = NO;
                    for (Photo* uploadedPhoto in uploadedAlbum.photos)
                    {
                        if([photo.name isEqualToString:uploadedPhoto.name])
                        {
                            photoWasFound = YES;
                            
                        }
                        
                        
                    }
                    
                    
                    //This photo was never uploaded.  Upload it now.
                    if(!photoWasFound)
                    {
                        [_uploadProgressBar setHidden:NO];
                         _statusText.stringValue = @"Uploading photo...";
                        [self uploadPhoto:photo  album:album];
                        wereAnyPhotosUploaded = YES;
                        photoWasFound = NO;
                    }
                    
                    
                    
                }
            }
            
            
        }
    }
    
    
    
    
    
    
    
 if(wereAnyPhotosUploaded && [_showNotifications isEqualToString:@"YES"])
 {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Smugmug Sync";
    notification.informativeText = @"Photos have been uploaded to your Smugmug account.";
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
 }
    
    _statusItem.image = [NSImage imageNamed:@"camera_checkmark.png"];
    _statusText.stringValue = @"synced.";
    [_uploadProgressBar setHidden:YES];
    
    
    
}
-(void)uploadPhoto:(Photo*)photo album:(Album*)album
{
    
    NSLog(@"Uploading photo:  %@", photo.name);
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://upload.smugmug.com"]];
    [request setValue:album.smugmugAlbumID forHTTPHeaderField:@"X-Smug-AlbumID"];
    [request setValue:_sessionID forHTTPHeaderField:@"X-Smug-SessionID"];
    [request setValue:@"1.3.0" forHTTPHeaderField:@"X-Smug-Version"];
    [request setValue:photo.name forHTTPHeaderField:@"X-Smug-FileName"];

    [request setHTTPMethod:@"POST"];
    
    
    NSData* data = [NSData dataWithContentsOfFile:photo.path];
    [request setHTTPBody:data];
    NSError* error = nil;
    NSURLResponse* response;
    
    NSData* retVal = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    
    
    _photosUploaded++;
    
    double percentCompeted = _photosUploaded / _photosToUpload;
    
    NSLog(@"Percent completed: %f", percentCompeted * 100);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_uploadProgressBar setDoubleValue:percentCompeted * 100];
        
        if(_photosToUpload == _photosUploaded)
        {
            _uploadProgressBar.minValue = 0;
            _uploadProgressBar.maxValue = 100;
            [_uploadProgressBar setDoubleValue:100];
            
            _photosUploaded = 0;
            _photosToUpload = 0;
            
        }
        
        
    });
    
    
    
    
    
}

-(void)getSmugmugSession
{

    
   

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.smugmug.com/services/api/json/1.2.2/?method=smugmug.login.withPassword&EmailAddress=%@&Password=%@&APIKey=%@",_emailAddress, _password,_apiKey]]];
                                    
   // [request setValue:@"32147430" forHTTPHeaderField:@"X-Smug-AlbumID"];
   // [request setValue:@"0784cbead68f65ed1017fe94cbea5c5f" forHTTPHeaderField:@"X-Smug-SessionID"];
   // [request setValue:@"1.3.0" forHTTPHeaderField:@"X-Smug-Version"];
    [request setHTTPMethod:@"GET"];
    
    
    NSError* error = nil;
    NSURLResponse* response;
    
    if(error)
    {
        NSLog(@"Error in getting session:  %@", error.localizedDescription);
        
        printf("getSmugmugSession:  %s.\n", error.localizedDescription.UTF8String);
        
    }
    else
    {
        NSLog(@"getSmugmugSession:  success\n");
        printf("getSmugmugSession:  success\n");
        _statusText.stringValue = @"Session id created...";
        
    }
    NSData* retVal = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:retVal options:0 error:&error];
    NSDictionary* loginResponse = [jsonResponse valueForKey:@"Login"];
    NSDictionary* sessionDict = [loginResponse objectForKey:@"Session"];
    _sessionID = [sessionDict objectForKey:@"id"];
    NSLog(@"session id:  %@", _sessionID);
    
    
}
-(void)createAlbums
{
   
    _statusText.stringValue = @"Scanning for new albums...";

    
    
    
    for (Album* album in _albums)
    {
        NSLog(@"Logger:  Checking for albums\n");
        NSString* urlStr = [NSString stringWithFormat:@"http://api.smugmug.com/services/api/json/1.2.2/?method=smugmug.albums.create&SessionID=%@&Title=%@&Public=false&Unique=true", _sessionID, album.name];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                                        
                                                                                                
        [request setHTTPMethod:@"GET"];
        
        NSError* error = nil;
        NSURLResponse* response;
        
        NSData* retVal = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if(!error)
        {
            NSDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:retVal options:0 error:&error];
            NSDictionary* createResponse = [jsonResponse valueForKey:@"Album"];
            NSNumber* albumID = [createResponse valueForKey:@"id"];
            NSString* albumKEY = [createResponse valueForKey:@"Key"];
        
                              
            album.smugmugAlbumID = albumID.stringValue;
            album.smugmugAlbumKEY = albumKEY;
        
        
            if(error != nil)
            {
                NSLog(@"Logger:  Create album error:  %@", error.localizedDescription);
            
            }
        }
        else
        {
            
            NSLog(@"Logger:  Error:  %@\n", error.localizedDescription);
            
        }
        

    }
   

  //  http://api.smugmug.com/services/api/json/1.2.2/?method=smugmug.albums.create&SessionID=2b5b565ce0954834d8d8675cce701818&Title=TestThisAlbum
    
}
-(void)uploadPhotos
{
    
    _statusText.stringValue = @"Scanning for new photos...";
    

    for (Album* album in _albums)
    {
    
        for (Photo* photo in album.photos)
        {
            printf("uploading photo\n");
            
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://upload.smugmug.com"]];
            [request setValue:album.smugmugAlbumID forHTTPHeaderField:@"X-Smug-AlbumID"];
            [request setValue:_sessionID forHTTPHeaderField:@"X-Smug-SessionID"];
            [request setValue:photo.name forHTTPHeaderField:@"X-Smug-FileName"];
            
            [request setValue:@"1.3.0" forHTTPHeaderField:@"X-Smug-Version"];
            [request setHTTPMethod:@"POST"];
            
            
            NSData* data = [NSData dataWithContentsOfFile:photo.path];
            [request setHTTPBody:data];
            NSError* error = nil;
            NSURLResponse* response;
            
            
            NSData* retVal = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if(error == nil)
            {
                photo.uploaded = YES;
                
                
            }
            
        }
    }
    
    
    int x = 5;
    

    
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)theApplication  hasVisibleWindows:(BOOL)flag
{
    [self.window makeKeyAndOrderFront:self];
    return YES;
}

-(void)savePrefs
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Logger:  Saving prefs.\n");
    NSLog(@"iPhoto path:  %@", _iphotoLibrary);
    
    if (standardUserDefaults) {
        [standardUserDefaults setValue:_emailAddress forKey:@"email"];
        [standardUserDefaults setValue:_password forKey:@"password"];
        //[standardUserDefaults setValue:_apiKey forKey:@"apikey"];
        [standardUserDefaults setValue:_iphotoLibrary forKey:@"iphotolibrary"];
        [standardUserDefaults setValue:_showNotifications forKey:@"shownotifications"];
        [standardUserDefaults setValue:_isDefaultIphotoLocation forKey:@"defaultiphotolocation"];
        
        [standardUserDefaults synchronize];
        
    /*
        if([_isDefaultIphotoLocation isEqualToString:@"YES"])
        {
            NSString* homePath = [NSString stringWithFormat:@"%@/Pictures/iPhoto Library.photolibrary", NSHomeDirectory()];
            _iphotoLibrary = homePath;
            
            
            
        }
*/
        
    }
    [self getSmugmugSession];
    [self createAlbums];
    _statusText.stringValue = @"synced.";
    
    NSArray *url  = [NSURL URLWithString:[_iphotoLibrary stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSArray *urls = [NSArray arrayWithObject:url];
    self.events   = [[CDEvents alloc] initWithURLs:urls block:
                     ^(CDEvents *watcher, CDEvent *event) {
                         NSLog(
                               @"Logger:  URLWatcher: %@\nEvent: %@",
                               watcher,
                               event
                               );
                         
                         NSString* fileName = event.URL.lastPathComponent;
                         if([fileName rangeOfString:@"photolibrary"].location != NSNotFound)
                         {
                             dispatch_async(_uploadQueue, ^{
                                 NSLog(@"Logger:  Directory update detected.");
                                 
                                 [self checkForiPhotoDirectoryChanges:self];
                                 
                             });
                             
                             
                         }
                         
                        
                         
                     }];
    [self.window orderOut:self];
    

}
-(IBAction)exit:(id)sender
{
    [NSApp terminate:self];
    
}

-(IBAction)showPrefs:(id)sender
{
   
    
    if(_emailAddress != nil)
    {
        _email.stringValue = _emailAddress;
        _prefsPassword.stringValue = _password;
        if(_iphotoLibrary != nil)
            _iPhotoLibrary.stringValue = _iphotoLibrary;
        
        if([_showNotifications isEqualToString:@"YES"])
        {
            _prefsShowNotifications.state = NSOnState;
            
        }
        else
        {
            _prefsShowNotifications.state = NSOffState;
            
        }
        if([_isDefaultIphotoLocation isEqualToString:@"YES"])
        {
            _isIphotoDefault.state = NSOnState;
            
        }
        else
        {
            _isIphotoDefault.state = NSOffState;
            
        }
        
    }
    

    
    //[_window.contentView addSubview:_viewController.view];
    [_window makeKeyAndOrderFront:self];
    
   
    
    
}

-(IBAction)changeOpenAtLogin:(id)sender
{
    if(_openAtLogin.state == NSOnState)
    {
        
        [self addAppAsLoginItem];
        
    }
    else
    {
        [self deleteAppFromLoginItem];
        
        
    }
    
    
    
}

-(void) addAppAsLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}


-(IBAction)changeIsDefaultiPhotoLocation:(id)sender
{
    AppDelegate* appDel = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    if(_isIphotoDefault.state == NSOnState)
    {
        appDel.isDefaultIphotoLocation = @"YES";
        
    }
    else
    {
        appDel.isDefaultIphotoLocation = @"NO";
        
    }
    [appDel savePrefs];
    
}
-(IBAction)browseForIphotoFile:(id)sender
{
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    // Configure your panel the way you want it
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    //[panel setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
    
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            
            for (NSURL *fileURL in [panel URLs]) {
                
                NSString* path = fileURL.path;
                _iPhotoLibrary.stringValue = path;
                
            }
        }
        
        
    }];
    
    
    
    
}


-(void) deleteAppFromLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		int i = 0;
		for(i ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                                         objectAtIndex:i]);
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
    }
}


-(IBAction)savePreferences:(id)sender
{
    _emailAddress = _email.stringValue;
    _password = _prefsPassword.stringValue;
    _iphotoLibrary = _iPhotoLibrary.stringValue;
    if(_prefsShowNotifications.state == NSOnState)
    {
        _showNotifications = @"YES";
        
    }
    else
    {
        _showNotifications = @"NO";
        
    }
    [self savePrefs];
    
    
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    return NSTerminateNow;
}

@end
