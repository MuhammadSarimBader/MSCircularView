//
//  MSCircularScrollView.m
//  Fasilite
//
//  Created by Shoaib on 9/18/17.
//  Copyright © 2017 Amaxza Digital. All rights reserved.
//

#import "MSCircularScrollView.h"
#import "MSPageView.h"
#import <math.h>


@interface MSCircularScrollView ()<UIScrollViewDelegate>
//@property (strong, nonatomic) NSMutableArray* originalArray;

@end

enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

CGPoint lastContentOffset;

static NSString *PAGE_VIEW = @"MSPageView";


@implementation MSCircularScrollView
{
    //
    NSInteger currentPage;
    NSInteger lastPage;
    //
    BOOL didScrollReset;
    //
    NSMutableArray* originalArray;
    NSMutableArray* dataArray;
    //
    //NSInteger dataArraySelectedIndex;
}

-(void)awakeFromNib{
    
    [super awakeFromNib];
    
    self.delegate=self;
    //
    originalArray=[NSMutableArray arrayWithObjects:@"No Item Found", nil];
    
    //Handle drag and scroll, to set scroll position only once.
    didScrollReset=NO;
    
}

-(void)addPageViews{
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    for (int i=0; i<dataArray.count; i++) {
        
        CGRect frame;
        frame.origin.x = screenBounds.size.width * i;
        frame.origin.y = 0;
        frame.size.width = screenBounds.size.width;
        frame.size.height=self.frame.size.height;

        MSPageView *pageView = [[[NSBundle mainBundle] loadNibNamed:PAGE_VIEW owner:self options:nil] objectAtIndex:0];
        [pageView setFrame:CGRectMake(screenBounds.size.width * i, 0, screenBounds.size.width, self.frame.size.height)];
        [pageView.lblTest setText:dataArray[i]];
        /* //add imageview
        UIImageView* imageView = [[UIImageView alloc]init];
        CGRect imageFrame;
        imageFrame.origin.x = 0;
        imageFrame.origin.y = 0;
        imageFrame.size.width = screenBounds.size.width;
        imageFrame.size.height = screenBounds.size.height;
        imageView.frame = imageFrame;
        
        [subView addSubview:imageView];
        imageView.image = [UIImage imageNamed:withGateImages[i]];
        
        [imageView setBackgroundColor:[UIColor clearColor]];
        */
        [self addSubview:pageView];
    }
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    self.contentSize = contentRect.size;
    [self setFrameAtPageIndex:20 animated:NO];
}


#pragma mark - Self Action
-(void)reloadCircularScrollView{
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    dataArray=[originalArray mutableCopy];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    for (int i=0; i<dataArray.count; i++) {
        
        CGRect frame;
        frame.origin.x = screenBounds.size.width * i;
        frame.origin.y = 0;
        frame.size.width = screenBounds.size.width;
        frame.size.height=self.frame.size.height;
        
        MSPageView *pageView = [[[NSBundle mainBundle] loadNibNamed:PAGE_VIEW owner:self options:nil] objectAtIndex:0];
        [pageView setFrame:CGRectMake(screenBounds.size.width * i, 0, screenBounds.size.width, self.frame.size.height)];
        [pageView.lblTest setText:dataArray[i]];
        
        [self addSubview:pageView];
    }
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    self.contentSize = contentRect.size;
}

-(void)setFrameAtPageIndex:(NSInteger)index animated:(BOOL)animated{
   
    CGRect frame;
    frame.origin.x = self.frame.size.width * index;
    frame.origin.y = 0;
    frame.size = self.frame.size;
    [self scrollRectToVisible:frame animated:animated];
    
    //If value is already selected, Ignore updating.
    if (lastPage!=index) {
        lastPage=index;
     //   NSLog(@"%ld",(long)index);
        [self.delegateCS circularScrollView:self DidSelectItemWithValue:[dataArray objectAtIndex:index]];
        [self.delegateCS circularScrollView:self DidSelectItemAtIndex:index];
    }
}

#pragma mark - Interface Action
-(void)setItems:(NSMutableArray*)array{
    originalArray=[NSMutableArray arrayWithArray:array];
    
    // Add 20 copy of items, in sequence, to the beginning and to the end.
    NSMutableArray *workingArray = [originalArray mutableCopy];
    
    //If orginal items in array is only one there is no need to scroll
    if (originalArray.count>1) {
        NSInteger orgSize=originalArray.count;
        NSInteger leftIndex = orgSize-1;
        NSInteger rightIndex = 0;
        
        for (int i=0; i<20; i++) {
            
            [workingArray insertObject:originalArray[leftIndex] atIndex:0];
            [workingArray addObject:originalArray[rightIndex]];
            
            leftIndex--;
            rightIndex++;
            
            if (leftIndex<0) {
                leftIndex=orgSize-1;
            }
            if (rightIndex>orgSize-1) {
                rightIndex= 0;
            }
        }
        // Update the collection view's data source property
        dataArray = [NSMutableArray arrayWithArray:workingArray];
        
        //Set initial scroll position
        currentPage=20;
        lastPage=20;
        
    }else{
        // Update the collection view's data source property
        dataArray = [NSMutableArray arrayWithArray:workingArray];
        
        //Set initial scroll position
        currentPage=0;
        lastPage=0;
    }
}

-(void)scrollToPageIndex:(NSInteger)index{
    
    CGRect frame;
    frame.origin.x = self.frame.size.width * index;
    frame.origin.y = 0;
    frame.size = self.frame.size;
    [self scrollRectToVisible:frame animated:YES];
    
}

-(void)resetToPageIndex:(NSInteger)index{
    
    CGRect frame;
    frame.origin.x = self.frame.size.width * index;
    frame.origin.y = 0;
    frame.size = self.frame.size;
    [self scrollRectToVisible:frame animated:NO];
    
}

#pragma mark - Scroll View Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (lastContentOffset.x > self.contentOffset.x){
        ScrollDirection = ScrollDirectionRight;
        if (didScrollReset) {
            ScrollDirection=ScrollDirectionLeft;
        }
    }else if (lastContentOffset.x < self.contentOffset.x){
        ScrollDirection = ScrollDirectionLeft;
        if (didScrollReset) {
            ScrollDirection=ScrollDirectionRight;
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    didScrollReset=NO;
    lastContentOffset=self.contentOffset;
    
    if (originalArray.count>1) {
        
        id object=[dataArray objectAtIndex:currentPage];
        NSInteger index=[originalArray indexOfObject:object];
        
        if (currentPage>=20+originalArray.count || currentPage < 20) {
            didScrollReset=YES;

            [self setFrameAtPageIndex:20+index animated:NO];
            
            //Reset circular scroll
            [self.delegateCS circularScrollView:self DidResetToIndex:20+index];
            currentPage=20+index;
            NSLog(@"reset position greater 20");
        
        }
    }

}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    NSInteger contentWidth=scrollView.contentSize.width;
    CGFloat viewWidth=contentWidth/dataArray.count;
    CGFloat currentOffsetX=scrollView.contentOffset.x;

    if (ScrollDirection==ScrollDirectionLeft) {
        currentPage=nearbyintf(currentOffsetX/viewWidth);
        
    }else if(ScrollDirection==ScrollDirectionRight){
        currentPage=nearbyintf(currentOffsetX/viewWidth);
    }
    
    [self setFrameAtPageIndex:currentPage animated:YES];
    
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
    NSInteger contentWidth=scrollView.contentSize.width;
    CGFloat viewWidth=contentWidth/dataArray.count;
    CGFloat currentOffsetX=scrollView.contentOffset.x;
    
    if (ScrollDirection==ScrollDirectionLeft) {
        currentPage=ceilf(currentOffsetX/viewWidth);
    }else if(ScrollDirection==ScrollDirectionRight){
        currentPage=floorf(currentOffsetX/viewWidth);
    }
    
    [self setFrameAtPageIndex:currentPage animated:YES];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
