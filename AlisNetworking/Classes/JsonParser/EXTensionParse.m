//
//  EXTensionParse.m
//  Pods
//
//  Created by alisports on 2017/4/7.
//
//
#import "AlisJsonModel.h"
#import "EXTensionParse.h"

@implementation EXTensionParse

- (id)parseJsonValue:(id<AlisJsonParserProtocol>)baseJsonParser parseClass:(Class)parseClass  jsonData:(NSDictionary *)jsonData{
    if (jsonData == nil || baseJsonParser == nil) {
        return nil;
    }
    
    AlisJsonModel *jsonModel = nil;
    if ([baseJsonParser respondsToSelector:@selector(parserBaseJsonValue:)]) {
         jsonModel = [baseJsonParser parserBaseJsonValue:jsonData];
    }
    else{
        //default parser
    
    }
   
    // 有可能是数组或者对象
    if ([jsonModel.data isKindOfClass:[NSArray class]]) {
        NSMutableArray *parsedData = [parseClass mj_objectArrayWithKeyValuesArray:jsonModel.data];
        jsonModel.data = parsedData;
        return jsonModel;
    }
    else{
        id parsedData = [parseClass mj_objectWithKeyValues:jsonModel.data];
        return parsedData;
    }
}

- (id)parseJsonValue:(Class)parseClass  jsonData:(NSDictionary *)jsonData{
    if (jsonData == nil ) return nil;
    AlisJsonModel *jsonModel = [[AlisJsonModel alloc]init];
    jsonModel.data = jsonData;    
    // 有可能是数组或者对象
    if ([jsonModel.data isKindOfClass:[NSArray class]]) {
        NSMutableArray *parsedData = [parseClass mj_objectArrayWithKeyValuesArray:jsonModel.data];
        jsonModel.data = parsedData;
        return jsonModel;
    }
    else{
        id parsedData = [parseClass mj_objectWithKeyValues:jsonModel.data];
        return parsedData;
    }
}

@end
