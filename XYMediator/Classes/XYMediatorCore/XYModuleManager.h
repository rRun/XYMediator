//
//  XYModuleManager.h
//  Pods
//
//  Created by 何霞雨 on 2016/11/23.
//
//

#import <Foundation/Foundation.h>

#define kModuleArrayKey     @"moduleClasses"
#define kModuleInfoNameKey  @"moduleClass"
#define kModuleInfoUrlKey  @"moduleUrl"
#define kModuleInfoLevelKey @"moduleLevel"

@class XYModule;
@interface XYModuleManager : NSObject

@property(nonatomic, strong)  NSMutableArray<XYModule *> *BHModules;//module数组
@property (nonatomic, strong) NSString *modulesConfigFilename;//本地解析配置的路径

+ (instancetype)sharedManager;

//加载本地配置
-(void)loadLocalModules;
//手动添加
-(void)addModule:(XYModule *)module;

//获取完module数组后，注册组件
- (void)registedAllModules;
-(void)registedModule:(XYModule *)module;

@end

@interface XYModule : NSObject

@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,assign)NSInteger level;


@property (nonatomic,assign)BOOL hasRegisted;

@end
