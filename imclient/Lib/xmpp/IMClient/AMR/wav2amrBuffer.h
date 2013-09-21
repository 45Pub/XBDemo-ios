//
//  wav2amrBuffer.h
//  Rcd
//
//  Created by 王 鹏 on 11-12-23.
//  Copyright (c) 2011年 pjsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "amrFileCodec.h"

@interface wav2amrBuffer : NSObject
{
    FILE *fp;
    BOOL initOK;
    BOOL isFirst;
    char magic[8];
	void * enstate;
	int nFrameCount ;
	int bytes;
	unsigned char stdFrameHeader;
	
	unsigned char amrFrame[MAX_AMR_FRAME_SIZE];

}
- (id)initWithPath:(NSString *)path;
- (int)putWavBuffer:(void *)buffer bsize:(size_t)bufsize;
@end
