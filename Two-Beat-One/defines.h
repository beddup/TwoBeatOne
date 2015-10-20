//
//  notification.h
//  Two Beat One
//
//  Created by Amay on 4/30/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//
#
#ifndef Two_Beat_One_notification_h
#define Two_Beat_One_notification_h

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    GameModeStandard,
    GameModeCustom,  //player custom the inital locaiton
} GameMode;

typedef enum : NSUInteger {
    GameContextOnLine,
    GameContextBlueTooth,
    GameContextOffline,
} GameContext;

#define historyPath  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"histoty.plist"]

#define GameModeAndGameContextDeterminedNotification @"GameModeAndGameContextDeterminedNotification"

#define APP_ID @"995903223"

#define Default_Time_Out 25.0



#endif
