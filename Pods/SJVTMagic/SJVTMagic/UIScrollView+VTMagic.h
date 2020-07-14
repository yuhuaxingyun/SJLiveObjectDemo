//
//  UIScrollView+VTMagic.h
//  SJVTMagic
//
//  Created by mac on 2020/7/3.
//  Copyright © 2020 songjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (VTMagic)

/**
*  判断指定的frame是否在当前屏幕的可视范围内
*
*  @param frame      视图的frame
*  @param preloading 是否需要预加载
*
*  @return 是否需要显示
*/
- (BOOL)vtm_isNeedDisplayWithFrame:(CGRect)frame preloading:(BOOL)preloading;
/**
 *  判断menuItem的frame是否需要显示在菜单栏上
 *
 *  @param frame item的frame
 *
 *  @return 是否需要显示在菜单栏上
 */
- (BOOL)vtm_isItemNeedDisplayWithFrame:(CGRect)frame;

@end
