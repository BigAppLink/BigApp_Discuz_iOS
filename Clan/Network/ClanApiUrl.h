//
//  ClanApiUrl.h
//  Clan
//
//  Created by chivas on 15/3/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#ifndef Clan_ClanApiUrl_h
#define Clan_ClanApiUrl_h

typedef NS_ENUM(NSInteger, ListType) {
    allList = 0,//默认
    newList,//最新回复
    heats,//按热门排序
    hotList,//本版热帖
    ordbydata,//发帖时间排序
    digestlist,//精华帖
    
};
#endif
