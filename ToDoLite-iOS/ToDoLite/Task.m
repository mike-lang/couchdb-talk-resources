//
//  Task.m
//  ToDo Lite
//
//  Created by Jens Alfke on 8/22/13.
//
//

#import "Task.h"
#import "List.h"

#define kTaskDocType @"task"
#define kTaskImageName @"image"

@implementation Task

@dynamic checked, list_id;

+ (NSString*) docType {
    return kTaskDocType;
}

@end
