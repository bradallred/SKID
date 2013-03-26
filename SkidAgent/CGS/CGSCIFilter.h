/*
 * CGSCIFilter.h
 *
 * Created by Joe Ranieri on 7/23/07.
 * Copyright 2007 Alacatia Labs. All rights reserved.
 *
 * A CGSCIFilter is a CoreImage filter that can be applied to a window. As of 10.4.10, this mechanism is very crashy.
 *
 */

#pragma once
#include "CGSConnection.h"
#include "CGSWindow.h"

typedef int CGSCIFilterID;

/*! Creates a new CGSCIFilter from a filter name. These names are the same as you'd usually use for CIFilters. */
CG_EXTERN CGError CGSNewCIFilterByName(CGSConnectionID cid, CFStringRef filterName, CGSCIFilterID *outFilter);

/*! Adds or removes a CIFilter to a window. Flags are currently unknown (the Dock uses 0x3001).
 Note: This stuff is VERY crashy under 10.4.10 - make sure to remove the filter before minimizing the window or closing it. */
CG_EXTERN CGError CGSAddWindowFilter(CGSConnectionID cid, CGSWindowID wid, CGSCIFilterID filter, int flags);
CG_EXTERN CGError CGSRemoveWindowFilter(CGSConnectionID cid, CGSWindowID wid, CGSCIFilterID filter);

/*! Loads a set of values into the CIFilter. */
CG_EXTERN CGError CGSSetCIFilterValuesFromDictionary(CGSConnectionID cid, CGSCIFilterID filter, CFDictionaryRef filterValues);

/*! Releases a CIFilter. */
CG_EXTERN CGError CGSReleaseCIFilter(CGSConnectionID cid, CGSCIFilterID filter);

CG_EXTERN_C_END