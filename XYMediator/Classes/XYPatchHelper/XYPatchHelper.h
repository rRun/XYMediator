//
//  XYPatchHelper.h
//  Pods
//
//  Created by 何霞雨 on 16/11/10.
//
//

#import <Foundation/Foundation.h>

@interface XYPatchHelper : NSObject

//是关于XYPathchModel的数组
- (instancetype)initWithPatchArray:(NSMutableArray *)array;

//加载热更新文件
-(void)loadPathchFile;

@end
