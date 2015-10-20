//
//  TBOLeaderBoardCell.h
//  Two Beat One
//
//  Created by Amay on 5/26/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBOLeaderBoardCell : UITableViewCell

@property(nonatomic)NSUInteger rank;
@property(strong,nonatomic)UIImage  *playerPhoto;
@property(strong,nonatomic)NSString *playerName;
@property(strong,nonatomic)NSString *performance;
@property(strong,nonatomic)NSString *formattedperformance;

@end
