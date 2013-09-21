//
//  amr2wavBuffer.m
//  Rcd
//
//  Created by 王 鹏 on 11-12-22.
//  Copyright (c) 2011年 pjsoft. All rights reserved.
//

#import "amr2wavBuffer.h"
//#import "PPCore.h"
@implementation amr2wavBuffer

- (id)initWithPath:(NSString *)path
{
    if((self = [super init]))
    {
        fp = fopen([path UTF8String], "r");
        if(fp == NULL)
        {
//            PPLOG(@"%@|open file error!", path);
//            assert(0);
            return nil;
        }
        fread(magic, sizeof(char), strlen(AMR_MAGIC_NUMBER), fp);
        if (strncmp(magic, AMR_MAGIC_NUMBER, strlen(AMR_MAGIC_NUMBER)) == 0)
        {
            initOK = YES;
        }
        else 
        {
            initOK = NO;
            fclose(fp);
            return nil;
        }
        
        isFirst = YES;
        destate = Decoder_Interface_init();
        tintSend = NO;
		nFrameCount = 0;
    }
    return self;
}

- (id)initWithPath2:(NSString *)path
{
    if((self = [super init]))
    {
        fp = fopen([path UTF8String], "r");
        if(fp == NULL)
        {
//            PPLOG(@"%@|open file error!", path);
            //            assert(0);
            return nil;
        }
        fread(magic, sizeof(char), strlen(AMR_MAGIC_NUMBER), fp);
        if (strncmp(magic, AMR_MAGIC_NUMBER, strlen(AMR_MAGIC_NUMBER)) == 0)
        {
            initOK = YES;
        }
        else 
        {
            initOK = NO;
            fclose(fp);
            return nil;
        }
        
        isFirst = YES;
        destate = Decoder_Interface_init();
        tintSend = YES;
    }
    return self;
}

- (long)addTintWav:(void *)outbuff
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"playend1.wav" ofType:nil];
    FILE *fpwav = fopen([path UTF8String], "r");
    if(fpwav == NULL)
        return 0;
    
    SkipToPCMAudioData(fpwav);
    
    unsigned char buf[24*1024];
    memset(buf, 0, 24*1024);
    long num = fread((void *)buf, 1, 24*1024, fpwav);
//    PPLOG(@"%ld===wav", num);
    memcpy(outbuff, buf, num);
    fclose(fpwav);
    [pool drain];
    return num;
}

- (size_t)getWavBuffer:(void *)outbuff
{
    void *pp = outbuff;
    int ret;
//    NSLog(@"tt");
    if(isFirst == YES)
    {
        memset(amrFrame, 0, sizeof(amrFrame));
        memset(pcmFrame, 0, sizeof(pcmFrame));
        if(ReadAMRFrameFirst(fp, amrFrame, &stdFrameSize, &stdFrameHeader) == 0)
            return 0;
        
        // 解码一个AMR音频帧成PCM数据
        Decoder_Interface_Decode(destate, amrFrame, pcmFrame, 0);
        nFrameCount++;
        //	fwrite(pcmFrame, sizeof(short), PCM_FRAME_SIZE, fpwave);
        memcpy(pp, pcmFrame, PCM_FRAME_SIZE*sizeof(short));
        pp += PCM_FRAME_SIZE*sizeof(short);
        isFirst = NO;
    }
    int i = 100;
    while(i--)
    {
        memset(amrFrame, 0, sizeof(amrFrame));
		memset(pcmFrame, 0, sizeof(pcmFrame));
		if (!ReadAMRFrame(fp, amrFrame, stdFrameSize, stdFrameHeader)) break;
		
		// 解码一个AMR音频帧成PCM数据 (8k-16b-单声道)
		Decoder_Interface_Decode(destate, amrFrame, pcmFrame, 0);
		nFrameCount++;
        //		fwrite(pcmFrame, sizeof(short), PCM_FRAME_SIZE, fpwave);
        memcpy(pp, pcmFrame, PCM_FRAME_SIZE*sizeof(short));
        pp += PCM_FRAME_SIZE*sizeof(short);
        
    }
    ret = pp - outbuff;
    if(ret == 0 && tintSend == NO)
    {
        tintSend = YES;
        ret = [self addTintWav:outbuff];
    }
    return ret;
}

- (void)resetAmrfp
{
    isFirst = NO;
    fseek(fp, 0, SEEK_SET);
}

- (void)dealloc
{
    Decoder_Interface_exit(destate);
    fclose(fp);
    [super dealloc];
}

- (int)nFrameCount
{
	return nFrameCount;
}

@end
