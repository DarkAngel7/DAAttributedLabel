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
    self.attributedLabel.attributedTruncationToken = truncationToken;
    self.attributedLabel.automaticLinkDetectionEnabled = YES;
    self.attributedLabel.lineSpacing = 5;
    self.attributedLabel.delegate = self;
    self.attributedLabel.displaysAsynchronously = YES;
    NSData *data = [@"热爱综艺的医学生放弃了专业，来到日本把自己的爱好变成了工作。 她最终如愿以偿，来到了大名鼎鼎的下饭综艺《月曜》，一个专注地域黑的日本深夜搞笑节目，当AD（民工）。 \n当看综艺变成拍综艺，面临最大的问题不是这行难不难做，而是在一个行业最后都要面临的事实：\"天赋\"远远没有\"坚持\"重要，但最后发现\"能坚持\"也是\"天赋\"的一种。 \n对话参与人：\n唐一，罗二，周三，毛四（嘉宾）\n欢迎关注 主页 (https://tokyodametime.fireside.fm)、微博 (https://www.weibo.com/nottodayok/)\n或者到提问箱 (https://www.pomeet.com/dame123)与我们沟通。\n新增支持我们的小办法：购买周边 (https://item.taobao.com/item.htm?id=625989651512)\nINTRO：\nEnnio Morricone - Slalom\nPart 1  \n\"所以你们真的是，从早上等到晚，剪出来就十秒。\" \n《月曜から夜ふかし》 (https://www.ntv.co.jp/yofukashi/)（Getsuyo Kara Yofukashi），2012年开始日本电视台每周一晚上深夜11点播放的节目，在中国也赢得了很多观众。其中展现各式各样在日本社会生活的人，大胆又出其不意的环节策划，搭配 杰尼斯关8的 村上信五和 重量级男大姐 マツコ・ DELUXE  (https://ja.wikipedia.org/wiki/%E3%83%9E%E3%83%84%E3%82%B3%E3%83%BB%E3%83%87%E3%83%A9%E3%83%83%E3%82%AF%E3%82%B9)的吐槽，笑出声。 個人的ニュース（Kojinteki News），是最著名的一个节目内容，在街上抓路人聊最近人生有什么新鲜事，在涩谷取材比较多。 \n节目出现的一些综艺节目相关的术语/日语\nプロデューサー（Producer），称为P， 制片人，可以理解为算钱的，在电视台决定节目内容与方向。韩国的综艺节目中也有 PD，除了算钱还管拍摄，所以又P又D。 \n総合演出（Sougo Enshutsu），总导演。 \nチーフディレクター（Chef Director），简称チーフD。 \nディレクタ ー （Director），简称D，导演，负责具体内容呈现。 \nアシスタントディレクター（Assistant Director），简称AD，副导演，也负责端茶倒水。 \nリアクション （ Reaction ）， 综艺节目会强调观众的反应。 \nコンプライアンスチェック（ Compliance Check ），可理解为节目内容的合规审查。 \n生放送（Nama Houso），直播。 \n日本民間放送連盟 (https://j-ba.or.jp/)（Nihon Minkan Hoso Renmei），日本全国16间商业广播电视台组成，作为电视台工会保护电视台的利益。 \n日本放送協会 (https://j-ba.or.jp/)（Nihon Hoso Kyokai），又称NHK，是日本的国家公共媒体机构，成立于1925年，在日本国外也会以多种语言播出节目。 \nＢＰＯ (https://www.bpo.gr.jp/)（Broadcasting Ethics & Program Improvement Organization），日文叫放送倫理・番組向上機構，上两者合作成立的作为第三方存在的日本公共机构，审核电视节目内容，保护观众。\nＦＣＣ (https://zh.wikipedia.org/wiki/%E8%81%94%E9%82%A6%E9%80%9A%E4%BF%A1%E5%A7%94%E5%91%98%E4%BC%9A?oldformat=true)（Federal Communications Commission" dataUsingEncoding:NSUnicodeStringEncoding];
    self.attributedLabel.attributedText = [[NSMutableAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
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
        aSwitch.on = rand;
        attachment = [DATextAttachment attachmentWithCustomView:aSwitch viewSize:aSwitch.intrinsicContentSize];
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
