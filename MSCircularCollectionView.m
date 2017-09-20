//
//  MSCircularCollectionView.m
//  Fasilite
//
//  Created by Shoaib on 9/14/17.
//  Copyright © 2017 Amaxza Digital. All rights reserved.
//

#import "MSCircularCollectionView.h"

typedef NS_ENUM(NSInteger, ScrollDirection) {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
};

@interface MSCircularCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray* dataArray;
@property (nonatomic, assign) CGFloat lastContentOffset;

@end

//CellIdentifier
//ItemTags

@implementation MSCircularCollectionView
{
    ScrollDirection scrollDirection;
    
    NSTimer* timerSetScroll;

    NSIndexPath* lastItemPath;

    NSMutableArray *originalArray;
    NSInteger dataArraySelectedIndex;
    
    BOOL didSetup;
    
    BOOL isUserDragging;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [super awakeFromNib];
    
    UICollectionViewFlowLayout* layout=[[UICollectionViewFlowLayout alloc] init];
    //layout.itemSize = CGSizeMake(100, 20);
    
    layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize;
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView setContentInset:UIEdgeInsetsMake(-12, 0, 0, 0)];
    
    
    //Add observer
    [self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
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
        self.dataArray = [NSMutableArray arrayWithArray:workingArray];

        //Set initial scroll position
        dataArraySelectedIndex=20;
        
    }else{
        // Update the collection view's data source property
        self.dataArray = [NSMutableArray arrayWithArray:workingArray];
        
        //Set initial scroll position
        dataArraySelectedIndex=0;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context{
    // You will get here when the first time reloadData finished
    
    if (self.collectionView.visibleCells.count>0) {
        
        NSIndexPath *xpathSelectedItem=[NSIndexPath indexPathForRow:dataArraySelectedIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:xpathSelectedItem atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        [self setItemSelectedAtIndexPath:xpathSelectedItem];
        lastItemPath=[NSIndexPath indexPathForRow:dataArraySelectedIndex inSection:0];
    }
}

- (void)dealloc{
    @try {
        [self.collectionView removeObserver:self forKeyPath:@"contentSize" context:NULL];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)scrollToIndex:(NSInteger)index{
    
    NSIndexPath *xpathSelectedItem;
    xpathSelectedItem=[NSIndexPath indexPathForRow:index inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:xpathSelectedItem atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
    [self setItemUnselectedAtIndexPath:lastItemPath];
    [self setItemSelectedAtIndexPath:xpathSelectedItem];
    lastItemPath=[NSIndexPath indexPathForRow:index inSection:0];
}

-(void)resetToIndex:(NSInteger)index{
    
    NSIndexPath *xpathSelectedItem;
    xpathSelectedItem=[NSIndexPath indexPathForRow:index inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:xpathSelectedItem atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    
    //[NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        //Run this specially in timer because cell takes time to create before setting views selected
        [self setItemUnselectedAtIndexPath:lastItemPath];
        [self setItemSelectedAtIndexPath:xpathSelectedItem];
        lastItemPath=[NSIndexPath indexPathForRow:index inSection:0];
    
    //[self setItemsUnselected:self.collectionView.visibleCells];
        //[self setItemSelectedAtIndexPath:[NSIndexPath indexPathForRow:dataArraySelectedIndex inSection:0]];
        //lastItemPath=[NSIndexPath indexPathForRow:index inSection:0];
        
   // }];
}

-(void)reloaData{
    [self.collectionView reloadData];
}


#pragma mark - ScrollViewDelegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.lastContentOffset > scrollView.contentOffset.x) {
        scrollDirection = ScrollDirectionRight;
    } else if (self.lastContentOffset < scrollView.contentOffset.x) {
        scrollDirection = ScrollDirectionLeft;
    }
    self.lastContentOffset = scrollView.contentOffset.x;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    @try {
        [self.collectionView removeObserver:self forKeyPath:@"contentSize" context:NULL];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    isUserDragging=YES;
    if (originalArray.count>1) {
        
        id object=[self.dataArray objectAtIndex:dataArraySelectedIndex];
        NSInteger index=[originalArray indexOfObject:object];
        
        if (dataArraySelectedIndex>=20+originalArray.count || dataArraySelectedIndex < 20) {
            NSIndexPath *xpathSelectedItem=[NSIndexPath indexPathForRow:(20+index) inSection:0];
            
            [self setItemUnselectedAtIndexPath:lastItemPath];
            [self setItemSelectedAtIndexPath:xpathSelectedItem];
            
            [self.collectionView scrollToItemAtIndexPath:xpathSelectedItem atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            
            //Reset circular scroll
            [self.delegate circularCollectionView:self DidResetToIndex:dataArraySelectedIndex];
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //[timerSetScroll invalidate];
    //timerSetScroll=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setScrollView) userInfo:nil repeats:NO];
    [self setScrollView];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
   // [timerSetScroll invalidate];
   // timerSetScroll=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setScrollView) userInfo:nil repeats:NO];
    [self setScrollView];
}



#pragma mark - Self Action
-(void)setScrollView{
    
    NSArray *visibleRows = [self.collectionView visibleCells];
    NSIndexPath* firstItemPath;
    
    switch (scrollDirection) {
        case ScrollDirectionLeft:
        {
            firstItemPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(self.collectionView.contentOffset.x+self.collectionView.frame.size.width/visibleRows.count, 15)];
        }
            break;
        case ScrollDirectionRight:
        {
            firstItemPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(self.collectionView.contentOffset.x+self.collectionView.frame.size.width*0.05, 15)];
        }
            break;
        default:
            break;
    }
    
    [self.collectionView scrollToItemAtIndexPath:firstItemPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
    if (lastItemPath.row!=firstItemPath.row) {
        
        [self.delegate circularCollectionView:self DidSelectItemWithValue:self.dataArray[firstItemPath.row]];
        [self.delegate circularCollectionView:self DidSelectItemAtIndex:firstItemPath.row];
        [self setItemUnselectedAtIndexPath:lastItemPath];
        [self setItemSelectedAtIndexPath:firstItemPath];
        lastItemPath=[NSIndexPath indexPathForRow:firstItemPath.row inSection:0];
    }
}


-(void)setItemSelectedAtIndexPath:(NSIndexPath*)indexPath{
    NSLog(@"Selected Item %ld",(long)indexPath.row);

    dataArraySelectedIndex=indexPath.row;

    UICollectionViewCell* cell=[self.collectionView cellForItemAtIndexPath:indexPath];
    UIView* view=[cell.contentView viewWithTag:171];
    [view setHidden:NO];
    UILabel* label=[cell.contentView viewWithTag:111];
    [label setTextColor:[UIColor redColor]];
    
    NSLog(@"%@",label.text);
    
    if (!view) {
        isUserDragging=NO;
        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
            if (!isUserDragging) {
                
                UICollectionViewCell* cell=[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:dataArraySelectedIndex inSection:0]];
                UIView* view=[cell.contentView viewWithTag:171];
                [view setHidden:NO];
                UILabel* label=[cell.contentView viewWithTag:111];
                [label setTextColor:[UIColor redColor]];
                
                NSLog(@"%@",label.text);
            }
        }];
    }
}

-(void)setItemUnselectedAtIndexPath:(NSIndexPath*)indexPath{
    NSLog(@"Last Item %ld",(long)indexPath.row);
    /*if (indexPath.row==dataArraySelectedIndex) {
        return;
    }*/
    UICollectionViewCell* cell=[self.collectionView cellForItemAtIndexPath:indexPath];
    UIView* view=[cell.contentView viewWithTag:171];
    [view setHidden:YES];
    UILabel* label=[cell.contentView viewWithTag:111];
    [label setTextColor:[UIColor darkGrayColor]];
}

-(void)setItemsUnselected:(NSArray*)visibleRows{
    
    for (UICollectionViewCell *cell in visibleRows) {
        NSIndexPath* indexPath=[self.collectionView indexPathForCell:cell];
        UICollectionViewCell* cell=[self.collectionView cellForItemAtIndexPath:indexPath];
        UIView* view=[cell.contentView viewWithTag:171];
        [view setHidden:YES];
        UILabel* label=[cell.contentView viewWithTag:111];
        [label setTextColor:[UIColor darkGrayColor]];
    }
}


#pragma mark - CollectionView Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Did Tap %ld",indexPath.row);
}

#pragma mark - CollectionView DataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"CELLONE" forIndexPath:indexPath];
    
    UIView* view=[cell.contentView viewWithTag:171];
    [view setHidden:YES];
    
    UILabel *label = [cell.contentView viewWithTag:111];
    [label setTextColor:[UIColor darkGrayColor]];
    
    [label setText:self.dataArray[indexPath.row]];
    
    return cell;
}


@end
