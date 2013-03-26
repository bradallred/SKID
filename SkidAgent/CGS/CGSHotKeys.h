/*
 * CGSHotKeys.h
 *
 * Created by Joe Ranieri on 7/23/07.
 * Copyright 2007 Alacatia Labs. All rights reserved.
 *
 */

#pragma once
#include "CGSConnection.h"

// A symbolic hotkey is basically a named hotkey which is remembered between application launches.
typedef enum {
	// full keyboard access hotkeys
	kCGSHotKeyToggleFullKeyboardAccess = 12,
	kCGSHotKeyFocusMenubar = 7,
	kCGSHotKeyFocusDock = 8,
	kCGSHotKeyFocusNextGlobalWindow = 9,
	kCGSHotKeyFocusToolbar = 10,
	kCGSHotKeyFocusFloatingWindow = 11,
	kCGSHotKeyFocusApplicationWindow = 27,
	kCGSHotKeyFocusNextControl = 13,
	kCGSHotKeyFocusDrawer = 51,
	kCGSHotKeyFocusStatusItems = 57,
	
	// screenshot hotkeys
	kCGSHotKeyScreenshot = 28,
	kCGSHotKeyScreenshotToClipboard = 29,
	kCGSHotKeyScreenshotRegion = 30,
	kCGSHotKeyScreenshotRegionToClipboard = 31,
	
	// universal access
	kCGSHotKeyToggleZoom = 15,
	kCGSHotKeyZoomOut = 19,
	kCGSHotKeyZoomIn = 17,
	kCGSHotKeyZoomToggleSmoothing = 23,
	kCGSHotKeyIncreaseContrast = 25,
	kCGSHotKeyDecreaseContrast = 26,
	kCGSHotKeyInvertScreen = 21,
	kCGSHotKeyToggleVoiceOver = 59,
	
	// Dock
	kCGSHotKeyToggleDockAutohide = 52,
	kCGSHotKeyExposeAllWindows = 32,
	kCGSHotKeyExposeAllWindowsSlow = 34,
	kCGSHotKeyExposeApplicationWindows = 33,
	kCGSHotKeyExposeApplicationWindowsSlow = 35,
	kCGSHotKeyExposeDesktop = 36,
	kCGSHotKeyExposeDesktopsSlow = 37,
	kCGSHotKeyDashboard = 62,
	kCGSHotKeyDashboardSlow = 63,
	
	// spaces (Leopard and later)
	kCGSHotKeySpaces = 75,
	kCGSHotKeySpacesSlow = 76,
	// 77 - fn F7 (disabled)
	// 78 - ⇧fn F7 (disabled)
	kCGSHotKeySpaceLeft = 79,
	kCGSHotKeySpaceLeftSlow = 80,
	kCGSHotKeySpaceRight = 81,
	kCGSHotKeySpaceRightSlow = 82,
	kCGSHotKeySpaceDown = 83,
	kCGSHotKeySpaceDownSlow = 84,
	kCGSHotKeySpaceUp = 85,
	kCGSHotKeySpaceUpSlow = 86,
	
	// input
	kCGSHotKeyToggleCharacterPallette = 50,
	kCGSHotKeySelectPreviousInputSource = 60,
	kCGSHotKeySelectNextInputSource = 61,
	
	// Spotlight
	kCGSHotKeySpotlightSearchField = 64,
	kCGSHotKeySpotlightWindow = 65,
	
	kCGSHotKeyToggleFrontRow = 73,
	kCGSHotKeyLookUpWordInDictionary = 70,
	kCGSHotKeyHelp = 98, //AVAILABLE_MAC_OS_X_VERSION_10_5_AND_LATER
	
	// displays - not verified
	kCGSHotKeyDecreaseDisplayBrightness = 53,
	kCGSHotKeyIncreaseDisplayBrightness = 54,
} CGSSymbolicHotKey;

typedef enum {
    kCGSGlobalHotKeyEnable,
    kCGSGlobalHotKeyDisable,
	kCGSGlobalHotKeyDisableAllButUniversalAccess
} CGSGlobalHotKeyOperatingMode;


CG_EXTERN_C_BEGIN

/*! DOCUMENTATION PENDING */
CG_EXTERN CGError CGSGetSymbolicHotKeyValue(CGSSymbolicHotKey hotKey, int *unknown, int *outVirtualKeyCode, int *outModifiers);

/*! Gets and sets whether a symbolic hot key is enabled. */
CG_EXTERN bool CGSIsSymbolicHotKeyEnabled(CGSSymbolicHotKey hotKey);
CG_EXTERN CGError CGSSetSymbolicHotKeyEnabled(CGSSymbolicHotKey hotKey, bool isEnabled);

/*! Gets and sets the global hotkey operating mode. This can be used to disable all hotkeys. */
CG_EXTERN CGError CGSGetGlobalHotKeyOperatingMode(CGSConnectionID cid, CGSGlobalHotKeyOperatingMode *outMode);
CG_EXTERN CGError CGSSetGlobalHotKeyOperatingMode(CGSConnectionID cid, CGSGlobalHotKeyOperatingMode mode);

CG_EXTERN_C_END