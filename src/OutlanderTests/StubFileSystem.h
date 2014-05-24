//
//  StubFileSystem.h
//  Outlander
//
//  Created by Joseph McBride on 5/20/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

#import "FileSystem.h"

@interface StubFileSystem : NSObject <FileSystem>

@property (nonatomic, strong) NSString *fileContents;
@property (nonatomic, strong) NSString *givenFileName;
@property (nonatomic, strong) NSError *errorToReturn;
@property (nonatomic, assign) BOOL writeResult;

@end
