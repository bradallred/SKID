/*
 * CGSMisc.h
 *
 * Created by Joe Ranieri on 7/23/07.
 * Copyright 2007 Alacatia Labs. All rights reserved.
 *
 */

#pragma once
#include "CGSConnection.h"

CG_EXTERN_C_BEGIN

/*! Gets whether the display is zoomed. I'm not sure why there's two calls that appear to do the same thing - I think CGSIsZoomed calls through to CGSDisplayIsZoomed. */
CG_EXTERN bool CGSDisplayIsZoomed(void);
CG_EXTERN CGError CGSIsZoomed(CGSConnectionID cid, bool *outIsZoomed);

/*! Gets and sets the cursor scale. The largest the Universal Access prefpane allows you to go is 4.0. */
CG_EXTERN CGError CGSGetCursorScale(CGSConnectionID cid, float *outScale);
CG_EXTERN CGError CGSSetCursorScale(CGSConnectionID cid, float scale);

/*! Gets and sets the state of screen inversion. */
CG_EXTERN bool CGDisplayUsesInvertedPolarity(void);
CG_EXTERN void CGDisplaySetInvertedPolarity(bool invertedPolarity);

/*! Gets and sets whether the screen is grayscale. */
CG_EXTERN bool CGDisplayUsesForceToGray(void);
CG_EXTERN void CGDisplayForceToGray(bool forceToGray);

/*! Sets the display's contrast. There doesn't seem to be a get version of this function. */
CG_EXTERN CGError CGSSetDisplayContrast(float contrast);

CG_EXTERN_C_END