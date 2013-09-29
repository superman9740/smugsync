//
//  Photo.h
//  smugsync
//
//  Created by Shane Dickson on 9/28/13.
//  Copyright (c) 2013 Shane Dickson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject
{
    
    
}

@property (strong, nonatomic) NSString* key;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* path;
@property (assign) BOOL uploaded;

@end
