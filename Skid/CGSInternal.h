/*
 * CGSInternal.h
 *
 * Created by Joe Ranieri on 7/23/07.
 * Copyright 2007 Alacatia Labs. All rights reserved.
 *
 */

#pragma once
#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>

#warning CGSInternal contains PRIVATE FUNCTIONS and should NOT BE USED in shipping applications!

#ifndef AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER
#define AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER UNAVAILABLE_ATTRIBUTE
#endif

//#include "CarbonHelpers.h"
#include "CGSAccessibility.h"
#include "CGSCIFilter.h"
#include "CGSConnection.h"
#include "CGSCursor.h"
#include "CGSDebug.h"
#include "CGSDisplays.h"
#include "CGSHotKeys.h"
#include "CGSMisc.h"
#include "CGSRegion.h"
#include "CGSSession.h"
#include "CGSTransitions.h"
#include "CGSWindow.h"