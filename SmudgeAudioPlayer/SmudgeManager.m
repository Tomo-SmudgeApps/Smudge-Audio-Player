//
//  SmudgeManager.m
//  SmudgeAudioPlayer
//
//  Created by Hisatomo Umaoka on 12/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmudgeManager.h"

@implementation SmudgeManager

-(id) init{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

+(SmudgeManager *) sharedManager{
    static SmudgeManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SmudgeManager alloc] init];
    });
    
    return sharedManager;
}

@end
