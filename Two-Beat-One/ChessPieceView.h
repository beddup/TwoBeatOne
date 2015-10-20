//
//  ChessPiece.h
//  Two Beat One
//
//  Created by Amay on 5/14/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Position.h"

@interface ChessPieceView : UIImageView

@property(strong,nonatomic)Position *position;
@property(nonatomic,getter=isOpposite,readonly)BOOL opposite;
@property(nonatomic,getter=isChosen)BOOL chosen;

-(instancetype)initWithSide:(BOOL)isOpposite;

@end
