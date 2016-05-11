/*
 * Copyright 2016 Mobicage NV
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @@license_version:1.1@@
 */

#import <Foundation/Foundation.h>


typedef enum {
    MCTJSEmbeddingStatusUnavailable = 0,
    MCTJSEmbeddingStatusAvailable = 1,
} MCTJSEmbeddingStatus;

@interface MCTJSEmbedding : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *embeddingHash;
@property (nonatomic) MCTJSEmbeddingStatus status;

+ (MCTJSEmbedding *)jsEmbeddingWithName:(NSString *)name embeddingHash:(NSString *)embeddingHash status:(MCTJSEmbeddingStatus)status;

@end