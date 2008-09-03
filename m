From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/9] Introduce context structure needed during
	checkpointing/restart
Date: Wed, 3 Sep 2008 18:07:10 +0400
Message-ID: <200809031807.11053.major@openvz.org>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1220439476-16465-4-git-send-email-major@openvz.org>
	<20080903135616.GR14473@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080903135616.GR14473-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wednesday 03 September 2008 17:56 Louis Rilling wrote:
> On Wed, Sep 03, 2008 at 02:57:50PM +0400, Andrey Mirkin wrote:
> > Add functions for context allocation/destroy.
> > Introduce functions to read/write image.
> > Introduce image header and object header.
>
> [...]
>
> > diff --git a/cpt/cpt_image.h b/cpt/cpt_image.h
> > new file mode 100644
> > index 0000000..3d26229
> > --- /dev/null
> > +++ b/cpt/cpt_image.h
> > @@ -0,0 +1,63 @@
> > +/*
> > + *  Copyright (C) 2008 Parallels, Inc.
> > + *
> > + *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> > + *
> > + *  This program is free software; you can redistribute it and/or
> > + *  modify it under the terms of the GNU General Public License as
> > + *  published by the Free Software Foundation, version 2 of the
> > + *  License.
> > + *
> > + */
> > +
> > +#ifndef __CPT_IMAGE_H_
> > +#define __CPT_IMAGE_H_ 1
> > +
> > +enum _cpt_object_type
> > +{
> > +	CPT_OBJ_TASK = 0,
> > +	CPT_OBJ_MAX,
> > +	/* The objects above are stored in memory while checkpointing */
> > +
> > +	CPT_OBJ_HEAD = 1024,
> > +};
> > +
> > +enum _cpt_content_type {
> > +	CPT_CONTENT_VOID,
> > +	CPT_CONTENT_ARRAY,
> > +	CPT_CONTENT_DATA,
> > +	CPT_CONTENT_NAME,
> > +	CPT_CONTENT_REF,
> > +	CPT_CONTENT_MAX
> > +};
> > +
> > +#define CPT_SIGNATURE0 0x79
> > +#define CPT_SIGNATURE1 0x1c
> > +#define CPT_SIGNATURE2 0x01
> > +#define CPT_SIGNATURE3 0x63
> > +
> > +struct cpt_head
> > +{
> > +	__u8	cpt_signature[4];	/* Magic number */
> > +	__u32	cpt_hdrlen;		/* Header length */
> > +	__u16	cpt_image_major;	/* Format of this file */
> > +	__u16	cpt_image_minor;	/* Format of this file */
> > +	__u16	cpt_image_sublevel;	/* Format of this file */
> > +	__u16	cpt_image_extra;	/* Format of this file */
> > +	__u16	cpt_arch;		/* Architecture */
> > +	__u16	cpt_pad1;
> > +	__u32	cpt_pad2;
> > +#define CPT_ARCH_I386		0
>
> Why is this constant precisely defined after the padding?
I will move it right after cpt_arch. Thanks.

>
> > +	__u64	cpt_time;		/* Time */
> > +} __attribute__ ((aligned (8)));
> > +
> > +/* Common object header. */
> > +struct cpt_object_hdr
> > +{
> > +	__u64	cpt_len;		/* Size of current chunk of data */
> > +	__u16	cpt_type;		/* Type of object */
> > +	__u32	cpt_hdrlen;		/* Size of header */
> > +	__u16	cpt_content;		/* Content type: array, reference... */
>
> This layout looks a bit awkward for 32bits/64bits compatibility. Maybe put
> cpt_hdrlen before cpt_type?
You right here. Thanks for the catch. I will change that in next version.

Thanks,
Andrey
