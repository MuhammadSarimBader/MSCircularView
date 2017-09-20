//
//  MSCircularCollectionView.h
//  Fasilite
//
//  Created by Shoaib on 9/14/17.
//  Copyright © 2017 Amaxza Digital. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MSCircularCollectionView;

@protocol MSCircularCollectionViewDelegate <NSObject>

@required
-(void)circularCollectionView:(MSCircularCollectionView *)CCView  DidSelectItemWithValue:(NSString*)value;

@optional
-(void)circularCollectionView:(MSCircularCollectionView *)CCView DidSelectItemAtIndex:(NSInteger)index;
-(void)circularCollectionView:(MSCircularCollectionView *)CCView DidResetToIndex:(NSInteger)index;

@end

@interface MSCircularCollectionView : UIView

@property (nonatomic, weak) id<MSCircularCollectionViewDelegate> delegate;

-(void)scrollToIndex:(NSInteger)index;
-(void)resetToIndex:(NSInteger)index;
-(void)setItems:(NSMutableArray*)array;
-(void)reloaData;


@end
