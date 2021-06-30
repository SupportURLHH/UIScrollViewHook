//
//  ViewController.m
//  UIScrollViewHook
//
//  Created by 范庆宇 on 2021/6/7.
//

#import "ViewController.h"
#import "UIScrollView+Category.h"
#import "UIScrollView+Swizzle.h"

@interface ViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

//@property(nonatomic,strong) UITableView *scrollView;

@property(nonatomic,strong) UIScrollView *scrollView;

@property(nonatomic,strong) UIButton *btn;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 300, 800)];
//    _scrollView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 300, 800) style:UITableViewStylePlain];
    _scrollView.backgroundColor = [UIColor lightGrayColor];
    _scrollView.contentSize = CGSizeMake(200 * 8, 10*800);
    _scrollView.delegate = self;
//    _scrollView.dataSource = self;
    
    __weak typeof(self) weakSelf = self;
    _scrollView.stopScrollBlock = ^(UIScrollView *scrollView) {
        NSLog(@"停止滑动");
        
    };
    
    _scrollView.scrollDirectionBlock = ^(Direction direction, CGPoint contentOffset) {
        
        if (contentOffset.y > 200) {
            [weakSelf.btn setHidden:NO];
            
        }else {
            [weakSelf.btn setHidden:YES];
        }
        
//        if (direction == UP) { // 手势向上
//            NSLog(@"向下滚动");
//            [weakSelf.btn setHidden:YES];
//
//        }else if (direction == DOWN) { // 手势向下
//            NSLog(@"向上滚动");
//
//        }
        
    };
    [self.view addSubview:_scrollView];
    
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btn setHidden:YES];
    _btn.backgroundColor = [UIColor redColor];
    _btn.frame = CGRectMake(230, 700, 40, 40);
    [_btn addTarget:self action:@selector(scrollTop) forControlEvents:UIControlEventAllTouchEvents];
    [self.view addSubview:_btn];

}

- (void)scrollTop {
    [_scrollView custom_scrollToTop];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = @"text";
    return cell;
    
}

@end
