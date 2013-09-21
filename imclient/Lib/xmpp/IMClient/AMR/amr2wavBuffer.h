//
//  amr2wavBuffer.h
//  Rcd
//
//  Created by 王 鹏 on 11-12-22.
//  Copyright (c) 2011年 pjsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "amrFileCodec.h"

@interface amr2wavBuffer : NSObject
{
    FILE *fp;
    BOOL initOK;
    BOOL isFirst;
    char magic[8];
	void * destate;
	int nFrameCount ;
	int stdFrameSize;
	unsigned char stdFrameHeader;
	
	unsigned char amrFrame[MAX_AMR_FRAME_SIZE];
	short pcmFrame[PCM_FRAME_SIZE];
    BOOL tintSend;
}
- (id)initWithPath:(NSString *)path;
- (id)initWithPath2:(NSString *)path;
- (size_t)getWavBuffer:(void *)outbuff;
- (void)resetAmrfp;
- (int)nFrameCount;
@end
