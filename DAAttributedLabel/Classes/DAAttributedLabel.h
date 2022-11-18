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
 @return YES or NO,如果没有实现，默认是NO
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

@class DALayoutManager;
//@class DATextStorage;
/**
 富文本label
 */
@interface DAAttributedLabel : UILabel
/**
 asynchronous display of the view's layer. default NO
 */
@property (nonatomic, assign) IBInspectable BOOL displaysAsynchronously;
/**
 clear layer'content,before asynchronously display. default YES
 */
@property (nonatomic, assign) IBInspectable BOOL clearContentBeforeAsyncDisplay;
/**
 富文本的Truncation，当显示不下的时候，默认是...，这里可以自定义该内容
 */
@property(nullable, nonatomic, copy) NSAttributedString *attributedTruncationToken;
/**
 普通字符串的Truncation，当显示不下的时候，默认是...，这里可以自定义该内容，与attributedTruncationToken互相覆盖
 */
@property(nullable, nonatomic, copy) IBInspectable NSString *truncationToken;
/// 文本是否被截断
@property (nonatomic, assign, readonly) BOOL isTruncated;
/// 自定义富文本后缀，固定显示，比如：当限制2行，此属性不为空时，永远显示此内容，会将文本内容自动truck为...
@property (nonatomic, copy, nullable) NSAttributedString *attributedSuffix;
/// 自定义后缀，与 attributedSuffix 互项覆盖
@property (nonatomic, copy, nullable) NSString *suffix;
/**
 自动检测链接等，default is NO
 */
@property (nonatomic, assign, getter = isAutomaticLinkDetectionEnabled) IBInspectable BOOL automaticLinkDetectionEnabled;
/**
 链接属性，default is @{NSFontAttributeName: self.font,
                      NSForegroundColorAttributeName: [UIColor blueColor],
                      DASelectedLinkBackgroundColorAttributeName: [UIColor lightGrayColor]}
 */
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *linkTextAttributes;
/**
 链接是否在换行时被截断。  default is NO
 */
@property (nonatomic, assign, getter=isShouldBreakLinkLine) IBInspectable BOOL shouldBreakLinkLine;
/**
 UnionText是否在换行时被截断。  default is YES
 */
@property (nonatomic, assign, getter=isShouldBreakUnionTextLine) IBInspectable BOOL shouldBreakUnionTextLine;
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
/**
 TextKit三件套
 */
@property (nonatomic, strong, readonly) DALayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;
@property (nonatomic, strong, readonly) NSTextStorage *textStorage;
/**
 选中的range，一般用来处理链接高亮
 */
@property (nonatomic, assign, readonly) NSRange selectedRange;
/**
 长按手势
 */
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGesture;

- (nullable NSDictionary<NSAttributedStringKey, id> *)attributesAtPoint:(CGPoint)location;
- (nullable NSDictionary<NSAttributedStringKey, id> *)linkAttributesAtPoint:(CGPoint)location;
- (nullable NSDictionary<NSAttributedStringKey, id> *)attachmentAtLocation:(CGPoint)location;

@end

/*
#pragma mark - DATextStorage

@interface DATextStorage: NSTextStorage

@property (nonatomic, strong, readonly) NSMutableAttributedString *backingStore;

@end
 */

#pragma mark - DALayoutManagerDelegate

@class DATextAttachment;
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

@property (nonatomic, assign) CGFloat minimumLineHeight;

@end

#pragma mark - DATextAttachment

typedef NS_ENUM(NSUInteger, DATextAttachmentLineAlignment) {
    DATextAttachmentLineAlignmentTop,
    DATextAttachmentLineAlignmentMiddle,
    DATextAttachmentLineAlignmentBottom,
};
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

@property (nonatomic, assign) DATextAttachmentLineAlignment lineAlignment;

@property (nonatomic, assign) UIEdgeInsets contentInset;
/**
 快速创建一个自定义UIView附件

 @param customView 普通的UIView
 @param viewSize View的尺寸大小
 @return DATextAttachment对象
 */
+ (DATextAttachment *)attachmentWithCustomView:(nonnull UIView *)customView viewSize:(CGSize)viewSize;

@end

///选中的链接背景色，有默认值
extern NSAttributedStringKey const DASelectedLinkBackgroundColorAttributeName NS_SWIFT_NAME(selectedLinkBackgroundColor);
///背景色高度，不包含行间距的
extern NSAttributedStringKey const DABackgroundHeightAttributeName NS_SWIFT_NAME(backgroundHeight);
///背景色属性，不包含行间距的，如果包含行间距，请使用NSBackgroudColorAttributeName
extern NSAttributedStringKey const DABackgroundColorAttributeName NS_SWIFT_NAME(backgroundNoSpacingColor);
///背景色大小inset，默认是zero
extern NSAttributedStringKey const DABackgroundColorInsetsAttributeName NS_SWIFT_NAME(backgroundColorInsets);
///背景色圆角，默认是3
extern NSAttributedStringKey const DABackgroundColorCornerRadiusAttributeName NS_SWIFT_NAME(backgroundColorCornerRadius);
///Underline Height
extern NSAttributedStringKey const DAUnderlineHeightAttributeName NS_SWIFT_NAME(underlineHeight);
///Underline Spacing
extern NSAttributedStringKey const DAUnderlineSpacingAttributeName NS_SWIFT_NAME(underlineSpacing);

extern NSAttributedStringKey const DAUnionTextAttributeName NS_SWIFT_NAME(unionText);


NS_ASSUME_NONNULL_END
