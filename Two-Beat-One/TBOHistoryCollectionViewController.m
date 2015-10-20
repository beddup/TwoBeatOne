//
//  TBO_History_CVC.m
//  Two Beat One
//
//  Created by Amay on 5/8/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOHistoryCollectionViewController.h"
#import "OptionsViewController.h"
#import "defines.h"
#import "Position.h"
#import "TBOPlayHistoryViewController.h"
#import "TBOHistoryCollectionViewCell.h"

#define History_Choose_Title NSLocalizedStringFromTable(@"History_Choose_Title", @"historyVC", nil)
#define History_Delete_Title NSLocalizedStringFromTable(@"History_Delete_Title", @"historyVC", nil)
#define History_Cancel_Title NSLocalizedStringFromTable(@"History_Cancel_Title", @"historyVC", nil)

@interface TBOHistoryCollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,TBOHistoryCollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(strong,nonatomic)NSMutableArray *history;
@property (weak, nonatomic) IBOutlet UIButton *chooseToDeleteButton;
@end

@implementation TBOHistoryCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden=YES;
    self.history=[NSMutableArray arrayWithContentsOfFile:historyPath];
    if (!self.history.count) {
        [self.chooseToDeleteButton setTitle:@"" forState:UIControlStateNormal];
    }

    [self.collectionView registerClass:[TBOHistoryCollectionViewCell class]
            forCellWithReuseIdentifier:@"ReuseableHistoryCollectionCell"];

    self.collectionView.backgroundColor=[UIColor clearColor];
    [self configureLayout];
    self.chooseToDeleteButton.hidden=!self.history.count;

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    for (NSMutableDictionary *history in self.history) {
        [history setObject:@(NO) forKey:@"isChosen"];
    }
    [self.history writeToFile:historyPath atomically:NO];

}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
-(void)configureLayout{
    
    UICollectionViewFlowLayout *flowLayout=(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.sectionInset=UIEdgeInsetsMake(5, 10, 5, 10);
    flowLayout.minimumInteritemSpacing=16;
    flowLayout.minimumLineSpacing=20;

    NSInteger countInALine=(NSInteger)(CGRectGetWidth(self.view.frame)/200+0.5);
    CGFloat contentSpaceWidth=CGRectGetWidth(self.view.frame)-flowLayout.sectionInset.left-flowLayout.sectionInset.right-flowLayout.minimumInteritemSpacing*(countInALine-1);
    flowLayout.itemSize=CGSizeMake(contentSpaceWidth/countInALine, contentSpaceWidth/countInALine);
    
}

- (IBAction)back:(UIButton *)sender {
    if (self.splitViewController) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)chooseToDelete:(UIButton*)sender {

    if (self.isEditing) {
        // if delete tapped
        NSMutableArray *historyToBeDelete=[@[] mutableCopy];
        for (NSMutableDictionary *history in self.history) {
            if ([history[@"isChosen"]boolValue]) {
                [historyToBeDelete addObject:history];
            }
        }
        if (historyToBeDelete.count) {
            [self.history removeObjectsInArray:historyToBeDelete];
            [sender setTitle:self.history.count ? History_Cancel_Title : @"" forState:UIControlStateNormal];
            [self.collectionView reloadData];
            return;
        }

        // if cancel tapped
        for (TBOHistoryCollectionViewCell *cell in self.collectionView.visibleCells) {
            [cell hiddenMarkImage];
            [sender setTitle:History_Choose_Title forState:UIControlStateNormal];
            self.editing=NO;
        }
        return;
    }
    // if choose tapped
    for (TBOHistoryCollectionViewCell *cell in self.collectionView.visibleCells) {
        [sender setTitle:History_Cancel_Title forState:UIControlStateNormal];
        cell.isChosen=NO;
        self.editing=YES;
    }
}

#pragma mark - datasource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.history.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TBOHistoryCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ReuseableHistoryCollectionCell" forIndexPath:indexPath];
    cell.history=self.history[indexPath.row] ;
    cell.delegate=self;
    if (self.isEditing) {
        cell.isChosen=[cell.history[@"isChosen"] boolValue];
    }
    return cell;
}

#pragma mark - collectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    if (self.editing) {
        NSMutableDictionary *history=self.history[indexPath.row];
        TBOHistoryCollectionViewCell *cell=(TBOHistoryCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.isChosen=![history[@"isChosen"] boolValue];
        [history setObject:@(cell.isChosen) forKey:@"isChosen"];
        if (cell.isChosen) {
            [self.chooseToDeleteButton setTitle:History_Delete_Title
                                       forState:UIControlStateNormal];
            return;
        }
        for (NSDictionary *history in self.history) {
            if ([history[@"isChosen"] boolValue]) {
                [self.chooseToDeleteButton setTitle:History_Delete_Title
                                           forState:UIControlStateNormal];
                return;
            }
        }
        [self.chooseToDeleteButton setTitle:History_Cancel_Title
                                   forState:UIControlStateNormal];
        return;
    }
    
    self.theChosenHistory=self.history[indexPath.row];
    [self performSegueWithIdentifier:@"playHistory" sender:nil];

}
#pragma mark - navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"playHistory"]) {
        TBOPlayHistoryViewController *vc=(TBOPlayHistoryViewController *)segue.destinationViewController;
        vc.history=self.theChosenHistory;
    }
}
#pragma mark - Collection Cell Delegate
-(void)deleteHistory:(NSDictionary *)history{

    [self.history removeObject:history];
    [self.collectionView reloadData];

}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
