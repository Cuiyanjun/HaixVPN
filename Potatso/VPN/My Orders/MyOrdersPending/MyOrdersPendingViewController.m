//
//  MyOrdersAllViewController.m
//  Potatso
//
//  Created by txb on 2017/10/13.
//  Copyright © 2017年 TouchingApp. All rights reserved.
//

#import "MyOrdersPendingViewController.h"
#import "MyOrderPendTableViewCell.h"
#import "DetailOrderViewController.h"
#import "MyOrdersViewController.h"
@interface MyOrdersPendingViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation MyOrdersPendingViewController
{
    UITableView *tabelviewALL;
    NSMutableArray *OrderListDic;
    UIImageView *NullimageALL;
    UILabel *NulllabeALL;
    UIView *viewback;
}
- (instancetype)init
{
    if (self = [super init]) {
        
        [self viewLoad];
    }
    return self;
}

- (void)viewLoad {
    self.backgroundColor = ViewBackColor;
    
    //Package套餐
    tabelviewALL  = [[UITableView alloc]initWithFrame:CGRectMake(20,0, kscreenw - 40,kscreenh - 130)];
    tabelviewALL.delegate =self;
    tabelviewALL.dataSource = self;
    tabelviewALL.backgroundColor = ViewBackColor;
    [self addSubview:tabelviewALL];
    tabelviewALL.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setExtraCellLineHidden:tabelviewALL];
    
    //获取订单列表
    [NetworkApi Getorderlist:nil anddic:nil block:^(NSDictionary *responseObject) {
        OrderListDic = [[NSMutableArray alloc]init];
        for (NSDictionary * dic in responseObject[@"data"][@"orders"]) {
            if ([dic[@"status"] intValue] == 1) {
                [OrderListDic addObject:dic];
            }
        }
        [tabelviewALL reloadData];
    } block:^(NSError *error) {
        [AppEnvironment ShowErrorLoading:error];
    }];
    
    //背景
    viewback = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kscreenw, kscreenh)];
    viewback.backgroundColor = ViewBackColor;
    [self addSubview:viewback];
    
    NullimageALL = [[UIImageView alloc] initWithFrame:CGRectMake(138 *SJwidth, 208 *SJhight - 64, 100, 162)];
    NullimageALL.image = [UIImage imageNamed:@"bottle"];
    [viewback addSubview:NullimageALL];
    
    NulllabeALL = [[UILabel alloc] initWithFrame:CGRectMake(0, NullimageALL.frame.origin.y + NullimageALL.frame.size.height + 30, kscreenw, 30)];
    NulllabeALL.text = @"You don’t have any orders yet.";
    NulllabeALL.textAlignment = 1;
    NulllabeALL.textColor = [UIColor colorWithRed:0.5 green:0.55 blue:0.65 alpha:1];
    NulllabeALL.font = [UIFont fontWithName:@"SourceSansPro-bold" size:14];
    [viewback addSubview:NulllabeALL];
    
    // Do any additional setup after loading the view.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [OrderListDic count];
}

-(void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


//分区之间的颜色
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = ViewBackColor;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;//分区之间的距离
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0) {
        //获取订单详情
        [LCProgressHUD showLoading:nil];
        [NetworkApi Getorderinfo: [NSString stringWithFormat:@"%@",OrderListDic[indexPath.section][@"_id"]] anddic:nil block:^(NSDictionary *responseObject) {
            [LCProgressHUD hide];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"pushtoMYorderdetail" object:responseObject];
            
        } block:^(NSError *error) {
            [AppEnvironment ShowErrorLoading:error];
        }];
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = indexPath.section;
    static NSString *identifier = @"CellPending";
    
    MyOrderPendTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[MyOrderPendTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }

    [cell.labelCompleted setTitle:@"" forState:0];
    [cell.labelCompleted setImage:[UIImage imageNamed:@"订单"] forState:0];
    
    //订单Pending
    if ([OrderListDic[row][@"status"] intValue] == 1) {
        
        NullimageALL.hidden = YES;
        viewback.hidden = YES;
        NulllabeALL.hidden = YES;
        
        [cell.labelCompleted setTitle:@"    Pending" forState:0];
        [cell.labelCompleted setTitleColor:[UIColor colorWithRed:1 green:0.48 blue:0.52 alpha:1] forState:0];
        [cell.labelCompleted setImage:[UIImage imageNamed:@"OrderPending"] forState:0];
        
        cell.labeldevices.text = OrderListDic[row][@"planName"];
        cell.labelExpires.text = [AppEnvironment UTCchangeDate:OrderListDic[row][@"createDateUnixTimestamp"]];
        cell.labelmoney.text = [NSString stringWithFormat:@"$ %@",OrderListDic[row][@"total"]];
    }

    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 4;
    cell.accessoryType=UITableViewCellAccessoryNone;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//设置cell点击效果（无显示）
    return cell;
}




@end
