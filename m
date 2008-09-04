From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v3][PATCH 2/9] General infrastructure for checkpoint restart
Date: Thu, 4 Sep 2008 11:00:00 -0500
Message-ID: <20080904160000.GB19364@us.ibm.com>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040402170.5982@takamine.ncl.cs.columbia.edu>
	<20080904091230.GW14473@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080904091230.GW14473-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Louis Rilling (Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org):
> On Thu, Sep 04, 2008 at 04:02:38AM -0400, Oren Laadan wrote:
> >
> > Add those interfaces, as well as helpers needed to easily manage the
> > file format. The code is roughly broken out as follows:
> >
> > checkpoint/sys.c - user/kernel data transfer, as well as setup of the
> > checkpoint/restart context (a per-checkpoint data structure for
> > housekeeping)
> >
> > checkpoint/checkpoint.c - output wrappers and basic checkpoint handling
> >
> > checkpoint/restart.c - input wrappers and basic restart handling
> >
> > Patches to add the per-architecture support as well as the actual
> > work to do the memory checkpoint follow in subsequent patches.
> >
> 
> [...]
> 
> > diff --git a/include/linux/ckpt_hdr.h b/include/linux/ckpt_hdr.h
> > new file mode 100644
> > index 0000000..629ad5a
> > --- /dev/null
> > +++ b/include/linux/ckpt_hdr.h
> > @@ -0,0 +1,82 @@
> > +#ifndef _CHECKPOINT_CKPT_HDR_H_
> > +#define _CHECKPOINT_CKPT_HDR_H_
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
> > +#include <linux/utsname.h>
> > +
> > +/*
> > + * To maintain compatibility between 32-bit and 64-bit architecture flavors,
> > + * keep data 64-bit aligned: use padding for structure members, and use
> > + * __attribute__ ((aligned (8))) for the entire structure.
> > + */
> > +
> > +/* records: generic header */
> > +
> > +struct cr_hdr {
> > +	__s16 type;
> > +	__s16 len;
> > +	__u32 parent;
> > +};
> > +
> > +/* header types */
> > +enum {
> > +	CR_HDR_HEAD = 1,
> > +	CR_HDR_STRING,
> > +
> > +	CR_HDR_TASK = 101,
> > +	CR_HDR_THREAD,
> > +	CR_HDR_CPU,
> > +
> > +	CR_HDR_MM = 201,
> > +	CR_HDR_VMA,
> > +	CR_HDR_MM_CONTEXT,
> > +
> > +	CR_HDR_TAIL = 5001
> > +};
> > +
> > +struct cr_hdr_head {
> > +	__u64 magic;
> > +
> > +	__u16 major;
> > +	__u16 minor;
> > +	__u16 patch;
> > +	__u16 rev;
> > +
> > +	__u64 time;	/* when checkpoint taken */
> > +	__u64 flags;	/* checkpoint options */
> > +
> > +	char release[__NEW_UTS_LEN];
> > +	char version[__NEW_UTS_LEN];
> > +	char machine[__NEW_UTS_LEN];
> > +} __attribute__((aligned(8)));
> > +
> > +struct cr_hdr_tail {
> > +	__u64 magic;
> > +} __attribute__((aligned(8)));
> > +
> > +struct cr_hdr_task {
> > +	__u64 state;
> > +	__u32 exit_state;
> > +	__u32 exit_code, exit_signal;
> 
> 64bits alignment issue?
> I probably missed it in previous versions...

In the first version it was followed by two __u16's (pid and tgid)...

-serge
