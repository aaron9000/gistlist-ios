//
//  LocalStorage.h
//  Blob
//
//  Created by Aaron Geisler on 3/9/13.
//
//

#import <Foundation/Foundation.h>
#import "LocalData.h"

@interface LocalStorage : NSObject{
}

+ (LocalData*) localData;
+ (void) setLocalData:(LocalData*) localData;
+ (void) resetLocalData;

@end
