//
//  NSString+UrlEncode.m
//  playtell-ducati
//
//  Created by Dimitry Bentsionov on 7/26/12.
//  Copyright (c) 2012 LovelyRide. All rights reserved.
//

#import "NSString+UrlEncode.h"

@implementation NSString (UrlEncode)

- (NSString *)urlEncodedString { // UTF-8 encodes prior to URL encoding
	NSMutableString *result = [NSMutableString string];
	const char *p = [self UTF8String];
	unsigned char c;
	
	for(; (c = *p); p++)
	{
		switch(c)
		{
			case '0' ... '9':
			case 'A' ... 'Z':
			case 'a' ... 'z':
			case '.':
			case '-':
			case '~':
			case '_':
				[result appendFormat:@"%c", c];
				break;
			default:
				[result appendFormat:@"%%%02X", c];
		}
	}
	return result;
}

@end