//
//  UIView+PDFAdditionals.h
//  MileageMonster
//
//  Created by Stanislav Cherednichenko on 31.07.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


@interface UIView(PDFWritingAdditions)

- (void)renderInPDFFile:(NSString*)path;

@end
