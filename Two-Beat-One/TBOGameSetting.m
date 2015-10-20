//
//  TBOGameSetting.m
//  Two Beat One
//
//  Created by Amay on 5/17/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOGameSetting.h"
@interface TBOGameSetting()

@end

@implementation TBOGameSetting

#pragma mark - sharedInstance

static TBOGameSetting * _sharedInstance;
+(instancetype)sharedGameSetting{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance=[[self alloc]init];
    });
    return _sharedInstance;

}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance=[[super allocWithZone:zone]init];
    });
    return _sharedInstance;

}
-(id)copy{
    return _sharedInstance;
}

-(instancetype)init{

    static TBOGameSetting *gameSetting=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gameSetting=[super init];
    });
    return gameSetting;

}

#pragma mark - properties
-(GameMode)gameMode{
    return [[NSUserDefaults standardUserDefaults]integerForKey:@"GAME_MODE"];
}
-(void)setGameMode:(GameMode)gameMode{
    [[NSUserDefaults standardUserDefaults] setInteger:gameMode forKey:@"GAME_MODE"];
}

-(GameContext)gameContext{
    return [[NSUserDefaults standardUserDefaults]integerForKey:@"GAME_CONTEXT"];
}

-(void)setGameContext:(GameContext)gameContext{
    [[NSUserDefaults standardUserDefaults] setInteger:gameContext forKey:@"GAME_CONTEXT"];

}

-(BOOL)soundON{
    return [[NSUserDefaults standardUserDefaults]boolForKey:@"SOUND"];
}
-(void)setSoundON:(BOOL)soundON{
    [[NSUserDefaults standardUserDefaults] setBool:soundON forKey:@"SOUND"];
}
#pragma mark - save setting
-(void)saveSetting{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
