//
//  TBOGameCommunicatorPublicity.h
//  Two Beat One
//
//  Created by Amay on 5/30/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//


#ifndef Two_Beat_One_TBOGameCommunicatorPublicity_h
#define Two_Beat_One_TBOGameCommunicatorPublicity_h

#define DATA_INFO_KEY_DATAID        @"ID"
#define DATA_INFO_KEY_DATATYPE      @"DATATYPE"
#define DATA_INFO_KEY_ACTIONTYPE    @"ACTIONTYPE"
#define DATA_INFO_KEY_ACTION        @"ACTION"
#define DATA_INFO_KEY_SITUATION     @"SITUATION"

#define ACTION_MOVE_KEY_FROM  @"MOVE FROM"
#define ACTION_MOVE_KEY_TO  @"MOVE TO"
#define GAME_COMMUNICATOR @"GAME COMMUNICATOR"
#define GAME_MODE @"GAME_MODE"
#define GAME_CONTEXT @"GAME CONTEXT"
#define CONNECTION_LOST @"CONNECT LOST"

typedef enum : NSUInteger {
    DATATYPE_ACTION=1,
    DATATYPE_RETURNRECEIPT,
    DATATYPE_REPORT_SITUATION,
} DATA_INFO_DATATYPE_VALUE;

typedef enum : NSUInteger {
    ACTIONTYPEADDCHESSPIECE=1,
    ACTIONTYPEMOVE,
    ACTIONTYPERANDOMNUMBER,
    ACTIONTYPEREQUESTPLAYONCEMORE,
} ACTIONTYPE;

typedef enum : NSUInteger {
    REQUESTPLAYONCEMORESENT=1,
    REQUESTPLAYONCEMOREACCEPTTED,
    REQUESTPLAYONCEMOREREFUSED,
} ACTION_REQUEST_PLAYONCEMORE_STATE;

typedef enum : NSUInteger {
    TBOSendDataModeReliable=0,
    TBOSendDataModeUnreliable,
} TBOSendDataMode;
typedef enum : NSUInteger {
    MatchStateDefault=0, // didn't find a player
    MatchStateConnecting,
    MatchStateStarted,
    MatchStateTerminated, // app interrop by system event, into background
} MatchState;

typedef enum : NSUInteger {
    PlayerSituationNormal=0,
    PlayerSituationInactive,
} PlayerSituation;


#endif
