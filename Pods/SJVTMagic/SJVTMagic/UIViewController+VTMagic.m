//
//  UIViewController+VTMagic.m
//  SJVTMagic
//
//  Created by mac on 2020/7/3.
//  Copyright © 2020 songjiang. All rights reserved.
//

#import "UIViewController+VTMagic.h"
#import <objc/runtime.h>
#import "VTMagicView.h"

static const void *kVTReuseIdentifier = &kVTReuseIdentifier;

@implementation UIViewController (VTMagic)

#pragma mark - accessor methods
- (void)setReuseIdentifier:(NSString *)reuseIdentifier {
    objc_setAssociatedObject(self, kVTReuseIdentifier, reuseIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)reuseIdentifier {
    return objc_getAssociatedObject(self, kVTReuseIdentifier);
}

- (UIViewController<VTMagicProtocol> *)magicController {
    UIViewController *viewController = self.parentViewController;
    while (viewController) {
        if ([viewController conformsToProtocol:@protocol(VTMagicProtocol)]) break;
        viewController = viewController.parentViewController;
    }
    return (UIViewController<VTMagicProtocol> *)viewController;
}

- (NSInteger)vtm_pageIndex {
    return [self.magicController.magicView pageIndexForViewController:self];
}

@end
