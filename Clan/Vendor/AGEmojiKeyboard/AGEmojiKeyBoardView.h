//
//  AGEmojiKeyboardView.h
//  AGEmojiKeyboard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//
// Set as inputView to textfields, this view class gives an
// interface to the user to enter emoji characters.

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AGEmojiKeyboardViewCategoryImage) {
    AGEmojiKeyboardViewCategoryImageEmoji,
    AGEmojiKeyboardViewCategoryImageMonkey,
};

@protocol AGEmojiKeyboardViewDelegate;
@protocol AGEmojiKeyboardViewDataSource;

/**
 Keyboard class to present as an alternate.
 This keyboard presents the emojis supported by iOS.
 */
@class UIEaseTabBar;
@interface AGEmojiKeyboardView : UIView

@property (nonatomic, weak) id<AGEmojiKeyboardViewDelegate> delegate;
@property (nonatomic, weak) id<AGEmojiKeyboardViewDataSource> dataSource;
@property (nonatomic, strong) UIEaseTabBar *easeTabBar;
@property (nonatomic,copy) NSString *category;


/**
 @param frame Frame of the view to be initialised with.
 
 @param dataSource dataSource is required during the initialization to
 get all the relevent images to present in the view.
 */
- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(id<AGEmojiKeyboardViewDataSource>)dataSource;

- (void)setDoneButtonTitle:(NSString *)doneStr;
@end


/**
 Protocol to be followed by the dataSource of `AGEmojiKeyboardView`.
 */
@protocol AGEmojiKeyboardViewDataSource <NSObject>

/**
 Method called on dataSource to get the category image when selected.
 
 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 
 @param category category to get the image for. @see AGEmojiKeyboardViewCategoryImage
 */
- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView
      imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category;

/**
 Method called on dataSource to get the category image when not-selected.
 
 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 
 @param category category to get the image for. @see AGEmojiKeyboardViewCategoryImage
 */
- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView
   imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category;

/**
 Method called on dataSource to get the back button image to be shown in the view.
 
 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 */
- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView;

@optional

/**
 Method called on dataSource to get category that should be shown by
 default i.e. when the keyboard is just presented.
 
 @note By default `AGEmojiKeyboardViewCategoryImageRecent` is shown.
 
 @param emojiKeyBoardView EmojiKeyBoardView object shown.
 */
- (AGEmojiKeyboardViewCategoryImage)defaultCategoryForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView;

/**
 Method called on dataSource to get number of emojis to be maintained in
 recent category.
 
 @note By default `50` is used.
 
 @param emojiKeyBoardView EmojiKeyBoardView object shown.
 */
- (NSUInteger)recentEmojisMaintainedCountForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView;

@end


/**
 Protocol to be followed by the delegate of `AGEmojiKeyboardView`.
 */
@protocol AGEmojiKeyboardViewDelegate <NSObject>

/**
 Delegate method called when user taps an emoji button
 
 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 
 @param emoji Emoji used by user
 */
- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView
              didUseEmoji:(NSString *)emoji;

/**
 Delegate method called when user taps on the backspace button
 
 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 */
- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView;

- (void)emojiKeyBoardViewDidPressSendButton:(AGEmojiKeyboardView *)emojiKeyBoardView;

@end

@interface UIEaseTabBar : UIView
@property (assign, nonatomic) NSInteger selectedIndex, numOfTabs;
@property (nonatomic) UIButton *sendButton;

@property (copy, nonatomic) void(^selectedIndexChangedBlock)(UIEaseTabBar *);
@property (copy, nonatomic) void(^sendButtonClickedBlock)();
- (instancetype)initWithFrame:(CGRect)frame selectedImages:(NSArray *)selectedImages unSelectedImages:(NSArray *)unSelectedImages;
@end


