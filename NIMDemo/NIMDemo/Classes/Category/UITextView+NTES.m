//
//  UITextView+NTES.m
//  NIM
//
//  Created by chris on 2018/3/20.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "UITextView+NTES.h"
#import <objc/runtime.h>

@implementation UITextView (NTES)

#define UI_PLACEHOLDER_TEXT_COLOR [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0]

@dynamic placeholder;
@dynamic placeholderLabel;
@dynamic textValue;

-(void)setTextValue:(NSString *)textValue
{
    //  Change the text of our UITextView, and check whether we need to display the placeholder.
    self.text = textValue;
    [self checkIfNeedToDisplayPlaceholder];
}
-(NSString*)textValue
{
    return self.text;
}

-(void)checkIfNeedToDisplayPlaceholder
{
    //  If our UITextView is empty, display our Placeholder label (if we have one)
    if (self.placeholderLabel == nil)
        return;
    
    self.placeholderLabel.hidden = (![self.text isEqualToString:@""]);
}

-(void)onTap
{
    //  When the user taps in our UITextView, we'll see if we need to remove the placeholder text.
    [self checkIfNeedToDisplayPlaceholder];
    
    //  Make the onscreen keyboard appear.
    [self becomeFirstResponder];
}

-(void)keyPressed:(NSNotification*)notification
{
    //  The user has just typed a character in our UITextView (or pressed the delete key).
    //  Do we need to display our Placeholder label ?
    [self checkIfNeedToDisplayPlaceholder];
}

#pragma mark - Add a "placeHolder" string to the UITextView class

NSString const *kKeyPlaceHolder = @"kKeyPlaceHolder";
-(void)setPlaceholder:(NSString *)_placeholder
{
    //  Sets our "placeholder" text string, creates a new UILabel to contain it, and modifies our UITextView to cope with
    //  showing/hiding the UILabel when needed.
    objc_setAssociatedObject(self, &kKeyPlaceHolder, (id)_placeholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 0, 0)];
    self.placeholderLabel.numberOfLines = 1;
    self.placeholderLabel.text = _placeholder;
    self.placeholderLabel.textColor = UI_PLACEHOLDER_TEXT_COLOR;
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.userInteractionEnabled = true;
    self.placeholderLabel.font = self.font;
    [self addSubview:self.placeholderLabel];
    
    [self.placeholderLabel sizeToFit];
    
    //  Whenever the user taps within the UITextView, we'll give the textview the focus, and hide the placeholder if necessary.
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];
    
    //  Whenever the user types something in the UITextView, we'll see if we need to hide/show the placeholder label.
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(keyPressed:) name:UITextViewTextDidChangeNotification object:nil];
    
    [self checkIfNeedToDisplayPlaceholder];
}
-(NSString*)placeholder
{
    //  Returns our "placeholder" text string
    return objc_getAssociatedObject(self, &kKeyPlaceHolder);
}

#pragma mark - Add a "UILabel" to this UITextView class

NSString const *kKeyLabel = @"kKeyLabel";
-(void)setPlaceholderLabel:(UILabel *)placeholderLabel
{
    //  Stores our new UILabel (which contains our placeholder string)
    objc_setAssociatedObject(self, &kKeyLabel, (id)placeholderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(keyPressed:) name:UITextViewTextDidChangeNotification object:nil];
    
    [self checkIfNeedToDisplayPlaceholder];
}
-(UILabel*)placeholderLabel
{
    //  Returns our new UILabel
    return objc_getAssociatedObject(self, &kKeyLabel);
}

@end
