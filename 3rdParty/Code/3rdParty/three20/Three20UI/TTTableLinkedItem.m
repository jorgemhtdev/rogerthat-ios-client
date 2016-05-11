//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "TTTableLinkedItem.h"

// Core
#import "TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableLinkedItem

@synthesize URL           = _URL;
@synthesize accessoryURL  = _accessoryURL;
@synthesize delegate      = _delegate;
@synthesize selector      = _selector;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder*)decoder {
	self = [super initWithCoder:decoder];
  if (self) {
    self.URL = [decoder decodeObjectForKey:@"URL"];
    self.accessoryURL = [decoder decodeObjectForKey:@"accessoryURL"];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
  [super encodeWithCoder:encoder];
  if (self.URL) {
    [encoder encodeObject:self.URL forKey:@"URL"];
  }
  if (self.accessoryURL) {
    [encoder encodeObject:self.accessoryURL forKey:@"accessoryURL"];
  }
}


@end

