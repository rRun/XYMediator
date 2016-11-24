//
//  XYModuleManager.m
//  Pods
//
//  Created by 何霞雨 on 2016/11/23.
//
//

#import "XYModuleManager.h"

#import "XYURLMediatorCore.h"
#import "XYConnectorPrt.h"




@implementation XYModule


@end



@interface XYModuleManager()



@end

@implementation XYModuleManager


#pragma mark - public

+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)loadLocalModules
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:self.modulesConfigFilename ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        return;
    }
    
    NSDictionary *moduleList = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSArray *modulesArray = [moduleList objectForKey:kModuleArrayKey];
    
    [modulesArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *module1Level = (NSNumber *)[obj objectForKey:kModuleInfoLevelKey];
        NSString *classStr = [obj objectForKey:kModuleInfoNameKey];
        NSString *url = [obj objectForKey:kModuleInfoUrlKey];
        
        [self addModule:classStr Url:url Level:[module1Level intValue]];
        
    }];
}
-(void)addModule:(XYModule *)module{
    [self addModule:module.name Url:module.url Level:module.level];
}
-(void)addModule:(NSString *)className Url:(NSString *)url Level:(int)level{
    if (!url || !className) {
        NSLog(@"module的class,url不能为空！");
        return ;
    }
    XYModule *module = [XYModule new];
    module.level = level;
    module.name = className;
    module.url = url;
    
    __block BOOL hasExists = NO;
    [self.BHModules enumerateObjectsUsingBlock:^(XYModule *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.url isEqualToString:module.url]) {
            hasExists = YES;
            *stop = YES;
        }
    }];
    [self.BHModules addObject:module];
}
- (void)registedAllModules
{
    [self.BHModules sortUsingComparator:^NSComparisonResult(XYModule *module1, XYModule *module2) {
        return module1.level > module2.level;
    }];
    
    //module init
    [self.BHModules enumerateObjectsUsingBlock:^(XYModule *module, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registedModule:module];
    }];
}

-(void)registedModule:(XYModule *)module{
    if (module.hasRegisted) {
        return ;
    }
    
    NSString *classStr = module.name;
    NSString *url = module.url;
    Class moduleClass = NSClassFromString(classStr);
    
    if (NSStringFromClass(moduleClass)) {
        id clazz = [[moduleClass alloc]init];
        if ([clazz conformsToProtocol:@protocol(XYConnectorPrt)] ) {
            [[XYURLMediatorCore sharedRouter]registerURL:url forClass:moduleClass];
            module.hasRegisted = YES;
        }
    }
}
#pragma mark - setter or getter

- (NSMutableArray *)BHModules
{
    if (!_BHModules) {
        _BHModules = [NSMutableArray array];
    }
    return _BHModules;
}


@end
