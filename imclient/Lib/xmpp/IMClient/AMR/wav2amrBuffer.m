//
//  wav2amrBuffer.m
//  Rcd
//
//  Created by 王 鹏 on 11-12-23.
//  Copyright (c) 2011年 pjsoft. All rights reserved.
//

#import "wav2amrBuffer.h"
//#import "PPCore.h"

@implementation wav2amrBuffer
- (id)initWithPath:(NSString *)path
{
    if((self = [super init]))
    {
        fp = fopen([path UTF8String], "wb");
        if(fp == NULL)
        {
//            PPLOG(@"open file error!");
            return nil;
        }
    
        bytes = fwrite(AMR_MAGIC_NUMBER, sizeof(char), strlen(AMR_MAGIC_NUMBER), fp);
        enstate = Encoder_Interface_init(0);
    }
    return self;
}

- (int)putWavBuffer:(void *)buffer bsize:(size_t)bufsize
{
    short speech[160];
    int byte_counter, frames = 0;
    enum Mode req_mode = MR515;
    void *p = buffer;
    if(bufsize < 320)
        return 0;
    for(int i = 0; i< bufsize; i+=320)
    {
        memset((void *)speech, 0, 320);
        memcpy((void *)speech, p, 320);
        memset(amrFrame, 0, sizeof(amrFrame));
        byte_counter = Encoder_Interface_Encode(enstate, req_mode, speech, amrFrame, 0);
		
		bytes += byte_counter;
		fwrite(amrFrame, sizeof (unsigned char), byte_counter, fp);
        frames++;
        
        p += 320;
    }
    /*for(;p < buffer + bufsize;)
    {
        int addPad;
        memset((void *)speech, 0, 320);
        if(p + 320 < buffer + bufsize)
            addPad = 320;
        else
            addPad = buffer + bufsize - p;
        memcpy((void *)speech, p, addPad);
        memset(amrFrame, 0, sizeof(amrFrame));
//        PPLOG(@"%@", @"begin Endcode");
        byte_counter = Encoder_Interface_Encode(enstate, req_mode, speech, amrFrame, 0);
//		PPLOG(@"%@", @"end Endcode");
		bytes += byte_counter;
		fwrite(amrFrame, sizeof (unsigned char), byte_counter, fp);
        frames++;
        
        p += addPad;

    
    }*/
    return frames;
}

- (void)dealloc
{
    Encoder_Interface_exit(enstate);
    fclose(fp);
    [super dealloc];
}
@end
