//
//  MSCircularScrollView.h
//  Fasilite
//
//  Created by Shoaib on 9/18/17.
//  Copyright © 2017 Amaxza Digital. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MSCircularScrollView;

@protocol MSCircularScrollViewDelegate <NSObject>

@required
-(void)circularScrollView:(MSCircularScrollView *)CSView  DidSelectItemWithValue:(NSString*)value;

@optional
-(void)circularScrollView:(MSCircularScrollView *)CSView DidSelectItemAtIndex:(NSInteger)index;
-(void)circularScrollView:(MSCircularScrollView *)CSView DidResetToIndex:(NSInteger)index;

@end


@interface MSCircularScrollView : UIScrollView

@property(weak, nonatomic) id<MSCircularScrollViewDelegate> delegateCS;
//
-(void)scrollToPageIndex:(NSInteger)index;
-(void)resetToPageIndex:(NSInteger)index;
//
-(void)setItems:(NSMutableArray*)array;
-(void)addPageViews;

@end
