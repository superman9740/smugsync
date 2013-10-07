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





@end
