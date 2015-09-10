//
//  messageView.m
//  master
//
//  Created by jin on 15/9/8.
//  Copyright (c) 2015年 JXH. All rights reserved.
//

#import "messageView.h"
#import "otherMessageTableViewCell.h"
#import "mySelfMessageTableViewCell.h"
@implementation messageView


-(void)dealloc{

    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}


-(instancetype)initWithFrame:(CGRect)frame{

    if (self=[super initWithFrame:frame]) {
        
        [self createTableview];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    
    return self;

}





-(void)keyboardWillHide:(NSNotification*)nc{




}

-(void)keyboardWillShow:(NSNotification*)nc{



}

-(void)createTableview{

//    self.tableview=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64-45)];
//    self.tableview.delegate=self;
//    self.tableview.dataSource=self;
//    self.tableview.separatorStyle=0;
//    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
//    tap.numberOfTapsRequired=1;
//    tap.numberOfTouchesRequired=1;
//    [self addGestureRecognizer:tap];
    
    /* 对话列表 */
    self.chatListTable = [[UITableView alloc]init];
    self.chatListTable.dataSource = self;
    self.chatListTable.delegate = self;
    self.chatListTable.backgroundColor = [GJGCChatInputPanelStyle mainBackgroundColor];
    self.chatListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatListTable.frame = (CGRect){0,0,GJCFSystemScreenWidth,GJCFSystemScreenHeight  - 50};
    [self addSubview:self.chatListTable];
    
    /* 滚动到最底部 */
//    if (self.dataSourceManager.totalCount > 0) {
//        [self.chatListTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSourceManager.totalCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
//    
//    if (GJCFSystemVersionIs7) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
    
    /* 输入面板 */
    self.inputPanel = [[GJGCChatInputPanel alloc]initWithPanelDelegate:self];
    self.inputPanel.frame = (CGRect){0,GJCFSystemScreenHeight-self.inputPanel.inputBarHeight,GJCFSystemScreenWidth,self.inputPanel.inputBarHeight+216};
    
    GJCFWeakSelf weakSelf = self;
    [self.inputPanel configInputPanelKeyboardFrameChange:^(GJGCChatInputPanel *panel,CGRect keyboardBeginFrame, CGRect keyboardEndFrame, NSTimeInterval duration,BOOL isPanelReserve) {
        
        /* 不要影响其他不带输入面板的系统视图对话 */
        if (panel.hidden) {
            return ;
        }
        
        [UIView animateWithDuration:duration animations:^{
            
            weakSelf.chatListTable.gjcf_height = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight  - keyboardEndFrame.size.height;
            
            if (keyboardEndFrame.origin.y == GJCFSystemScreenHeight) {
                
                if (isPanelReserve) {
                    
                    weakSelf.inputPanel.gjcf_top = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight ;
                    
                    weakSelf.chatListTable.gjcf_height = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight ;
                    
                }else{
                    
                    weakSelf.inputPanel.gjcf_top = GJCFSystemScreenHeight - 216 - weakSelf.inputPanel.inputBarHeight ;
                    
                    weakSelf.chatListTable.gjcf_height = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight  - 216;
                    
                }
                
            }else{
                
                weakSelf.inputPanel.gjcf_top = weakSelf.chatListTable.gjcf_bottom;
                
            }
            
        }];
        
        [weakSelf.chatListTable scrollRectToVisible:CGRectMake(0, weakSelf.chatListTable.contentSize.height - weakSelf.chatListTable.bounds.size.height, weakSelf.chatListTable.gjcf_width, weakSelf.chatListTable.gjcf_height) animated:NO];
        
    }];
    
    [self.inputPanel configInputPanelRecordStateChange:^(GJGCChatInputPanel *panel, BOOL isRecording) {
        
        if (isRecording) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
//                [weakSelf stopPlayCurrentAudio];
                
                weakSelf.chatListTable.userInteractionEnabled = NO;
                
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakSelf.chatListTable.userInteractionEnabled = YES;
                
            });
        }
        
    }];
    
    [self.inputPanel configInputPanelInputTextViewHeightChangedBlock:^(GJGCChatInputPanel *panel, CGFloat changeDelta) {
        
        panel.gjcf_top = panel.gjcf_top - changeDelta;
        
        panel.gjcf_height = panel.gjcf_height + changeDelta;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            weakSelf.chatListTable.gjcf_height = weakSelf.chatListTable.gjcf_height - changeDelta;
            
            [weakSelf.chatListTable scrollRectToVisible:CGRectMake(0, weakSelf.chatListTable.contentSize.height - weakSelf.chatListTable.bounds.size.height, weakSelf.chatListTable.gjcf_width, weakSelf.chatListTable.gjcf_height) animated:NO];
            
        }];
        
    }];
    
//    /* 动作变化 */
//    [self.inputPanel setActionChangeBlock:^(GJGCChatInputBar *inputBar, GJGCChatInputBarActionType toActionType) {
////        [weakSelf inputBar:inputBar changeToAction:toActionType];
//    }];
    [self addSubview:self.inputPanel];
    
    /* 顶部刷新 */
//    self.refreshHeadView = [[GJGCRefreshHeaderView alloc]init];
//    self.refreshHeadView.delegate = self;
//    [self.refreshHeadView setupChatFooterStyle];
//    [self.chatListTable addSubview:self.refreshHeadView];
    
    /* 拉取最新历史消息 */
//    [self addOrRemoveLoadMore];
    
    
    /* 观察输入面板变化 */
//    [self.inputPanel addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
//    
//    [self.chatListTable addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionNew context:nil];
}


-(void)hideKeyBoard{

    
    __weak typeof(self)weakSelf=self;
    [UIView animateWithDuration:0.2 animations:^{
        
        weakSelf.inputPanel.gjcf_top = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight ;
        
        weakSelf.chatListTable.gjcf_height = GJCFSystemScreenHeight - weakSelf.inputPanel.inputBarHeight ;
    }];


}


#pragma mark - 属性变化观察
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"] && object == self.inputPanel) {
        
        CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        
        CGFloat originY = GJCFSystemNavigationBarHeight + GJCFSystemOriginYDelta;
        
        //50.f 高度是输入条在底部的时候显示的高度，在录音状态下就是50
        if (newFrame.origin.y < GJCFSystemScreenHeight - 50.f - originY) {
            
            self.inputPanel.isFullState = YES;
            
        }else{
            
            self.inputPanel.isFullState = NO;
        }
    }
    
    if ([keyPath isEqualToString:@"panGestureRecognizer.state"] && object == self.chatListTable) {
        
        UIGestureRecognizerState state = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (state) {
            case UIGestureRecognizerStateBegan:
            case UIGestureRecognizerStateChanged:
            {
//                [self makeVisiableGifCellPause];
            }
                break;
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
            {
//                [self makeVisiableGifCellResume];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - 输入动作变化

- (void)inputBar:(GJGCChatInputBar *)inputBar changeToAction:(GJGCChatInputBarActionType)actionType
{
    CGFloat originY = GJCFSystemNavigationBarHeight + GJCFSystemOriginYDelta;
    
    switch (actionType) {
        case GJGCChatInputBarActionTypeRecordAudio:
        {
            if (self.inputPanel.isFullState) {
                
                [UIView animateWithDuration:0.26 animations:^{
                    
                    self.inputPanel.gjcf_top = GJCFSystemScreenHeight - self.inputPanel.inputBarHeight - originY;
                    
                    self.chatListTable.gjcf_height = GJCFSystemScreenHeight - self.inputPanel.inputBarHeight - originY;
                    
                }];
                
                [self.chatListTable scrollRectToVisible:CGRectMake(0, self.chatListTable.contentSize.height - self.chatListTable.bounds.size.height, self.chatListTable.gjcf_width, self.chatListTable.gjcf_height) animated:NO];
            }
        }
            break;
        case GJGCChatInputBarActionTypeChooseEmoji:
        case GJGCChatInputBarActionTypeExpandPanel:
        {
            if (!self.inputPanel.isFullState) {
                
                [UIView animateWithDuration:0.26 animations:^{
                    
                    self.inputPanel.gjcf_top = GJCFSystemScreenHeight - self.inputPanel.inputBarHeight - 216 - originY;
                    
                    self.chatListTable.gjcf_height = GJCFSystemScreenHeight - self.inputPanel.inputBarHeight - 216 - originY;
                    
                }];
                
                
                [self.chatListTable scrollRectToVisible:CGRectMake(0, self.chatListTable.contentSize.height - self.chatListTable.bounds.size.height, self.chatListTable.gjcf_width, self.chatListTable.gjcf_height) animated:NO];
                
            }
        }
            break;
            
        default:
            break;
    }
}






-(void)send:(UIButton*)button{

   

}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 0;
    return [[self.convenit loadAllMessages] count];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 1;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EMMessage*message=[self.convenit loadAllMessages][indexPath.section];
     if ([message isKindOfClass:[EMTextMessageBody class]]==YES) {
    AppDelegate*delegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    PersonalDetailModel*model=[[dataBase share]findPersonInformation:delegate.id];
   
    if ([model.mobile isEqualToString:message.from]==YES) {
        mySelfMessageTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"mySelfMessageTableViewCell"];
        if (!cell) {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"mySelfMessageTableViewCell" owner:nil  options:nil]lastObject];
        }
        
        cell.selectionStyle=0;
        cell.model=message;
        [cell reloadData];
        return cell;
        
    }
    otherMessageTableViewCell*Cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!Cell) {
       Cell=[[[NSBundle mainBundle]loadNibNamed:@"otherMessageTableViewCell" owner:nil options:nil]lastObject];
    }
    Cell.selectionStyle=0;
    Cell.model=message;
    [Cell reloadData];
    return Cell;
     }
    UITableViewCell*cell=[[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"CELL"];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    EMMessage*message=[self.convenit loadAllMessages][indexPath.section];
    if ([message isKindOfClass:[EMTextMessageBody class]]==YES) {
        NSString*temp=((EMTextMessageBody*)message.messageBodies.firstObject).text;
        if (temp.length<=13) {
            return 75;
        }else{
            
            return 75+[self accountStringHeightFromString:temp Width:13*15+15]-16;
            
        }
    }
    return 50;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    label.backgroundColor=self.chatListTable.backgroundColor;
    return label;

}



- (void)chatInputPanel:(GJGCChatInputPanel *)panel sendTextMessage:(NSString *)text{


    [self.delegate sendMessage:text];
    

}


@end