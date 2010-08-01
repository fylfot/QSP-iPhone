//
//  UIView+PDFAdditionals.m
//  MileageMonster
//
//  Created by Stanislav Cherednichenko on 31.07.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@implementation UIView(PDFWritingAdditions)

- (void)renderInPDFFile:(NSString*)path {
    CGRect mediaBox = self.bounds;
    CGContextRef ctx = CGPDFContextCreateWithURL((CFURLRef)[NSURL URLWithString:path], &mediaBox, NULL);
    
    CGPDFContextBeginPage(ctx, NULL);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -mediaBox.size.height);
    [self.layer renderInContext:ctx];
    CGPDFContextEndPage(ctx);
    CFRelease(ctx);
}

@end

