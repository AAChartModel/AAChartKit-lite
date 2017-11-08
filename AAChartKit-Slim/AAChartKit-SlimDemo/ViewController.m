//
//  ViewController.m
//  AAChartKit-Slim
//
//  Created by Danny boy on 2017/5/16.
//  Copyright © 2017年 Danny boy. All rights reserved.
//

#import "ViewController.h"
#import "AAchartView.h"
#import "AAJsonConverter.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    
    // Drawing code
    AAChartModel *chartModel = [[AAChartModel alloc]init];
    NSString *jsonString = [AAJsonConverter getPureOptionsString:chartModel];
    
}




@end
