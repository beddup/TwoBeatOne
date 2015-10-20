//
//  TBOAudioPlayer.m
//  Two Beat One
//
//  Created by Amay on 5/28/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOAudioPlayer.h"
#import "TBOGameSetting.h"
@interface TBOAudioPlayer()

@property(strong,nonatomic)AVAudioPlayer *playMove;
@property(strong,nonatomic)AVAudioPlayer *playAdd;

@end


@implementation TBOAudioPlayer

#pragma mark- Initiatation

-(instancetype)init{
    self=[super init];
    if (self) {
        _enable=YES;
    }
    return self;
}
#pragma mark- Properties
-(AVAudioPlayer *)playAdd{
    if (!_playAdd &&  [TBOGameSetting sharedGameSetting].soundON) {
        NSURL * addSoundURL=[[NSBundle mainBundle] URLForResource:@"TBOadd" withExtension:@"caf"];
        _playAdd=[[AVAudioPlayer alloc]initWithContentsOfURL:addSoundURL error:NULL];
    }
    return _playAdd;
}
-(AVAudioPlayer *)playMove{
    if (!_playMove && [TBOGameSetting sharedGameSetting].soundON) {
        NSURL * moveSoundURL=[[NSBundle mainBundle] URLForResource:@"TBOmove" withExtension:@"caf"];
        _playMove=[[AVAudioPlayer alloc]initWithContentsOfURL:moveSoundURL error:NULL];
        
    }
    return _playMove;
}

#pragma mark- PlayAudio
-(void)playAudioWhenMove{
    if ([TBOGameSetting sharedGameSetting].soundON && self.enable) {
        [self.playMove stop];
        self.playMove.currentTime=0.0; //set currenttime , next time , it will play from the begining
        [self.playMove play];
    }
}
-(void)playAudioWhenAddChessPiece{
    if ([TBOGameSetting sharedGameSetting].soundON && self.enable) {
        [self.playAdd stop];
        self.playAdd.currentTime=0.0;
        [self.playAdd play];
    }
}



@end
