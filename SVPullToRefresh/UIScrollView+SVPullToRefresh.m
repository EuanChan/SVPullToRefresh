//
// UIScrollView+SVPullToRefresh.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+SVPullToRefresh.h"

//fequal() and fequalzro() from http://stackoverflow.com/a/1614761/184130
#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)


#pragma mark - UIScrollView (SVPullToRefresh)
#import <objc/runtime.h>

typedef void (^ODRefreshControlBlock)();

static char UIScrollViewRefreshControlView;
static char UIScrollViewODRefreshActionBlock;

@interface UIScrollView ()

@property (nonatomic, copy) ODRefreshControlBlock ODRefreshActionBlock;

@end

@implementation UIScrollView (SVPullToRefresh)

- (void)addRefreshControlWithActionHandler:(void (^)(void))actionHandler;
{
    if (![self respondsToSelector:@selector(refreshControl)]) {
        if (!self.refreshControlOD) {
            self.refreshControlOD = [[ODRefreshControl alloc] initInScrollView:self];
            self.ODRefreshActionBlock = actionHandler;
            [self.refreshControlOD addTarget:self action:@selector(od_refreshControlDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        }
    }
    else {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.ODRefreshActionBlock = actionHandler;
        [self.refreshControl addTarget:self action:@selector(od_refreshControlDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
#endif
#endif
    }
}

- (void)od_refreshControlDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    if (self.ODRefreshActionBlock) {
        self.ODRefreshActionBlock();

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];

            //      NSString *updated = [NSString stringWithFormat:NSLocalizedString(@"Last Updated: %@",), newLastUpdatedDate?[self.dateFormatter stringFromDate:newLastUpdatedDate]:NSLocalizedString(@"Never",)];
            //        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:updated];
    }
}

- (void)setRefreshControlOD:(id)refreshControl
{
    if (![self respondsToSelector:@selector(refreshControl)]) {
        [self willChangeValueForKey:@"RefreshControll_OD"];
        objc_setAssociatedObject(self, &UIScrollViewRefreshControlView,
                                 refreshControl,
                                 OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"RefreshControll_OD"];
    }
    else {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
        self.refreshControl = refreshControl;
#endif
#endif
    }
}

- (id)refreshControlOD
{
    if (![self respondsToSelector:@selector(refreshControl)]) {
        return objc_getAssociatedObject(self, &UIScrollViewRefreshControlView);
    }
    else {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
        return self.refreshControl;
#endif
#endif
    }
    return nil;
}

- (void)setODRefreshActionBlock:(ODRefreshControlBlock)refreshActionBlock
{
    [self willChangeValueForKey:@"RefreshControll_OD"];
    objc_setAssociatedObject(self, &UIScrollViewODRefreshActionBlock,
                             refreshActionBlock,
                             OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"RefreshControll_OD"];
}

- (ODRefreshControlBlock)ODRefreshActionBlock
{
    return objc_getAssociatedObject(self, &UIScrollViewODRefreshActionBlock);
}

@end
