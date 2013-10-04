//
//  PrefsViewController.m
//  smugsync
//
//  Created by Shane Dickson on 9/27/13.
//  Copyright (c) 2013 Shane Dickson. All rights reserved.
//

#import "PrefsViewController.h"
#import "AppDelegate.h"

@interface PrefsViewController ()

@end

@implementation PrefsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    
    return self;
}

-(void)awakeFromNib
{
    
    AppDelegate* appDel = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    if(appDel.emailAddress != nil)
    {
        _email.stringValue = appDel.emailAddress;
       _password.stringValue = appDel.password;
       if(appDel.iphotoLibrary != nil)
           _iPhotoLibrary.stringValue = appDel.iphotoLibrary;
        
        if([appDel.showNotifications isEqualToString:@"YES"])
        {
            _showNotifications.state = NSOnState;
            
        }
        else
        {
            _showNotifications.state = NSOffState;
            
        }
        if([appDel.isDefaultIphotoLocation isEqualToString:@"YES"])
        {
            _isIphotoDefault.state = NSOnState;
            
        }
        else
        {
            _isIphotoDefault.state = NSOffState;
            
        }

    }
         
    
}



-(IBAction)savePreferences:(id)sender
{
    AppDelegate* appDel = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    appDel.emailAddress = _email.stringValue;
    appDel.password = _password.stringValue;
    appDel.iphotoLibrary = _iPhotoLibrary.stringValue;
    if(_showNotifications.state == NSOnState)
    {
        appDel.showNotifications = @"YES";
        
    }
    else
    {
        appDel.showNotifications = @"NO";
        
    }
    [appDel savePrefs];
    
    
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
@end
