//
//  DAAttributedLabel.h
//
//  Created by DarkAngel on 2016/12/21.
//  Copyright © 2016年 DarkAngel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - DAAttributedLabelDelegate

@class DAAttributedLabel;
/**
 点击链接的协议
 */
@protocol DAAttributedLabelDelegate <NSObject>

@optional
/**
 点击了链接

 @param label label
 @param URL URL对象
 */
- (void)attributedLabel:(DAAttributedLabel *)label didTapLinkWithURL:(NSURL *)URL;
/**
 长按了链接
 
 @param label label
 @param URL URL对象
 */
- (void)attributedLabel:(DAAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)URL;
/**
 是否可以交互attachment

 @param label label
 @param attachment attachment对象
 @return YES or NO, 加入没有实现，默认是NO
 */
- (BOOL)attributedLabel:(DAAttributedLabel *)label shouldInteractWithTextAttachment:(NSTextAttachment *)attachment;
/**
 点击了Attachment
 
 @param label label
 @param attachment attachment对象，可以是NSTextAttachment的子类
 */
- (void)attributedLabel:(DAAttributedLabel *)label didTapAttachment:(NSTextAttachment *)attachment;
/**
 长按了Attachment
 
 @param label label
 @param attachment attachment对象，可以是NSTextAttachment的子类
 */
- (void)attributedLabel:(DAAttributedLabel *)label didLongPressAttachment:(NSTextAttachment *)attachment;

@end

#pragma mark - DAAttributedLabel

IB_DESIGNABLE
/**
 富文本label
 */
@interface DAAttributedLabel : UILabel
/**
 富文本的Truncation，当显示不下的时候，默认是...，这里可以自定义该内容
 */
@property(nullable, nonatomic, copy) NSAttributedString *attributedTruncationToken;
/**
 普通字符串的Truncation，当显示不下的时候，默认是...，这里可以自定义该内容，与attributedTruncationToken互相覆盖
 */
@property(nullable, nonatomic, copy) IBInspectable NSString *truncationToken;
/**
 自动检测链接等，default is NO
 */
@property (nonatomic, assign, getter = isAutomaticLinkDetectionEnabled) IBInspectable BOOL automaticLinkDetectionEnabled;
/**
 链接属性，default is @{NSFontAttributeName: self.font,
                      NSForegroundColorAttributeName: [UIColor blueColor],
                      DASelectedLinkBackgroundColorAttributeName: [UIColor lightGrayColor]}
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, id> *linkTextAttributes;
/**
 链接是否在换行时被截断。  default is NO
 */
@property (nonatomic, assign, getter=isShouldBreakLinkLine) IBInspectable BOOL shouldBreakLinkLine;
/**
 行间距，可能会与NSAttributedString的lineSpacing冲突，一般后设置的生效
 */
@property (nonatomic, assign) IBInspectable CGFloat lineSpacing;
/**
 是否可复制，default is NO
 */
@property (nonatomic, assign, getter=isCopyable) IBInspectable BOOL copyable;
/**
 代理
 */
@property (nonatomic, weak) id <DAAttributedLabelDelegate> delegate;

@end

#pragma mark - DALayoutManagerDelegate

@class DALayoutManager, DATextAttachment;
/**
 协议，在适当时候回调，画自定义的UIView附件。
 NOTE: 代理需要自行在适当的时候，移除这些UIView附件
 */
@protocol DALayoutManagerDelegate <NSLayoutManagerDelegate>
/**
 layoutManager

 @param layoutManager layoutManager
 @param attachment DATextAttachment附件
 @param rect 附件被渲染的区域
 */
- (void)layoutManager:(DALayoutManager *)layoutManager drawCustomViewAttachment:(DATextAttachment *)attachment inRect:(CGRect)rect;

@end

#pragma mark - DALayoutManager

/**
 自定义圆角backgroundColor的layoutManager
 */
@interface DALayoutManager : NSLayoutManager
/**
 代理，使用动态实现，来改变默认的代理遵循的NSLayoutManagerDelegate
 */
@property (nonatomic, weak) id<DALayoutManagerDelegate> delegate;

@end

#pragma mark - DATextAttachment

/**
 自定义的TextAttachment，使用时应避免和image或者contents和fileType同时使用，如果同时设置了，那么customView优先级高于其他，将会覆盖其他的设置
 */
@interface DATextAttachment : NSTextAttachment
/**
 可以将UIView作为自定义附件
 */
@property (nonatomic, strong, nonnull) UIView *customView;
/**
 UIView附件的大小
 */
@property (nonatomic, assign) CGSize viewSize;
/**
 快速创建一个自定义UIView附件

 @param customView 普通的UIView
 @param viewSize View的尺寸大小
 @return DATextAttachment对象
 */
+ (DATextAttachment *)attachmentWithCustomView:(nonnull UIView *)customView viewSize:(CGSize)viewSize;

@end

///选中的链接背景色，有默认值
extern NSString *const DASelectedLinkBackgroundColorAttributeName;
///背景色属性，不包含行间距的，如果包含行间距，请使用NSBackgroudColorAttributeName
extern NSString *const DABackgroundColorAttributeName;
///背景色大小inset，默认是zero
extern NSString *const DABackgroundColorInsetsAttributeName;
///背景色圆角，默认是3
extern NSString *const DABackgroundColorCornerRadiusAttributeName;

NS_ASSUME_NONNULL_END
