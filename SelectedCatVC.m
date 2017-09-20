//
//  SelectedCatVC.m
//  Fasilite
//
//  Created by Shoaib on 9/12/17.
//  Copyright © 2017 Amaxza Digital. All rights reserved.
//

#import "SelectedCatVC.h"
#import "MSCircularCollectionView.h"
#import "MSCircularScrollView.h"

@interface SelectedCatVC () <MSCircularCollectionViewDelegate, MSCircularScrollViewDelegate>
@property (weak, nonatomic) IBOutlet MSCircularCollectionView *circularCollectionView;
@property (weak, nonatomic) IBOutlet MSCircularScrollView *circularScrollView;

@end


static NSString *CUSTOM_TITLE_VIEW = @"SCCustomNavTitleView";

@implementation SelectedCatVC
{
    NSMutableArray *originalArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    //
    UIView* customTitleView=[[[NSBundle mainBundle] loadNibNamed:CUSTOM_TITLE_VIEW owner:self options:nil] objectAtIndex:0];
    UILabel* Title=[customTitleView viewWithTag:111];
    [Title setText:@"CLOTHING"];
    UILabel* itemCount=[customTitleView viewWithTag:112];
    [itemCount setText:@"4151 Products"];
    self.navigationItem.titleView=customTitleView;

    //originalArray = [NSMutableArray arrayWithObjects:@"itemzero", @"itemOne", @"itemTwo", @"itemThree", @"itemFour", @"itemFive", nil];
    originalArray = [NSMutableArray arrayWithObjects:@"zero", @"One",@"Two", @"Three", @"Four", @"Five", @"six", @"seven", @"eight", @"nine", @"ten",@"eleven", @"tweleve", @"thirteen", @"fourteen", @"fifteen", @"sixteen", @"seventeen", @"eighteen", @"Nineteen", nil];
 
    self.circularCollectionView.delegate=self;
    [self.circularCollectionView setItems:originalArray];
    
    //
    self.circularScrollView.delegateCS=self;
    [self.circularScrollView setItems:originalArray];
}

-(void)viewDidAppear:(BOOL)animated{
   // [self.circularCollectionView reloaData];
   // [self.circularCollectionView setSelectedItem:0];
    
    [self.circularScrollView addPageViews];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MSCircularCollectionView Delegate

-(void)circularCollectionView:(MSCircularCollectionView *)CCView DidSelectItemWithValue:(NSString *)value{
    NSLog(@"%@",value);
}

-(void)circularCollectionView:(MSCircularCollectionView *)CCView DidResetToIndex:(NSInteger)index{
    [self.circularScrollView resetToPageIndex:index];
}

-(void)circularCollectionView:(MSCircularCollectionView *)CCView DidSelectItemAtIndex:(NSInteger)index{
    NSLog(@"%ld",index);
    [self.circularScrollView scrollToPageIndex:index];
}

#pragma mark - MS CircularScrollView Delegate
-(void)circularScrollView:(MSCircularScrollView *)CSView  DidSelectItemWithValue:(NSString*)value{
    NSLog(@"%@",value);
}

-(void)circularScrollView:(MSCircularScrollView *)CSView DidResetToIndex:(NSInteger)index{
    [self.circularCollectionView resetToIndex:index];
}
-(void)circularScrollView:(MSCircularScrollView *)CSView DidSelectItemAtIndex:(NSInteger)index{
    [self.circularCollectionView scrollToIndex:index];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
