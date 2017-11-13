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
        [attributedString addAttribute:DABackgroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, string.length)];
        [attributedString addAttribute:DABackgroundColorCornerRadiusAttributeName value:@3 range:NSMakeRange(0, string.length)];
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
