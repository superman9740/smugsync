//
//  Album.h
//  smugsync
//
//  Created by Shane Dickson on 9/28/13.
//  Copyright (c) 2013 Shane Dickson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

@interface Album : NSObject
{
    
    
}

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* albumID;
@property (strong, nonatomic) NSString* smugmugAlbumID;
@property (strong, nonatomic) NSString* smugmugAlbumKEY;



@property (strong, nonatomic) NSMutableArray* photos;




@end
