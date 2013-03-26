/*
 * CGSDisplays.h
 *
 * Created by Joe Ranieri on 7/23/07.
 * Contributed to by Ryan Govostes.
 *
 * Copyright 2007 Alacatia Labs. All rights reserved.
 *
 */

#pragma once

CG_EXTERN_C_BEGIN

/*! Begins a new display configuration transacation. */
CG_EXTERN CGDisplayErr CGSBeginDisplayConfiguration(CGDisplayConfigRef *config);

/*! Sets the origin of a display relative to the main display. The main display is at (0, 0) and contains the menubar. */
CG_EXTERN CGDisplayErr CGSConfigureDisplayOrigin(CGDisplayConfigRef config, CGDirectDisplayID display, CGDisplayCoord x, CGDisplayCoord y);

/*! Applies the configuration changes made in this transaction. */
CG_EXTERN CGDisplayErr CGSCompleteDisplayConfiguration(CGDisplayConfigRef config);

/*! Gets the main display. */
CG_EXTERN CGDirectDisplayID CGSMainDisplayID(void);

/*! Drops the configuration changes made in this transaction. */
CG_EXTERN CGDisplayErr CGSCancelDisplayConfiguration(CGDisplayConfigRef config);

/*! Gets a list of on line displays */
CG_EXTERN CGDisplayErr CGSGetOnlineDisplayList(CGDisplayCount maxDisplays, CGDirectDisplayID *displays, CGDisplayCount *outDisplayCount);

/*! Gets a list of active displays */
CG_EXTERN CGDisplayErr CGSGetActiveDisplayList(CGDisplayCount maxDisplays, CGDirectDisplayID *displays, CGDisplayCount *outDisplayCount);

/*! Gets the depth of a display. */
CG_EXTERN CGError CGSGetDisplayDepth(CGDirectDisplayID id, int *outDepth);

/*! Gets the displays at a point. Note that multiple displays can have the same point - think mirroring. */
CG_EXTERN CGError CGSGetDisplaysWithPoint(const CGPoint *point, int maxDisplayCount, CGDirectDisplayID *outDisplays, int *outDisplayCount);

/*! Gets the displays which contain a rect. Note that multiple displays can have the same bounds - think mirroring. */
CG_EXTERN CGError CGSGetDisplaysWithRect(const CGRect *point, int maxDisplayCount, CGDirectDisplayID *outDisplays, int *outDisplayCount);

/*! Gets the bounds for the display. Note that multiple displays can have the same bounds - think mirroring. */
CG_EXTERN CGError CGSGetDisplayRegion(CGDirectDisplayID display, CGSRegionObj *outRegion);
CG_EXTERN CGError CGSGetDisplayBounds(CGDirectDisplayID display, CGRect *outRect);

/*! Gets the number of bytes per row. */
CG_EXTERN CGError CGSGetDisplayRowBytes(CGDirectDisplayID display, int *outRowBytes);

CG_EXTERN_C_END