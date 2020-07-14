//
//  SJFilterView.h
//  SJLiveObjectTest
//
//  Created by mac on 2020/7/13.
//  Copyright © 2020 songjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJFilterView : UIView

@property (nonatomic, copy)void(^selectBlock)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
