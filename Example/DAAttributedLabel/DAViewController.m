//
//  DAViewController.m
//  DAAttributedLabel
//
//  Created by darkangel7 on 11/13/2017.
//  Copyright (c) 2017 darkangel7. All rights reserved.
//

#import "DAViewController.h"
#import <DAAttributedLabel.h>
#import <SafariServices/SafariServices.h>

@interface DAViewController () <DAAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet DAAttributedLabel *attributedLabel;

@end

@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSMutableAttributedString *truncationToken = [[NSMutableAttributedString alloc] initWithString:@"...展开"];
    [truncationToken addAttribute:NSLinkAttributeName value:[NSURL URLWithString:@"darkangel://"] range:NSMakeRange(3, 2)];
    [truncationToken addAttribute:NSForegroundColorAttributeName value:UIColor.greenColor range:NSMakeRange(3, 2)];
    self.attributedLabel.attributedTruncationToken = truncationToken;
    self.attributedLabel.automaticLinkDetectionEnabled = YES;
    self.attributedLabel.lineSpacing = 5;
    self.attributedLabel.delegate = self;
    self.attributedLabel.displaysAsynchronously = YES;
//    NSData *data = [@"热爱综艺的医学生放弃了专业，来到日本把自己的爱好变成了工作。 她最终如愿以偿，来到了大名鼎鼎的下饭综艺《月曜》，一个专注地域黑的日本深夜搞笑节目，当AD（民工）。 \n当看综艺变成拍综艺，面临最大的问题不是这行难不难做，而是在一个行业最后都要面临的事实：\"天赋\"远远没有\"坚持\"重要，但最后发现\"能坚持\"也是\"天赋\"的一种。 \n对话参与人：\n唐一，罗二，周三，毛四（嘉宾）\n欢迎关注 主页 (https://tokyodametime.fireside.fm)、微博 (https://www.weibo.com/nottodayok/)\n或者到提问箱 (https://www.pomeet.com/dame123)与我们沟通。\n新增支持我们的小办法：购买周边 (https://item.taobao.com/item.htm?id=625989651512)\nINTRO：\nEnnio Morricone - Slalom\nPart 1  \n\"所以你们真的是，从早上等到晚，剪出来就十秒。\" \n《月曜から夜ふかし》 (https://www.ntv.co.jp/yofukashi/)（Getsuyo Kara Yofukashi）" dataUsingEncoding:NSUnicodeStringEncoding];
//    self.attributedLabel.attributedText = [[NSMutableAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
}

- (void)attributedLabel:(DAAttributedLabel *)label didTapLinkWithURL:(NSURL *)URL
{
    if ([URL.scheme isEqualToString:@"darkangel"]) {
        self.attributedLabel.numberOfLines = 0;
    } else {
        SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (IBAction)fold:(id)sender {
    self.attributedLabel.numberOfLines = 10;
}

- (IBAction)addCustomViewAttachment:(id)sender
{
    self.attributedLabel.numberOfLines = 0;
    DATextAttachment *attachment;
    static NSInteger i = 0;
    i ++;
    if (i % 2 == 0) {
        UISwitch *aSwitch = [UISwitch new];
        aSwitch.on = YES;
        attachment = [DATextAttachment attachmentWithCustomView:aSwitch viewSize:aSwitch.intrinsicContentSize];
        attachment.lineAlignment = DATextAttachmentLineAlignmentMiddle;
    } else {
        NSString *string = @"😄嘿嘿😜";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:string];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(0, string.length)];
        [attributedString addAttribute:DABackgroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, string.length)];
        [attributedString addAttribute:DABackgroundColorCornerRadiusAttributeName value:@3 range:NSMakeRange(0, string.length)];
        [attributedString addAttribute:NSBaselineOffsetAttributeName value:@10  range:NSMakeRange(0, string.length)];
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle)  range:NSMakeRange(0, string.length)];
        [attributedString addAttribute:DAUnderlineSpacingAttributeName value:@(5) range:NSMakeRange(0, string.length)];
        [attributedString addAttribute:DAUnderlineHeightAttributeName value:@(1) range:NSMakeRange(0, string.length)];
        UIEdgeInsets insets = UIEdgeInsetsMake(2, 5, 2, 5);
        [attributedString addAttribute:DABackgroundColorInsetsAttributeName value:[NSValue valueWithUIEdgeInsets:insets] range:NSMakeRange(0, string.length)];
        
        DAAttributedLabel *label = [[DAAttributedLabel alloc]init];
        label.textColor = [UIColor orangeColor];
        label.font = self.attributedLabel.font;
        label.textAlignment = NSTextAlignmentCenter;
        label.attributedText = attributedString;
        CGSize labelSize = CGSizeMake(label.intrinsicContentSize.width + insets.left + insets.right, label.intrinsicContentSize.height + insets.top + insets.bottom);
        label.frame = CGRectMake(0, 0, labelSize.width, labelSize.height);
        label.clipsToBounds = NO;
        attachment = [DATextAttachment attachmentWithCustomView:label viewSize:labelSize];
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedLabel.attributedText];
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    self.attributedLabel.attributedText = string;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
