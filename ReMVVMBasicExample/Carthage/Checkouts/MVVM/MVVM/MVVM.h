//
//  MVVM.h
//  MVVM
//
//  Created by Dariusz Grzeszczak on 19/05/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

// ViewModelProviders - Android like implementation

#include <TargetConditionals.h>

#ifdef TARGET_OS_WATCHOS
#import <WatchKit/WatchKit.h>
#elif TARGET_OS_IPHONE || TARGET_OS_TV || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for MVVM.
FOUNDATION_EXPORT double MVVMVersionNumber;

//! Project version string for MVVM.
FOUNDATION_EXPORT const unsigned char MVVMVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MVVM/PublicHeader.h>


