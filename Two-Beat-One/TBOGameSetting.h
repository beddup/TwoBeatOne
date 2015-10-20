//
//  TBOGameSetting.h
//  Two Beat One
//
//  Created by Amay on 5/17/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//
#import "defines.h"
#import <Foundation/Foundation.h>

@interface TBOGameSetting : NSObject

@property(nonatomic) GameMode       gameMode;
@property(nonatomic) GameContext    gameContext;
@property(nonatomic) BOOL           soundON;

+(instancetype)sharedGameSetting;
-(void)saveSetting;
@end
