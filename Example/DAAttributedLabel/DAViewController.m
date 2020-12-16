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
//    NSData *data = [@"热爱综艺的医学生放弃了专业，来到日本把自己的爱好变成了工作。 她最终如愿以偿，来到了大名鼎鼎的下饭综艺《月曜》，一个专注地域黑的日本深夜搞笑节目，当AD（民工）。 \n当看综艺变成拍综艺，面临最大的问题不是这行难不难做，而是在一个行业最后都要面临的事实：\"天赋\"远远没有\"坚持\"重要，但最后发现\"能坚持\"也是\"天赋\"的一种。 \n对话参与人：\n唐一，罗二，周三，毛四（嘉宾）\n欢迎关注 主页 (https://tokyodametime.fireside.fm)、微博 (https://www.weibo.com/nottodayok/)\n或者到提问箱 (https://www.pomeet.com/dame123)与我们沟通。\n新增支持我们的小办法：购买周边 (https://item.taobao.com/item.htm?id=625989651512)\nINTRO：\nEnnio Morricone - Slalom\nPart 1  \n\"所以你们真的是，从早上等到晚，剪出来就十秒。\" \n《月曜から夜ふかし》 (https://www.ntv.co.jp/yofukashi/)（Getsuyo Kara Yofukashi），2012年开始日本电视台每周一晚上深夜11点播放的节目，在中国也赢得了很多观众。其中展现各式各样在日本社会生活的人，大胆又出其不意的环节策划，搭配 杰尼斯关8的 村上信五和 重量级男大姐 マツコ・ DELUXE  (https://ja.wikipedia.org/wiki/%E3%83%9E%E3%83%84%E3%82%B3%E3%83%BB%E3%83%87%E3%83%A9%E3%83%83%E3%82%AF%E3%82%B9)的吐槽，笑出声。 個人的ニュース（Kojinteki News），是最著名的一个节目内容，在街上抓路人聊最近人生有什么新鲜事，在涩谷取材比较多。 \n节目出现的一些综艺节目相关的术语/日语\nプロデューサー（Producer），称为P， 制片人，可以理解为算钱的，在电视台决定节目内容与方向。韩国的综艺节目中也有 PD，除了算钱还管拍摄，所以又P又D。 \n総合演出（Sougo Enshutsu），总导演。 \nチーフディレクター（Chef Director），简称チーフD。 \nディレクタ ー （Director），简称D，导演，负责具体内容呈现。 \nアシスタントディレクター（Assistant Director），简称AD，副导演，也负责端茶倒水。 \nリアクション （ Reaction ）， 综艺节目会强调观众的反应。 \nコンプライアンスチェック（ Compliance Check ），可理解为节目内容的合规审查。 \n生放送（Nama Houso），直播。 \n日本民間放送連盟 (https://j-ba.or.jp/)（Nihon Minkan Hoso Renmei），日本全国16间商业广播电视台组成，作为电视台工会保护电视台的利益。 \n日本放送協会 (https://j-ba.or.jp/)（Nihon Hoso Kyokai），又称NHK，是日本的国家公共媒体机构，成立于1925年，在日本国外也会以多种语言播出节目。 \nＢＰＯ (https://www.bpo.gr.jp/)（Broadcasting Ethics & Program Improvement Organization），日文叫放送倫理・番組向上機構，上两者合作成立的作为第三方存在的日本公共机构，审核电视节目内容，保护观众。\nＦＣＣ (https://zh.wikipedia.org/wiki/%E8%81%94%E9%82%A6%E9%80%9A%E4%BF%A1%E5%A7%94%E5%91%98%E4%BC%9A?oldformat=true)（Federal Communications Commission），联邦通信委员会，负责规定所有的非联邦政府机构的无线电和电视广播使用，委员会也是影响美国通信政策的一个重要因素。\n 培養効果  (https://ja.wikipedia.org/wiki/%E3%83%A1%E3%83%87%E3%82%A3%E3%82%A2%E5%8A%B9%E6%9E%9C%E8%AB%96#:~:text=%E4%B8%BB%E3%81%AB%E3%83%86%E3%83%AC%E3%83%93%E3%81%AE%E5%BD%B1%E9%9F%BF,%E7%A0%94%E7%A9%B6%E3%81%8C%E3%81%99%E3%81%99%E3%82%81%E3%82%89%E3%82%8C%E3%81%9F%E3%80%82)（Baiyo Kouka），中文叫涵化理论，George Gerbner 等20世纪70年代提出，研究电视对于受众的长期影响。当时他们选取美国的地区作为样本，得出看电视时间越长，受众对于现实的看法就会越容易受到电视上内容的影响。  \n录音中提到了几期《月曜》\n2020年2月17日播出，因外国游客太多，滑雪胜地北海道的物价被抬得很高，日本人开始不去北海道了。节目组便找到下一个滑雪潮流所在地：长野 白马 ，直击心灵地问了去滑雪外国人的年收（支付宝也因此出镜）。 \n2019年10月28日播出， 去日本各地调查当地的有名人排行，其中包括山梨县 。 调查 山梨县的时候当地人都说 最有名的是武田信玄 （Takeda Shingen） ，一个战国时代的武将。 节目一般会靠吐槽当地没什么名人来挑事儿。 \nフェフ姉（ Fefu Ne)，中文观众称她\"音乐结姐姐\"，2016年被月曜节目组从路边挖掘，因她口吃发不出音乐节Fesu的音 而发成了Fefu ，但性格开朗，很有综艺效果。后来在月曜有了自己的专栏，成了电视名人 。 \n和其它几个日本综艺：\n恋愛番組《テラスハウス》《バチェラー》\n《ポツンと一軒家》 (https://www.asahi.co.jp/potsunto/)（Potsun To Ikkenya），朝日电视台周末综艺，打开谷歌地图，哪儿有独立的房子就去哪儿。借一栋房子看见整个日本社会的生态、人情，常青节目。 \nクイズ番組《林先生が驚く初耳学!》  (https://ja.wikipedia.org/wiki/%E6%9E%97%E5%85%88%E7%94%9F%E3%81%8C%E9%A9%9A%E3%81%8F%E5%88%9D%E8%80%B3%E5%AD%A6!)（ Hayashi Sensei Ga odoroku Hatsumimi-Gaku!），猜谜节目，林修看了VTR之后，按下第一次听到/知道的键，然后讲解。\n《マツコの知らない世界》 (https://www.tbs.co.jp/matsuko-sekai/)（Matsuko No Shiranai Sekai），主持月曜的松子主持的另一档有意思的节目。介绍各种不知道的世界，比如榻榻米的世界、键盘的世界、乌冬的世界。 \n《水曜日のダウンタウン》 (https://www.tbs.co.jp/suiyobinodowntown/)（Suiyobi no Dauntaun），每期验证不同的奇葩想法，一个烟民为了抽一口烟，如果故意把吸烟区设置在山上的话，他会不会爬山，也验证过宇多田光的歌的尾音每个人发得是不是一样的，搞笑艺人也很好笑。 \n《マツコ会議》 (https://www.ntv.co.jp/matsukokaigi/)（Matsuko Kaigi），找日本当地新奇话题就地取材，做过选题类似最近花60万日元可以把头发变柔顺的美发店，东京站有什么可以化妆的地方等内容。 \nPart 2 \n\"韩国每次都在不断地挑战，非常极端\" \n罗pd全名罗英锡，为韩国著名综艺节目导演，节目收视率的保证。 节目中提到罗pd的代表综艺： \n《花样爷爷》 (https://zh.wikipedia.org/wiki/%E8%8A%B1%E6%A8%A3%E7%88%BA%E7%88%BA)，有着五十年演艺生涯的韩国老演员们出国背包旅行。国内由东方卫视引进。 \n《三时三餐》 (https://zh.wikipedia.org/wiki/%E4%B8%80%E6%97%A5%E4%B8%89%E9%A4%90)，把演艺界人士带到远离都市的地方做饭的节目，温情、好看，芒果台有类似的《向往的生活》。其中第二季在韩国旌善拍摄的部分中，出现了这么一段字幕：\"也许我们都比想象中孤独，也因此，我们能和一些人一起吃一顿饭，会变得更加困难，但是反而说不定，也会更加恳切。\" \n《麻浦靓仔》 (https://zh.wikipedia.org/wiki/%E9%BA%BB%E6%B5%A6%E5%B8%A5%E5%B0%8F%E4%BC%99)，自称不懂时尚的罗pd ，拍出了让人感慨时尚也这么动人的综艺。以每期5分钟的“特别形式”编成，完整版也只有10多分钟。颠覆传统综艺形式。 \n《新西游记》 (https://zh.wikipedia.org/zh/%E6%96%B0%E8%A5%BF%E9%81%8A%E8%A8%98)，以西游记和龙珠为设定的旅游节目。嘉宾化学反应过好，爆红。前三季都在中国拍的。 \n《尹食堂》 (https://zh.wikipedia.org/wiki/%E5%B0%B9%E9%A3%9F%E5%A0%82)，韩国艺人尹汝贞为中心去外地运营韩餐厅，比起怎么经营，反而更多的看到了认真、勤劳的人如何赢得陌生人的敬意。芒果台有类似的 《中餐厅》。 \n《小巷餐厅》 (https://zh.wikipedia.org/wiki/%E7%99%BD%E7%A8%AE%E5%85%83%E7%9A%84%E8%83%A1%E5%90%8C%E9%A4%90%E9%A4%A8)，拯救小街区餐厅韩国节目，大名鼎鼎的厨师白钟元出手，切合韩国社会生态。 \n《拉面男》 (https://zh.wikipedia.org/wiki/%E7%85%AE%E6%B3%A1%E9%BA%B5%E7%9A%84%E7%94%B7%E4%BA%BA)，韩国艺人姜虎东去各个地方煮拉面的节目，也是每期6分钟，网络看10多分钟完整版。 \n 《 爸爸去哪儿 》  (https://zh.wikipedia.org/wiki/%E7%88%B8%E7%88%B8%E5%8E%BB%E5%93%AA%E5%85%92)，真人秀节目，原版来自韩国MBC电视台， 被芒果台引进。 \nPart3  \n\"我有时候会想，做综艺这么累，真的值得吗？\"  \n《街头美食斗士》 (https://zh.wikipedia.org/wiki/%E8%A1%97%E9%A0%AD%E7%BE%8E%E9%A3%9F%E9%AC%A5%E5%A3%AB)，韩国综艺节目，白钟元主持，寻找藏在世界各地的街头美食，只言片语里带出丰富的美食信息，却丝毫不说教，字幕克制。会有看了节目不想立刻到处吃吃吃的人吗？节目还透过美食拍出了文化。\n《Ugly Delicious》 (https://www.netflix.com/title/80170368)，Netflix 出品的纪录片， 可以说是真正舌尖上的美国，讲述了 烹饪 和移民文化是如何融合并成为当下美国的最佳注解 。 \n《Somebody Feed Phil》 (https://www.netflix.com/title/80146601)，又一部Netflix 出品的纪录片，到处吃美食。 \n《海王》 (https://movie.douban.com/subject/3878007/)，技术型导演温子仁的电影。海王是可以和海洋生物交流的超级英雄。大型海底捞现场。 \n《卡路里》 (https://weibo.com/2609084213/J9wp2C99K)， 上海彩虹室内合唱团 （主理人金承志） 在综艺节目《炙热的我们》中，改编了火箭少女的《卡路里》，唱哭了火箭少女。 \n《Panda Kill》 (https://zh.wikipedia.org/wiki/Panda_Kill)，线上狼人杀竞技综艺节目，有很厉害的嘉宾，全是黑话，不懂的话会看得满头问号。但有时候一期5个小时，相当耐看。 \n\"讨论了半天《月曜》，发现这就是一个豪华制作的民生新闻节目《1818黄金眼》\" \n* 《1818黄金眼》 (https://baike.baidu.com/item/1818%E9%BB%84%E9%87%91%E7%9C%BC)，浙江广播电视集团民生休闲频道推出的民生新闻节目 。 \n* 《谭谈交通》 (https://baike.baidu.com/item/%E8%B0%AD%E8%B0%88%E4%BA%A4%E9%80%9A)， 成都本土一档寓教于乐的交通警示类节目。交警上路抓违章，民生类新闻，好笑到出圈。 \n倾情安利：身在做民生新闻，但一心立志做美食节目的毛4推荐的美食综艺： \n《阿贤逛巴剎》 (https://movie.douban.com/subject/33446337/)，主持人功力+语言+知识背景=一档非常好的美食节目。 \n《雷蒙德·布兰克的厨房秘密》 (https://movie.douban.com/subject/5300049/)，法国乡下米其林餐厅，做有很多细节的法餐的节目。可以学到大量的料理知识，也有人性美。 \n《SMAPXSMAP》 (https://movie.douban.com/subject/1763308/)，美食节目无疑，而且是日本最贵的美食节目，鼎盛时期的富士台做的策划不可小觑。 \nUntitled https://files.fireside.fm/file/fireside-uploads/images/c/c04ddbe1-6019-4df9-8194-708045543fb5/9s3QIGEP.jpg" dataUsingEncoding:NSUnicodeStringEncoding];
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
