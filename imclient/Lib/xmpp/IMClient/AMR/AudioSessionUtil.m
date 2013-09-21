//
//  AudioSessionUtil.m
//  PPLibTest
//
//  Created by Paul Wang on 12-7-3.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import "AudioSessionUtil.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation AudioSessionUtil

+ (void)headPlusinChangeToSpeaker
{
    CFStringRef newRoute;
    UInt32 size; size = sizeof(CFStringRef);
    OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
    if (error)
    {
        printf("ERROR GETTING NEW AUDIO ROUTE! %ld\n", error);
    }
    else
    {
        CFStringRef head = CFSTR("Head");
        if(!CFStringHasPrefix(newRoute, head))
        {
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
        }
        else
        {
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
        }
        
        CFRelease(newRoute);
    }
}

@end
