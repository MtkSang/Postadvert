//
//  AlertCellContent.h
//  Postadvert
//
//  Created by Mtk Ray on 6/27/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertCellContent : NSObject

@property (nonatomic)           NSInteger connection_id;
@property (nonatomic)           NSInteger connect_from_id;
@property( nonatomic, strong)   NSString *connect_from_name;
@property( nonatomic, strong)   NSString *connect_from_thumb;
@property (nonatomic, strong)   NSString *created;
@property( nonatomic, strong)   NSString *message;
@property( nonatomic)           NSInteger mutual_friends_count;

- (id) initWithDict:(NSDictionary*)dict;
@end
