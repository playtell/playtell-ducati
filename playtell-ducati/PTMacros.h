//
//  PTMacros.h
//  PlayTell
//
//  Created by Dimitry Bentsionov on 5/17/12.
//  Copyright (c) 2012 PlayTell. All rights reserved.
//

#ifndef PlayTell_Macros_h
#define PlayTell_Macros_h

/** UIColor: Color From Hex **/
/** Import UIColor+Extended.h **/
#define colorFromHex( rgbValue ) ( [UIColor UIColorFromRGB:rgbValue ] )

/** UIColor: Color from RGB **/
#define colorFromRGB( r , g , b ) ( [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1 ] )

/** UIColor: Color from RGBA **/
#define colorFromRGBA(r , g , b , a ) ( [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a ] )

/** Float: Degrees -> Radian **/
#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

/** Float: Radians -> Degrees **/
#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )

/** Animation: Speed **/
#define BOOK_OPEN_CLOSE_ANIMATION_SPEED 1.0f
#define BOOK_HIDE_SHOW_ANIMATION_SPEED 0.5f
#define PAGE_TURN_ANIMATION_SPEED 0.3f

#endif
