From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 6/9][cr][v2]: Checkpoint file-locks
Date: Wed, 28 Jul 2010 19:39:13 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1007281927450.2895__27199.1578898907$1280360422$gmane$org@takamine.ncl.cs.columbia.edu>
References: <1274238452-15382-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274238452-15382-7-git-send-email-sukadev@linux.vnet.ibm.com>
	<4C16FDE7.7050709@cs.columbia.edu> <20100728192649.GB14570@us.ibm.com>
	<4C50882A.4000505@cs.columbia.edu> <20100728212950.GA10505@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100728212950.GA10505-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, matthew-Ztpu424NOJ8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 28 Jul 2010, Sukadev Bhattiprolu wrote:

> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> >
> >
> > Sukadev Bhattiprolu wrote:
> >> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> >> | | | > +	if (lock) {
> >> | > +		h->fl_start = lock->fl_start;
> >> | > +		h->fl_end = lock->fl_end;
> >> | > +		h->fl_type = lock->fl_type;
> >> | > +		h->fl_flags = lock->fl_flags;
> >> | > +	} else {
> >> | > +		/* Checkpoint a dummy lock as a marker */
> >> | > +		h->fl_start = -1;
> >> | | Maybe designate some constant for this ?  e.g. CKPT_FLOCK_NONE ?
> >> | In any case, you need a (loff_t) -1  (like in the restore code).
> >>
> >> Ok. Defining macros CKPT_HDR_SET_MARKER_LOCK() and
> >> CKPT_HDR_CHECK_MARKER_LOCK().  Also added the missing (loff_t).
> >
> > The nice thing about #define CKPT_FLOCK_NONE -1  - see also
> > the CKPT_PID_NULL, when defined in checkpoint_hdr.h, is that
> > they are intentionally visible to userspace too.
> 
> The problem is marker lock is currently identified by two fields:
> 
> 	.fl_start = -1;
> 	.fl_type = FL_POSIX.
> 
> so CKPT_FLOCK_NONE appears misleading if it only refers to one field.
> 
> Should I say CKPT_FLOCK_NONE_START and CKPT_FLOCK_NONE_TYPE ?
> 
> Or, can we make CKPT_CHECK_MARKER_LOCK() and CKPT_SET_MARKER_LOCK()
> available to user space ?

Having looked at the code again - how about the following:
get rid of this "last entry" altogether; instead, during
checkpoint, first count the locks, then write a header with
the number of locks, following by that many records of the
locks themselves.

This is what we do for other resource lists/chains as well.
Also makes it a bit easier to parse since you always know
what to expect once you see the header.

Oren.
