//
//  WYIncomeRecordTableViewCell.h
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/28.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WYContributionInformationModel;
@interface WYIncomeRecordTableViewCell : UITableViewCell
- (void)updateCellData:(WYContributionInformationModel *)contributionInformationModel;
@end
