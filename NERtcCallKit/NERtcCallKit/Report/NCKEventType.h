//
//  NCKEventType.h
//  NERtcCallKit
//
//  Created by Wenchao Ding on 2021/6/1.
//  Copyright © 2021 Wenchao Ding. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString * NCKEventType NS_EXTENSIBLE_STRING_ENUM;

extern NCKEventType const NCKEventTypeCall; 
extern NCKEventType const NCKEventTypeAccept;
extern NCKEventType const NCKEventTypeReject;
extern NCKEventType const NCKEventTypeHangup;
extern NCKEventType const NCKEventTypeCancel;
extern NCKEventType const NCKEventTypeTimeout;
