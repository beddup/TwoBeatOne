//
//  TBOHistoryCollectionViewCell.h
//  Two-Beat-One
//
//  Created by Amay on 6/25/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TBOHistoryCollectionViewCellDelegate

-(void)deleteHistory:(NSDictionary *)history;

@end


@interface TBOHistoryCollectionViewCell : UICollectionViewCell

@property(strong,nonatomic)NSDictionary *history;
@property(nonatomic)BOOL isChosen;
@property(weak,nonatomic)id<TBOHistoryCollectionViewCellDelegate>delegate;

-(void)hiddenMarkImage;
@end
