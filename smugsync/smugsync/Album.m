//
//  Album.m
//  smugsync
//
//  Created by Shane Dickson on 9/28/13.
//  Copyright (c) 2013 Shane Dickson. All rights reserved.
//

#import "Album.h"

@implementation Album
-(Album*)init
{
    
    _photos = [[NSMutableArray alloc] initWithCapacity:10];
    
    
    return self;
    
    
}
@end
