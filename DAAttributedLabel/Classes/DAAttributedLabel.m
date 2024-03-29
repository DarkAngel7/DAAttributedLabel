//
//  DAAttributedLabel.m
//
//  Created by DarkAngel on 2016/12/21.
//  Copyright © 2016年 DarkAngel. All rights reserved.
//

#import "DAAttributedLabel.h"

NSString *const DASelectedLinkBackgroundColorAttributeName = @"DASelectedLinkBackgroundColorAttributeName";
NSString *const DABackgroundHeightAttributeName = @"DABackgroundHeightAttributeName";
NSString *const DABackgroundColorAttributeName = @"DABackgroundColorAttributeName";
NSString *const DABackgroundColorInsetsAttributeName = @"DABackgroundColorInsetsAttributeName";
NSString *const DABackgroundColorCornerRadiusAttributeName = @"DABackgroundColorCornerRadiusAttributeName";
NSString *const DAUnderlineSpacingAttributeName = @"DAUnderlineSpacingAttributeName";
NSString *const DAUnderlineHeightAttributeName = @"DAUnderlineHeightAttributeName";
NSString *const DAUnionTextAttributeName = @"DAUnionTextAttributeName";

static NSString *const kDAAttributedLabelRangeKey = @"kDAAttributedLabelRangeKey";

static NSString *const DALinkAttributeName = @"DALinkAttributeName";

static CGFloat const kDefaultBackgroundColorCornerRadius = 3;

@interface DAAttributedLabel () <DALayoutManagerDelegate>
/**
 TextKit三件套
 */
@property (nonatomic, strong) DALayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, strong) NSTextStorage *textStorage;
/**
 选中的range，一般用来处理链接高亮
 */
@property (nonatomic, assign) NSRange selectedRange;
/**
 长按手势
 */
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
/**
 记录点击中的link
 */
@property (nonatomic, copy) NSDictionary *activeLinkAttributes;

// State used to trag if the user has dragged during a touch
@property (nonatomic, assign) BOOL isTouchMoved;

@property (nonatomic, strong) NSMutableArray *customAttachmentViews;

@end

@implementation DAAttributedLabel

@synthesize linkTextAttributes = _linkTextAttributes;

#pragma mark - Initialize

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _shouldBreakUnionTextLine = YES;
    self.userInteractionEnabled = YES;
    self.customAttachmentViews = @[].mutableCopy;
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:self.longPressGesture];
    //配置TextKit三件套
    [self configureTextkitStack];
    //根据已有内容更新textStorage
    [self updateTextStorageWithText];
}

- (void)dealloc
{
    self.layoutManager.delegate = nil;
    self.layoutManager = nil;
    self.textContainer = nil;
    self.textStorage = nil;
    if (self.longPressGesture) {
        [self removeGestureRecognizer:self.longPressGesture];
        self.longPressGesture = nil;
    }
}

- (void)configureTextkitStack {
    
    self.textContainer = [[NSTextContainer alloc] init];
    self.textContainer.lineFragmentPadding = 0;
    self.textContainer.maximumNumberOfLines = self.numberOfLines;
    self.textContainer.lineBreakMode = self.lineBreakMode;
    self.textContainer.size = self.bounds.size;
    
    self.layoutManager = [[DALayoutManager alloc] init];
    self.layoutManager.delegate = self;
    [self.layoutManager addTextContainer:self.textContainer];
    
    self.textStorage = [[NSTextStorage alloc] init];
    [self.textStorage addLayoutManager:self.layoutManager];
}

#pragma mark - Setters and Getters

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    _displaysAsynchronously = displaysAsynchronously;
    self.layer.drawsAsynchronously = displaysAsynchronously;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    [super setNumberOfLines:numberOfLines];
    self.textContainer.maximumNumberOfLines = numberOfLines;
    [self updateTextStorageWithOriginalText];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    [super setLineBreakMode:lineBreakMode];
    self.textContainer.lineBreakMode = lineBreakMode;
    [self updateTextStorageWithOriginalText];
}

- (void)setAttributedTruncationToken:(NSAttributedString *)attributedTruncationToken
{
    _attributedTruncationToken = attributedTruncationToken.copy;
    [self updateTextStorageWithText];
}

- (void)setTruncationToken:(NSString *)truncationToken
{
    _truncationToken = truncationToken.copy;
    [self updateTextStorageWithText];
}

- (void)setAttributedSuffix:(NSAttributedString *)attributedSuffix {
    _attributedSuffix = attributedSuffix.copy;
    [self updateTextStorageWithText];
}

- (void)setSuffix:(NSString *)suffix {
    _suffix = suffix.copy;
    [self updateTextStorageWithText];
}

- (void)setShouldBreakLinkLine:(BOOL)shouldBreakLinkLine
{
    _shouldBreakLinkLine = shouldBreakLinkLine;
    [self updateTextStorageWithText];
}

- (void)setShouldBreakUnionTextLine:(BOOL)shouldBreakUnionTextLine {
    _shouldBreakUnionTextLine = shouldBreakUnionTextLine;
    [self updateTextStorageWithText];
}

- (void)setLinkTextAttributes:(NSDictionary<NSString *,id> *)linkTextAttributes
{
    _linkTextAttributes = [linkTextAttributes copy];
    [self updateTextStorageWithText];
}

- (void)setAutomaticLinkDetectionEnabled:(BOOL)automaticLinkDetectionEnabled
{
    _automaticLinkDetectionEnabled = automaticLinkDetectionEnabled;
    [self updateTextStorageWithText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    NSMutableAttributedString *mutableStr = attributedText.mutableCopy;
    NSRange range = NSMakeRange(0, mutableStr.length);
    [mutableStr enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attributes, NSRange range, BOOL * _Nonnull stop) {
        [[self attributesFromProperties] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            // 如果不包含，再添加该属性
            if (!attributes[key]) {
                [mutableStr addAttribute:key value:obj range:range];
            }
        }];
    }];
    
    [super setAttributedText:mutableStr];
    [self updateTextStorageWithOriginalText];
}

- (void)setText:(NSString *)text
{
    // Pass the text to the super class first
    [super setText:text];
    if (!text.length) {
        //此时不会调用draw text in rect
        [self clearCustomAttachmentViews];
    }
    [self updateTextStorageWithOriginalText];
}

// Applies background color to selected range. Used to highlight touched links
- (void)setSelectedRange:(NSRange)range
{
    // Remove the current selection if the selection is changing
    if (self.selectedRange.length && !NSEqualRanges(self.selectedRange, range)) {
        [self.textStorage removeAttribute:DASelectedLinkBackgroundColorAttributeName range:self.selectedRange];
    }
    // Apply the new selection to the text
    if (range.length) {
        [self.textStorage addAttribute:DASelectedLinkBackgroundColorAttributeName value:self.linkTextAttributes[DASelectedLinkBackgroundColorAttributeName] ? : [UIColor lightGrayColor] range:range];
    }
    
    // Save the new range
    _selectedRange = range;
    
    NSRange glyphRange = NSMakeRange(NSNotFound, 0);
    [self.layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    CGRect rect = [self.layoutManager usedRectForTextContainer:self.textContainer];
    CGPoint point = [self calcGlyphsPositionInView];
    rect.origin.y += point.y;
    [self setNeedsDisplayInRect:rect];
}

- (void)setCopyable:(BOOL)copyable
{
    _copyable = copyable;
    self.longPressGesture.enabled = copyable;
}

- (void)setLineSpacing:(CGFloat)lineSpacing
{
    _lineSpacing = lineSpacing;
    [self updateTextStorageWithText];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    [self.textStorage addAttribute:NSForegroundColorAttributeName
                                            value:textColor
                                            range:NSMakeRange(0, self.textStorage.length)];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self.textStorage addAttribute:NSFontAttributeName
                                            value:font
                                            range:NSMakeRange(0, self.textStorage.length)];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    [super setShadowColor:shadowColor];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = shadowColor;
    shadow.shadowOffset = self.shadowOffset;
    [self.textStorage addAttribute:NSShadowAttributeName
                                            value:shadow
                                            range:NSMakeRange(0, self.textStorage.length)];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    [super setShadowOffset:shadowOffset];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = self.shadowColor;
    shadow.shadowOffset = shadowOffset;
    [self.textStorage addAttribute:NSShadowAttributeName
                                            value:shadow
                                            range:NSMakeRange(0, self.textStorage.length)];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    NSRange fullRange = NSMakeRange(0, self.textStorage.length);
    __block NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    
    [self.textStorage enumerateAttribute:NSParagraphStyleAttributeName
                                 inRange:fullRange
                                 options:NSAttributedStringEnumerationReverse
                              usingBlock:^(NSMutableParagraphStyle *value, NSRange range, BOOL * stop) {
                                  paragraph = value;
                              }];
    paragraph.alignment = textAlignment;
    [self.textStorage addAttribute:NSParagraphStyleAttributeName
                                            value:paragraph
                                            range:fullRange];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (self.highlightedTextColor) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName
                                 value:highlighted ? self.highlightedTextColor : (self.textColor ? : [UIColor blackColor])
                                 range:NSMakeRange(0, self.textStorage.length)];
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.userInteractionEnabled = enabled;
    [self.textStorage addAttribute:NSForegroundColorAttributeName
                             value:enabled ? self.textColor : [UIColor lightGrayColor]
                             range:NSMakeRange(0, self.textStorage.length)];
}

- (NSDictionary<NSString *,id> *)linkTextAttributes
{
    if (!_linkTextAttributes) {
        _linkTextAttributes = @{NSFontAttributeName: self.font,
                                NSForegroundColorAttributeName: [UIColor blueColor],
                                DASelectedLinkBackgroundColorAttributeName: [UIColor lightGrayColor],
                                };
    }
    return _linkTextAttributes;
}

- (NSDictionary<NSString *,id> *)layoutLinkTextAttributes
{
    NSMutableDictionary *attributes = self.linkTextAttributes.mutableCopy;
    [attributes removeObjectForKey:DASelectedLinkBackgroundColorAttributeName];
    return attributes;
}

- (BOOL)isTruncated {
    //获取最后一个字形的索引
    NSInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:self.textStorage.length - 1];
    if (glyphIndex < 0) {
        return false;
    }
    
    //放不下分2种：
    //1、行末...；
    //2、有换行，比如限制2行，第三行换行了所以放不下，也没有截断。
    
    //判断是否有截断
    NSRange truncatedGlyphRange = [self.layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:glyphIndex];
    if (truncatedGlyphRange.location != NSNotFound) {
        return true;
    } else {
        //可见的字形range
        NSRange visiableGlyphRange = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
        //如果可见的字形range >= 最后一个字形 index，则表示能显示下，没有...
        if (visiableGlyphRange.length - visiableGlyphRange.location - 1 >= glyphIndex) {
            //既没有截断，也没有换行，总之能放下，所以直接返回即可
            if ([_textStorage boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width < [self.attributedText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width) {
                return true;
            }
        } else {
            return true;
        }
    }
    return false;
}

#pragma mark - Text Storage Management

- (void)updateTextStorageWithOriginalText
{
    // Now update our storage from either the attributedString or the plain text
    if (self.attributedText) {
        [self updateTextStoreWithAttributedString:self.attributedText];
    } else if (self.text) {
        [self updateTextStoreWithAttributedString:[[NSAttributedString alloc] initWithString:self.text attributes:[self attributesFromProperties]]];
    } else {
        [self updateTextStoreWithAttributedString:[[NSAttributedString alloc] initWithString:@"" attributes:[self attributesFromProperties]]];
    }
}

- (void)updateTextStorageWithText
{
    [self updateTextStorageWithOriginalText];
    [self setNeedsDisplay];
}

- (void)updateTextStoreWithAttributedString:(NSAttributedString *)attributedString
{
    if (attributedString.length) {
        attributedString = [self fixedAttributedString:attributedString];
    }
    if (self.selectedRange.location != NSNotFound) {
        self.selectedRange = NSMakeRange(0, 0);
    }
    [self.textStorage setAttributedString:attributedString];
    
    if (!self.textStorage.length) {
        return;
    }
    // 添加自定义后缀
    [self appendSuffixIfNeeded];
    //检测链接
    [self detectLinkAtCharRange:NSMakeRange(0, self.textStorage.length)];
    //更新链接属性
    [self updateLinkAttributesAtCharRange:NSMakeRange(0, self.textStorage.length)];
}

- (void)updateTextStorageWithTruncationToken
{
    if (self.lineBreakMode != NSLineBreakByTruncatingTail && self.textContainer.lineBreakMode != NSLineBreakByTruncatingTail) {
        return;
    }
    
    //计算需要替换的range
    NSUInteger truncatedLocation;
    //获取最后一个字形的索引
    NSInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:self.textStorage.length - 1];
    if (glyphIndex < 0) {
        return;
    }
    
    //放不下分2种：
    //1、行末...；
    //2、有换行，比如限制2行，第三行换行了所以放不下，也没有截断。
    
    //判断是否有截断
    NSRange truncatedGlyphRange = [self.layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:glyphIndex];
    if (truncatedGlyphRange.location != NSNotFound) {
        truncatedLocation = truncatedGlyphRange.location;
    } else {
        //可见的字形range
        NSRange visiableGlyphRange = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
        //如果可见的字形range >= 最后一个字形 index，则表示能显示下，没有...
        if (visiableGlyphRange.length - visiableGlyphRange.location - 1 >= glyphIndex) {
            //既没有截断，也没有换行，总之能放下，所以直接返回即可
            return;
        } else {
            truncatedLocation = visiableGlyphRange.length - visiableGlyphRange.location - 1;
        }
    }
    
    NSMutableAttributedString *attributedTruncationToken;
    if (!self.attributedTruncationToken.length) {
        NSDictionary *attributes = [self.textStorage attributesAtIndex:truncatedLocation effectiveRange:nil];
        NSString *truncationTokenString = self.truncationToken.length ? self.truncationToken : @"\u2026"; // Unicode Character 'HORIZONTAL ELLIPSIS' (U+2026)
        attributedTruncationToken = [[NSMutableAttributedString alloc] initWithString:truncationTokenString attributes:attributes];
    } else {
        NSMutableAttributedString *str = self.attributedText.mutableCopy;
        [str replaceCharactersInRange:NSMakeRange(0, str.length) withString:self.attributedTruncationToken.string];
        [self.attributedTruncationToken enumerateAttributesInRange:NSMakeRange(0, self.attributedTruncationToken.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            [str addAttributes:attrs range:range];
        }];
        attributedTruncationToken = [[NSMutableAttributedString alloc] initWithAttributedString:[self fixedAttributedString:str]];
    }
    // 计算 attributedTruncationToken 和 attributedSuffix 的总体大小
    BOOL hasSuffix = NO;
    NSUInteger attributedSuffixLength = self.attributedSuffix.length;
    if (attributedSuffixLength) {
        [attributedTruncationToken appendAttributedString:self.attributedSuffix];
        hasSuffix = YES;
    }
    
    CGSize size = [attributedTruncationToken boundingRectWithSize:self.textContainer.size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    CGSize wholeSize = [attributedTruncationToken boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGRect lineRect = [self.layoutManager lineFragmentRectForGlyphAtIndex:truncatedLocation effectiveRange:nil];
    CGPoint glyphPoint = CGPointZero;
    NSUInteger numberOfLines = ceil(wholeSize.width / lineRect.size.width);
    CGFloat x = wholeSize.width - numberOfLines * lineRect.size.width;
    CGFloat fixedWidth = hasSuffix ? 5 : 0;
    if (x <= 0) {
        glyphPoint.x = lineRect.origin.x - x - fixedWidth;
    } else {
        glyphPoint.x = lineRect.origin.x + lineRect.size.width - x - fixedWidth;
    }
    glyphPoint.x = MAX(0, glyphPoint.x);
    glyphPoint.y = MAX(0, lineRect.origin.y + lineRect.size.height - size.height + fixedWidth);
    
    //起点从能够放下的那个字形开始
    NSUInteger replaceStartGlyphIndex = [self.layoutManager characterIndexForPoint:glyphPoint inTextContainer:_textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    NSRange characterRange = NSMakeRange(replaceStartGlyphIndex, _textStorage.length - replaceStartGlyphIndex);
    /*
    //有问题再放开
    //判断最后一个是否是换行
    unichar lastCharacter = [self.textStorage.string characterAtIndex: [self.layoutManager characterIndexForGlyphAtIndex:replaceStartGlyphIndex]];
    //换行的话，换行也一起替换
    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
        replaceStartGlyphIndex -= 1;
    }
    */
//    NSRange characterRange = [self.layoutManager characterRangeForGlyphRange:NSMakeRange(replaceStartGlyphIndex, glyphIndex - replaceStartGlyphIndex + 1) actualGlyphRange:nil];

    
    //替换range对应的字符串为自定义的内容
    [self.textStorage replaceCharactersInRange:characterRange withAttributedString:attributedTruncationToken];
    
    //检测attributedTruncationToken的链接
    [self detectLinkAtCharRange:NSMakeRange(characterRange.location, attributedTruncationToken.length)];
    //更新链接属性
    [self updateLinkAttributesAtCharRange:NSMakeRange(characterRange.location, attributedTruncationToken.length)];
}

- (void)detectLinkAtCharRange:(NSRange)range
{
    if (!self.automaticLinkDetectionEnabled) {
        return;
    }
    static NSDataDetector *linkDetector;
    linkDetector = linkDetector ?: [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber error:NULL];
    [linkDetector enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        // Add highlight color
        if (result.URL) {
            [self.textStorage addAttributes:[self layoutLinkTextAttributes] range:result.range];
            [self.textStorage addAttribute:DALinkAttributeName value:result.URL range:result.range];
        }
        if (result.phoneNumber) {
            [self.textStorage addAttributes:[self layoutLinkTextAttributes] range:result.range];
            [self.textStorage addAttribute:DALinkAttributeName value:[NSURL URLWithString:[@"tel://" stringByAppendingString:result.phoneNumber]] range:result.range];
        }
    }];
}

- (void)updateLinkAttributesAtCharRange:(NSRange)charRange
{
    //更新链接的文本属性
    [self.textStorage enumerateAttribute:NSLinkAttributeName inRange:charRange options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value) {
            [self.textStorage removeAttribute:NSLinkAttributeName range:range];
            NSDictionary *attributes = [self.textStorage attributesAtIndex:range.location longestEffectiveRange:nil inRange:range];
            [[self layoutLinkTextAttributes] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (attributes[key] == nil) {
                    [self.textStorage addAttribute:key value:obj range:range];
                }
            }];
            [self.textStorage addAttribute:DALinkAttributeName value:value range:range];
        }
    }];
}

- (void)appendSuffixIfNeeded {
    NSAttributedString *attributedSuffix;
    // 拼接自定义suffix
    if (!self.attributedSuffix.length) {
        if (self.suffix.length) {
            NSDictionary *attributes = [self.textStorage attributesAtIndex:self.textStorage.length - 1 effectiveRange:nil];
            attributedSuffix = [[NSAttributedString alloc] initWithString:self.suffix attributes:attributes];
            _attributedSuffix = attributedSuffix;
        }
    } else {
        NSMutableAttributedString *str = self.attributedText.mutableCopy;
        [str replaceCharactersInRange:NSMakeRange(0, str.length) withString:self.attributedSuffix.string];
        [self.attributedSuffix enumerateAttributesInRange:NSMakeRange(0, self.attributedSuffix.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            [str addAttributes:attrs range:range];
        }];
        attributedSuffix = [[NSMutableAttributedString alloc] initWithAttributedString:[self fixedAttributedString:str]];
        _attributedSuffix = attributedSuffix;
    }
    if (attributedSuffix.length) {
        [self.textStorage appendAttributedString:attributedSuffix];
    }
}

#pragma mark - Text Container Managment

- (void)updateTextContainer
{
    self.textContainer.size = CGSizeMake(self.bounds.size.width, self.bounds.size.height + self.lineSpacing);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updateTextContainer];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self updateTextContainer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateTextContainer];
}

#pragma mark - Layout and Rendering

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    if (!self.text.length) {
        return [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    }
    // Use our text container to calculate the bounds required. First save our
    // current text container setup
    CGSize savedTextContainerSize = _textContainer.size;
    NSInteger savedTextContainerNumberOfLines = _textContainer.maximumNumberOfLines;
    
    // Apply the new potential bounds and number of lines
    _textContainer.size = CGSizeMake(bounds.size.width, bounds.size.height + self.lineSpacing);
    _textContainer.maximumNumberOfLines = numberOfLines;
    
    //先更新下内容，再计算。
    [self updateTextStorageWithOriginalText];
    //强制_layoutManager加载，更新布局
    [_layoutManager glyphRangeForTextContainer:_textContainer];
    // Measure the text with the new state
    CGRect textBounds = [_layoutManager usedRectForTextContainer:_textContainer];
    
    // Position the bounds and round up the size for good measure
    textBounds.origin = bounds.origin;
    textBounds.size.width = ceil(textBounds.size.width);
    textBounds.size.height = ceil(textBounds.size.height);
    textBounds.size.height -= self.lineSpacing;
    
    
    if (textBounds.size.height < bounds.size.height)
    {
        // Take verical alignment into account
        CGFloat offsetY = (bounds.size.height - textBounds.size.height) / 2.0;
        textBounds.origin.y += offsetY;
    }
    
    // Restore the old container state before we exit under any circumstances
    _textContainer.size = savedTextContainerSize;
    _textContainer.maximumNumberOfLines = savedTextContainerNumberOfLines;
    
    return textBounds;
}

- (void)drawTextInRect:(CGRect)rect
{
    [self clearCustomAttachmentViews];
    //内容为空，调用super
    if (!self.textStorage.length) {
        [super drawTextInRect:rect];
    }
    // Don't call super implementation. Might want to uncomment this out when
    // debugging layout and rendering problems.
    // [super drawTextInRect:rect];
    
    //更新TextStorage，添加自定义截断
    [self updateTextStorageWithTruncationToken];
    
    // Calculate the offset of the text in the view
    NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
    CGPoint glyphsPosition = [self calcGlyphsPositionInView];
    
    // Drawing code
    [_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:glyphsPosition];
    [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:glyphsPosition];

}

// Returns the XY offset of the range of glyphs from the view's origin
- (CGPoint)calcGlyphsPositionInView
{
    CGPoint textOffset = CGPointZero;
    
    CGRect textBounds = [_layoutManager usedRectForTextContainer:_textContainer];
    textBounds.size.width = ceil(textBounds.size.width);
    textBounds.size.height = ceil(textBounds.size.height) - self.lineSpacing;
    
    if (textBounds.size.height < self.bounds.size.height)
    {
        CGFloat paddingHeight = (self.bounds.size.height - textBounds.size.height) / 2.0;
        textOffset.y = paddingHeight;
    }
    
    return textOffset;
}

- (void)clearCustomAttachmentViews
{
    //清除所有的customAttachmentViews
    [self.customAttachmentViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.customAttachmentViews removeAllObjects];
}

#pragma mark - Interactions

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ((![self linkAtPoint:point] && ![self shouldInteractAttachmentAtPoint:point]) || !self.userInteractionEnabled || self.hidden || self.alpha < 0.01 || ![self pointInside:point withEvent:event]) {
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            if (gesture.isEnabled) {
                if ([gesture isKindOfClass:[UITapGestureRecognizer class]] || gesture == self.longPressGesture) {
                    return [super hitTest:point withEvent:event];
                }
            }
        }
        UIView *v = [super hitTest:point withEvent:event];
        if (v != self) {
            return v;
        }
        return nil;
    }
    return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    self.isTouchMoved = NO;
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    self.activeLinkAttributes = [self linkAtPoint:location];
    if (!self.activeLinkAttributes && [self shouldInteractAttachmentAtPoint:location]) {
        self.activeLinkAttributes = [self attachmentAtLocation:location];
    }
    if (!self.activeLinkAttributes) {
        [super touchesBegan:touches withEvent:event];
    } else {
        self.selectedRange = [self.activeLinkAttributes[kDAAttributedLabelRangeKey] rangeValue];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isTouchMoved = YES;
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isTouchMoved) {
        self.isTouchMoved = NO;
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        if (![self pointInside:location withEvent:nil]) {
            self.activeLinkAttributes = nil;
            [UIView transitionWithView:self duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                self.selectedRange = NSMakeRange(0, 0);
            } completion:nil];
            [super touchesEnded:touches withEvent:event];
            return;
        }
    }
    if (self.activeLinkAttributes) {
        if (self.activeLinkAttributes[DALinkAttributeName]) {
            if ([self.delegate respondsToSelector:@selector(attributedLabel:didTapLinkWithURL:)]) {
                [self.delegate attributedLabel:self didTapLinkWithURL:self.activeLinkAttributes[DALinkAttributeName]];
            }
        } else if (self.activeLinkAttributes[NSAttachmentAttributeName]) {
            if ([self.delegate respondsToSelector:@selector(attributedLabel:didTapAttachment:)]) {
                [self.delegate attributedLabel:self didTapAttachment:self.activeLinkAttributes[NSAttachmentAttributeName]];
            }
        }
        self.activeLinkAttributes = nil;
        [UIView transitionWithView:self duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.selectedRange = NSMakeRange(0, 0);
        } completion:nil];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isTouchMoved = NO;
    if (self.activeLinkAttributes) {
        self.activeLinkAttributes = nil;
        [UIView transitionWithView:self duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.selectedRange = NSMakeRange(0, 0);
        } completion:nil];
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [gesture locationInView:self];
        NSDictionary *linkAttributes = [self linkAtPoint:location];
        if (linkAttributes) {
            if (self.activeLinkAttributes[DALinkAttributeName]) {
                if ([self.delegate respondsToSelector:@selector(attributedLabel:didTapLinkWithURL:)]) {
                    [self.delegate attributedLabel:self didTapLinkWithURL:self.activeLinkAttributes[DALinkAttributeName]];
                }
            } else if (self.activeLinkAttributes[NSAttachmentAttributeName]) {
                if ([self.delegate respondsToSelector:@selector(attributedLabel:didTapAttachment:)]) {
                    [self.delegate attributedLabel:self didTapAttachment:self.activeLinkAttributes[NSAttachmentAttributeName]];
                }
            }
        } else {
            if (self.isCopyable) {
                [self showCopyMenu];
            }
        }
    }
}

- (void)showCopyMenu
{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview];
    ;
    [menu setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return action == @selector(copy:);
}

- (void)copy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:self.text];
}

- (BOOL)shouldInteractAttachmentAtPoint:(CGPoint)point
{
    NSDictionary *attachmentDict = [self attachmentAtLocation:point];
    if (!attachmentDict) {
        return false;
    }
    BOOL shouldInteractAttachment = NO;
    if (attachmentDict && [self.delegate respondsToSelector:@selector(attributedLabel:shouldInteractWithTextAttachment:)]) {
        shouldInteractAttachment = [self.delegate attributedLabel:self shouldInteractWithTextAttachment:attachmentDict[NSAttachmentAttributeName]];
    }
    return shouldInteractAttachment;
}

#pragma mark - Layout manager delegate

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldSetLineFragmentRect:(inout CGRect *)lineFragmentRect lineFragmentUsedRect:(inout CGRect *)lineFragmentUsedRect baselineOffset:(inout CGFloat *)baselineOffset inTextContainer:(NSTextContainer *)textContainer forGlyphRange:(NSRange)glyphRange {
    if (![layoutManager isKindOfClass:DALayoutManager.class]) {
        return NO;
    }
    DALayoutManager *manager = (DALayoutManager *)layoutManager;
    if (manager.minimumLineHeight == 0) {
        return NO;
    }
    CGRect rect = *lineFragmentRect;
    CGFloat fontLineHeight = rect.size.height;
    rect.size.height = MAX(manager.minimumLineHeight, rect.size.height);
    *lineFragmentRect = rect;
    
    CGRect usedRect = *lineFragmentUsedRect;
    usedRect.size.height = MAX(manager.minimumLineHeight, usedRect.size.height);
    *lineFragmentUsedRect = usedRect;
    
    CGFloat baselineNudge = (manager.minimumLineHeight - fontLineHeight) * 0.6;
    CGFloat offset = *baselineOffset + baselineNudge;
    *baselineOffset = offset;
    return YES;
}

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex
{
    if (self.shouldBreakUnionTextLine) {
        NSRange linkRange;
        NSURL *linkURL = [layoutManager.textStorage attribute:DALinkAttributeName atIndex:charIndex effectiveRange:&linkRange];
        return !self.shouldBreakLinkLine && !(linkURL && (charIndex > linkRange.location) && (charIndex <= NSMaxRange(linkRange)));
    }
    __block BOOL shouldBreak = NO;
    [layoutManager.textStorage enumerateAttribute:DAUnionTextAttributeName inRange:NSMakeRange(0, layoutManager.textStorage.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value && charIndex == range.location) {
            *stop = YES;
            shouldBreak = YES;
        }
    }];
    return shouldBreak;
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    __block NSParagraphStyle *style = nil;
    NSAttributedString *str = layoutManager.textStorage;
    if ([layoutManager.delegate isKindOfClass:UILabel.class]) {
        str = [(UILabel *)layoutManager.delegate attributedText];
    }
    if (str.length >= [layoutManager characterIndexForGlyphAtIndex:glyphIndex] + 1) {
        [str enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange([layoutManager characterIndexForGlyphAtIndex:glyphIndex], 1) options:0 usingBlock:^(NSParagraphStyle * _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            style = value;
        }];
    }
    if (style.lineSpacing > 0) {
        return style.lineSpacing;
    }
    return self.lineSpacing;
}

- (void)layoutManager:(DALayoutManager *)layoutManager drawCustomViewAttachment:(DATextAttachment *)attachment inRect:(CGRect)rect
{
    UIView *view = attachment.customView;
    if (![self.customAttachmentViews containsObject:view]) {
        view.frame = CGRectIntegral(rect);
        [self addSubview:view];
        [self.customAttachmentViews addObject:view];
    }
}

#pragma mark - Helpers

- (BOOL)isLineRectContainsPoint:(CGPoint)location characterIndex:(NSUInteger *)characterIndexPointer {
    // Do nothing if we have no text
    if (self.textStorage.string.length == 0) {
        return false;
    }
    // Work out the offset of the text in the view
    CGPoint textOffset = [self calcGlyphsPositionInView];
    // Get the touch location and use text offset to convert to text cotainer coords
    location.x -= textOffset.x;
    location.y -= textOffset.y;
    
    // Find the character that's been tapped on
    NSUInteger characterIndex;
    characterIndex = [self.layoutManager characterIndexForPoint:location
                                                inTextContainer:self.textContainer
                       fractionOfDistanceBetweenInsertionPoints:NULL];
    *characterIndexPointer = characterIndex;

    //有问题再放开
    NSUInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:characterIndex];
    CGRect lineRect = [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphIndex effectiveRange:nil];
    lineRect.size.height -= [self layoutManager:self.layoutManager lineSpacingAfterGlyphAtIndex:glyphIndex withProposedLineFragmentRect:lineRect];
    //如果不在本行，直接返回
    if (!CGRectContainsPoint(lineRect, location)) {
        return false;
    }
    if (characterIndex < self.textStorage.length) {
        return true;
    }
    return false;
}

- (nullable NSDictionary<NSAttributedStringKey, id> *)attributesAtPoint:(CGPoint)location {
    NSMutableDictionary<NSAttributedStringKey, id> *attributes = [self _attributesAtPoint:location].mutableCopy;
    if (attributes[DALinkAttributeName]) {
        attributes[NSLinkAttributeName] = attributes[DALinkAttributeName];
        [attributes removeObjectForKey:DALinkAttributeName];
    }
    return attributes;
}

- (nullable NSDictionary<NSAttributedStringKey, id> *)linkAttributesAtPoint:(CGPoint)location {
    NSMutableDictionary<NSAttributedStringKey, id> *attributes = [self _linkAttributesAtPoint:location].mutableCopy;
    if (attributes[DALinkAttributeName]) {
        attributes[NSLinkAttributeName] = attributes[DALinkAttributeName];
        [attributes removeObjectForKey:DALinkAttributeName];
    }
    return attributes;
}

- (nullable NSDictionary<NSAttributedStringKey, id> *)_attributesAtPoint:(CGPoint)location {
    NSUInteger characterIndex;
    if (![self isLineRectContainsPoint:location characterIndex:&characterIndex]) {
        return nil;
    }
    NSRange range;
    NSMutableDictionary<NSAttributedStringKey, id> *value = [self.textStorage attributesAtIndex:characterIndex longestEffectiveRange:&range inRange:NSMakeRange(0, self.textStorage.length)].mutableCopy;
    if (!value) {
        return nil;
    }
    value[kDAAttributedLabelRangeKey] = [NSValue valueWithRange:range];
    return value;
}

- (nullable NSDictionary<NSAttributedStringKey, id> *)_linkAttributesAtPoint:(CGPoint)location {
    NSUInteger characterIndex;
    if (![self isLineRectContainsPoint:location characterIndex:&characterIndex]) {
        return nil;
    }
    NSRange range;
    id value = [self.textStorage attribute:DALinkAttributeName atIndex:characterIndex longestEffectiveRange:&range inRange:NSMakeRange(0, self.textStorage.length)];
    if (!value) {
        return nil;
    }
    NSMutableDictionary<NSAttributedStringKey, id> *attributes = [[self.textStorage attributedSubstringFromRange:range] attributesAtIndex:0 effectiveRange:nil].mutableCopy;
    attributes[kDAAttributedLabelRangeKey] = [NSValue valueWithRange:range];
    return attributes;
}

- (NSDictionary *)linkAtPoint:(CGPoint)location
{
    NSDictionary<NSAttributedStringKey, id> *attributes = [self _linkAttributesAtPoint:location];
    if (attributes[DALinkAttributeName]) {
        return attributes;
    }
    return nil;
}

- (NSDictionary *)attachmentAtLocation:(CGPoint)location
{
    // Do nothing if we have no text
    if (self.textStorage.string.length == 0) {
        return nil;
    }
    // Work out the offset of the text in the view
    CGPoint textOffset = [self calcGlyphsPositionInView];
    // Get the touch location and use text offset to convert to text cotainer coords
    location.x -= textOffset.x;
    location.y -= textOffset.y;
    
    // Find the character that's been tapped on
    NSUInteger characterIndex;
    characterIndex = [self.layoutManager characterIndexForPoint:location
                                                inTextContainer:self.textContainer
                       fractionOfDistanceBetweenInsertionPoints:NULL];
    /*
     //有问题再放开
     NSUInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:characterIndex];
     CGRect lineRect = [self.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:nil];
     lineRect.size.height -= [self layoutManager:self.layoutManager lineSpacingAfterGlyphAtIndex:glyphIndex withProposedLineFragmentRect:lineRect];
     //如果不在本行，直接返回
     if (!CGRectContainsPoint(lineRect, location)) {
     return nil;
     }
     */
    
    if (characterIndex < self.textStorage.length) {
        NSRange range;
        id value = [self.textStorage attribute:NSAttachmentAttributeName atIndex:characterIndex longestEffectiveRange:&range inRange:NSMakeRange(0, self.textStorage.length)];
        if (!value) {
            return nil;
        }
        return @{NSAttachmentAttributeName: value,
                 kDAAttributedLabelRangeKey: [NSValue valueWithRange:range]
                 };
    }
    return nil;
}

- (NSAttributedString *)fixedAttributedString:(NSAttributedString *)attributedString
{
    // Setup paragraph alignement properly. IB applies the line break style
    // to the attributed string. The problem is that the text container then
    // breaks at the first line of text. If we set the line break to wrapping
    // then the text container defines the break mode and it works.
    // NOTE: This is either an Apple bug or something I've misunderstood.
    
    // Get the current paragraph style. IB only allows a single paragraph so
    // getting the style of the first char is fine.
    NSMutableAttributedString *restyled = attributedString.mutableCopy;
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id  _Nullable paragraphStyle, NSRange range, BOOL * _Nonnull stop) {
        if (paragraphStyle) {
            // Remove the line breaks
            NSMutableParagraphStyle *mutableParagraphStyle = [paragraphStyle mutableCopy];
            mutableParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            // Apply new style
            [restyled addAttribute:NSParagraphStyleAttributeName value:mutableParagraphStyle range:range];
        }
    }];
    return restyled;
}

// Returns attributed string attributes based on the text properties set on the label.
// These are styles that are only applied when NOT using the attributedText directly.
- (NSDictionary *)attributesFromProperties
{
    // Setup shadow attributes
    NSShadow *shadow = shadow = [[NSShadow alloc] init];
    if (self.shadowColor)
    {
        shadow.shadowColor = self.shadowColor;
        shadow.shadowOffset = self.shadowOffset;
    }
    else
    {
        shadow.shadowOffset = CGSizeMake(0, -1);
        shadow.shadowColor = nil;
    }
    
    // Setup color attributes
    UIColor *color = self.textColor;
    if (!self.isEnabled)
    {
        color = [UIColor lightGrayColor];
    }
    else if (self.isHighlighted)
    {
        color = self.highlightedTextColor;
    }
    
    // Setup paragraph attributes
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = self.textAlignment;
    
    // Create the dictionary
    NSDictionary *attributes = @{NSFontAttributeName : self.font ? : [UIFont systemFontOfSize:16],
                                 NSForegroundColorAttributeName : color ? : [UIColor blackColor],
                                 NSShadowAttributeName : shadow,
                                 NSParagraphStyleAttributeName : paragraph,
                                 };
    return attributes;
}

@end

/*
#pragma mark - DATextStorage

@interface DATextStorage ()

@property (nonatomic, strong) NSMutableAttributedString *backingStore;

@end

@implementation DATextStorage

- (instancetype)init {
    if (self = [super init]) {
        self.backingStore = [NSTextStorage new];
    }
    return self;
}

- (NSString *)string {
    return [self.backingStore string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location
                     effectiveRange:(NSRangePointer)range {
    return [self.backingStore attributesAtIndex:location
                                 effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    [self beginEditing];
    [self.backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters
           range:range
  changeInLength:(NSInteger)str.length - (NSInteger)range.length];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
    [self beginEditing];
    [self.backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

- (void)processEditing {
    [super processEditing];
}

- (void)fixAttributesInRange:(NSRange)range {
    [super fixAttributesInRange:range];
}

@end
 */

#pragma mark - DALayoutManager

@implementation DALayoutManager

@dynamic delegate;

- (void)setDelegate:(id<DALayoutManagerDelegate>)delegate
{
    [super setDelegate:delegate];
}

- (id<DALayoutManagerDelegate>)delegate
{
    return (id<DALayoutManagerDelegate>)[super delegate];
}

- (void)setExtraLineFragmentRect:(CGRect)fragmentRect usedRect:(CGRect)usedRect textContainer:(NSTextContainer *)container {
    fragmentRect.size.height = MAX(self.minimumLineHeight, fragmentRect.size.height);
    usedRect.size.height = MAX(self.minimumLineHeight, usedRect.size.height);
    [super setExtraLineFragmentRect:fragmentRect usedRect:usedRect textContainer:container];
}

/**
 Override
 */
- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
    if ([self.delegate respondsToSelector:@selector(layoutManager:drawCustomViewAttachment:inRect:)]) {
        NSRange characterRange = [self characterRangeForGlyphRange:glyphsToShow actualGlyphRange:nil];
        [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:characterRange options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if (value && [value isKindOfClass:[DATextAttachment class]] && range.location != NSNotFound && [(DATextAttachment *)value customView]) {
                NSRange glyphRange = [self glyphRangeForCharacterRange:range actualCharacterRange:nil];
                [self enumerateEnclosingRectsForGlyphRange:glyphRange withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0) inTextContainer:self.textContainers.firstObject usingBlock:^(CGRect rect, BOOL * _Nonnull stop) {
                    rect.origin.x += origin.x;
                    rect.origin.y += origin.y;
                    if ([self.delegate respondsToSelector:@selector(layoutManager:lineSpacingAfterGlyphAtIndex:withProposedLineFragmentRect:)]) {
                        rect.size.height -= [self.delegate layoutManager:self lineSpacingAfterGlyphAtIndex:glyphRange.location withProposedLineFragmentRect:rect];
                    }
                    CGRect boundsRect = [(DATextAttachment *)value attachmentBoundsForTextContainer:self.textContainers.firstObject proposedLineFragment:rect glyphPosition:origin characterIndex:characterRange.location];
                    rect.origin.x += boundsRect.origin.x;
                    rect.origin.y += boundsRect.origin.y;
                    [self.delegate layoutManager:self drawCustomViewAttachment:value inRect:rect];
                }];
            }
        }];
    }
}

/**
 Override
 */
- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    NSRange characterRange = [self characterRangeForGlyphRange:glyphsToShow actualGlyphRange:nil];
    //先画背景，再画选中的背景
    NSArray *attributes = @[DABackgroundColorAttributeName, DASelectedLinkBackgroundColorAttributeName];
    for (NSString *attribute in attributes) {
        [self.textStorage enumerateAttribute:attribute inRange:characterRange options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if (value && range.location != NSNotFound && [value isKindOfClass:[UIColor class]]) {
                NSRange glyphRange = [self glyphRangeForCharacterRange:range actualCharacterRange:nil];
                NSMutableArray *rects = @[].mutableCopy;
                [self enumerateEnclosingRectsForGlyphRange:glyphRange withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0) inTextContainer:self.textContainers.firstObject usingBlock:^(CGRect rect, BOOL * _Nonnull stop) {
                    __block CGRect glyphRect = rect;
                    glyphRect.origin.x += origin.x;
                    glyphRect.origin.y += origin.y;
                    [rects addObject:[NSValue valueWithCGRect:glyphRect]];
                }];
                [self fillBackgroundRectArray:rects
                            forCharacterRange:range
                                        color:value
                             rectCornerRadius:[self backgroundColorCornerRadiusForRange:range]
                                    rectInset:[self backgroundColorInsetsForRange:range]
                                   rectHeight:[self backgroundHeightForRange:range]
                ];
            }
        }];
    }
}

/**
 Override
 */
- (void)drawUnderlineForGlyphRange:(NSRange)glyphRange underlineType:(NSUnderlineStyle)underlineVal baselineOffset:(CGFloat)baselineOffset lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin {
    __block BOOL isCustomDraw = NO;
    __block CGFloat offset = 0;
    NSRange characterRange = [self characterRangeForGlyphRange:glyphRange actualGlyphRange:nil];
    [self.textStorage enumerateAttribute:DAUnderlineSpacingAttributeName inRange:characterRange options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if (value && range.location != NSNotFound && [value isKindOfClass:NSNumber.class]) {
                offset = [(NSNumber *)value floatValue];
            }
    }];
    [self.textStorage enumerateAttribute:DAUnderlineHeightAttributeName inRange:characterRange options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value && range.location != NSNotFound && [value isKindOfClass:[NSNumber class]]) {
            isCustomDraw = YES;
            CGFloat underlineHeight = [value floatValue];
            NSRange glyphRange = [self glyphRangeForCharacterRange:range actualCharacterRange:nil];
            CGFloat baselineOffset = [[self.textStorage attribute:NSBaselineOffsetAttributeName atIndex:characterRange.location effectiveRange:nil] floatValue];
            NSMutableArray *rects = @[].mutableCopy;
            [self enumerateEnclosingRectsForGlyphRange:glyphRange withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0) inTextContainer:self.textContainers.firstObject usingBlock:^(CGRect rect, BOOL * _Nonnull stop) {
                rect.origin.x += lineRect.origin.x + containerOrigin.x;
                rect.origin.y += rect.size.height - baselineOffset + offset + containerOrigin.y;
                if ([self.delegate respondsToSelector:@selector(layoutManager:lineSpacingAfterGlyphAtIndex:withProposedLineFragmentRect:)]) {
                    rect.origin.y -= [self.delegate layoutManager:self lineSpacingAfterGlyphAtIndex:characterRange.location withProposedLineFragmentRect:rect];
                }
                rect.size.height = underlineHeight;
                [rects addObject:[NSValue valueWithCGRect:rect]];
            }];
            UIColor *color = [self.textStorage attribute:NSUnderlineColorAttributeName atIndex:characterRange.location effectiveRange:nil] ? : [self.textStorage attribute:NSForegroundColorAttributeName atIndex:characterRange.location effectiveRange:nil];
            [self fillUnderlineRectArray:rects color:color];
        }
    }];
    if (!isCustomDraw) {
        [super drawUnderlineForGlyphRange:glyphRange underlineType:underlineVal baselineOffset:baselineOffset lineFragmentRect:lineRect lineFragmentGlyphRange:lineGlyphRange containerOrigin:CGPointMake(containerOrigin.x, containerOrigin.y + offset)];
    }
}

/**
 Custom draw method
 */
- (void)fillBackgroundRectArray:(NSArray *)rectArray
              forCharacterRange:(NSRange)charRange
                          color:(UIColor *)color
               rectCornerRadius:(CGFloat)cornerRadius
                      rectInset:(UIEdgeInsets)rectInset
                     rectHeight:(CGFloat)rectHeight
{
    [color set];
    CGRect rect;
    UIBezierPath *path;
    UIRectCorner roundingCorner;
    CGSize size;
    for (NSUInteger i = 0; i < rectArray.count; i++) {
        BOOL shouldAddInsetLeft = YES;
        BOOL shouldAddInsetRight = YES;
        rect = [rectArray[i] CGRectValue];
        size = CGSizeMake(cornerRadius, cornerRadius);
        if (rectArray.count == 1) {
            roundingCorner = UIRectCornerAllCorners;
        }else{
            if (i == 0) {
                roundingCorner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
                shouldAddInsetRight = NO;
            }else if(i < rectArray.count - 1){
                roundingCorner = UIRectCornerAllCorners;
                size = CGSizeZero;
                shouldAddInsetLeft = NO;
                shouldAddInsetRight = NO;
            }else{
                roundingCorner = UIRectCornerTopRight | UIRectCornerBottomRight;
                shouldAddInsetLeft = NO;
            }
        }
        if ([self.delegate respondsToSelector:@selector(layoutManager:lineSpacingAfterGlyphAtIndex:withProposedLineFragmentRect:)]) {
            rect.size.height -= [self.delegate layoutManager:self lineSpacingAfterGlyphAtIndex:charRange.location withProposedLineFragmentRect:rect];
        }
        CGFloat insetLeft = shouldAddInsetLeft ? rectInset.left : 0;
        CGFloat insetRight = shouldAddInsetRight ? rectInset.right : 0;
        rect.origin.x -= insetLeft;
        rect.origin.y -= rectInset.top;
        rect.size.width = MAX(0, rect.size.width + insetLeft + insetRight);
        rect.size.height = MAX(0, rect.size.height + rectInset.top + rectInset.bottom);
        if (rectHeight > 0) {
            if (rectHeight < rect.size.height) {
                CGFloat lastHeight = rect.size.height;
                rect.size.height = rectHeight;
                rect.origin.y += (lastHeight - rectHeight) / 2;
            }
        }
        path = [UIBezierPath bezierPathWithRoundedRect:CGRectIntegral(rect) byRoundingCorners:roundingCorner cornerRadii:size];
        [path fill];
    }
}

/**
 Custom draw method
 */
- (void)fillUnderlineRectArray:(NSArray *)rectArray color:(UIColor *)color
{
    [color set];
    CGRect rect;
    UIBezierPath *path;
    for (NSUInteger i = 0; i < rectArray.count; i++) {
        rect = [rectArray[i] CGRectValue];
        path = [UIBezierPath bezierPathWithRect:rect];
        [path fill];
    }
}

#pragma mark - Helpers

- (UIEdgeInsets)backgroundColorInsetsForRange:(NSRange)range
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    id rectInset = [self.textStorage attribute:DABackgroundColorInsetsAttributeName atIndex:range.location longestEffectiveRange:nil inRange:range];
    if (rectInset && [rectInset isKindOfClass:[NSValue class]]) {
        insets = [rectInset UIEdgeInsetsValue];
    }
    return insets;
}

- (CGFloat)backgroundColorCornerRadiusForRange:(NSRange)range
{
    CGFloat cornerRadius = kDefaultBackgroundColorCornerRadius;
    id value = [self.textStorage attribute:DABackgroundColorCornerRadiusAttributeName atIndex:range.location longestEffectiveRange:nil inRange:range];
    if (value && [value isKindOfClass:[NSValue class]]) {
#if CGFLOAT_IS_DOUBLE
        cornerRadius = [value doubleValue];
#else
        cornerRadius = [value floatValue];
#endif
    }
    return cornerRadius;
}

- (CGFloat)backgroundHeightForRange:(NSRange)range
{
    CGFloat height = 0;
    id value = [self.textStorage attribute:DABackgroundHeightAttributeName atIndex:range.location longestEffectiveRange:nil inRange:range];
    if (value && [value isKindOfClass:[NSValue class]]) {
#if CGFLOAT_IS_DOUBLE
        height = [value doubleValue];
#else
        height = [value floatValue];
#endif
    }
    return height;
}

@end

@implementation DATextAttachment

+ (DATextAttachment *)attachmentWithCustomView:(UIView *)customView viewSize:(CGSize)viewSize
{
    DATextAttachment *attachment = [[DATextAttachment alloc] initWithData:nil ofType:nil];
    attachment.customView = customView;
    attachment.viewSize = viewSize;
    return attachment;
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
{
    if (self.customView) {
        return nil;
    }
    return [super imageForBounds:imageBounds textContainer:textContainer characterIndex:charIndex];
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    CGRect rect = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    if (self.customView) {
        rect.size.height = MIN(textContainer.size.height, self.viewSize.height);
        rect.size.width = MIN(textContainer.size.width, self.viewSize.width);
    }
    rect.origin.x = 0;
    switch (self.lineAlignment) {
        case DATextAttachmentLineAlignmentTop:
            rect.origin.y = -_contentInset.top;
            break;
        case DATextAttachmentLineAlignmentMiddle:
            if (rect.size.height >= lineFrag.size.height) {
                rect.origin.y = -_contentInset.top;
            } else {
                rect.origin.y = -(lineFrag.size.height - rect.size.height) / 2;
            }
            break;
        case DATextAttachmentLineAlignmentBottom:
            if (rect.size.height >= lineFrag.size.height) {
                rect.origin.y = -_contentInset.top;
            } else {
                rect.origin.y = -(lineFrag.size.height - rect.size.height + _contentInset.bottom);
            }
            break;
        default:
            break;
    }
    return rect;
}

@end
