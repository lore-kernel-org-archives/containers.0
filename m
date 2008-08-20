From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] [RFC][PATCH 1/4] checkpoint-restart: general
	infrastructure
Date: Wed, 20 Aug 2008 12:10:45 -0700
Message-ID: <1219259445.8960.45.camel__39234.9448790357$1219259740$gmane$org@nimitz>
References: <20080807224033.FFB3A2C1@kernel>
	<20080807224034.735B1F84@kernel>  <48A94061.8040206@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48A94061.8040206-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2008-08-18 at 13:26 +0400, Pavel Emelyanov wrote: 
> > diff -puN /dev/null ckpt/ckpt_hdr.h
> > --- /dev/null	2007-04-11 11:48:27.000000000 -0700
> > +++ linux-2.6.git-dave/ckpt/ckpt_hdr.h	2008-08-07 15:37:22.000000000 -0700
> > @@ -0,0 +1,69 @@
> > +/*
> > + *  Generic container checkpoint-restart
> > + *
> > + *  Copyright (C) 2008 Oren Laadan
> > + *
> > + *  This file is subject to the terms and conditions of the GNU General Public
> > + *  License.  See the file COPYING in the main directory of the Linux
> > + *  distribution for more details.
> > + */
> > +
> > +#include <linux/types.h>
> > +
> > +struct cr_hdr {
> > +	__s16 type;
> > +	__s16 len;
> > +	__u32 id;
> > +};
> 
> Sorry for probably being out-of-date again, but isn't it better to
> put these headers in the include/linux and export them to the user
> space?
> 
> Why? Because we'll need some image-dumping tool (let alone the
> image converting one for compatibility purposes) and these tools
> would require to know how the image looks like.

What's the deal with headers being exported these days?  Don't we always
have to sanitize them before we ship them over to userspace anyway?

-- Dave
