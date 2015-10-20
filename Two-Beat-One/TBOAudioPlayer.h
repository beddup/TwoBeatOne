//
//  TBOAudioPlayer.h
//  Two Beat One
//
//  Created by Amay on 5/28/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TBOAudioPlayer : NSObject

@property(nonatomic)BOOL enable;

-(void)playAudioWhenMove;
-(void)playAudioWhenAddChessPiece;

@end
