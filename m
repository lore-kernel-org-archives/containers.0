From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 6/6][v3] Protect cinit from blocked fatal signals
Date: Tue, 23 Dec 2008 01:03:56 +0100
Message-ID: <20081223000356.GB7279@redhat.com>
References: <20081221005106.GA4912@us.ibm.com>
	<20081221005529.GF5025@us.ibm.com>
	<20081222225825.GC1536@redhat.com>
	<20081222233855.GA13079@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081222233855.GA13079-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/22, Sukadev Bhattiprolu wrote:
>
> Oleg Nesterov [oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org] wrote:
> | > @@ -1907,9 +1943,10 @@ relock:
> | >
> | >  		/*
> | >  		 * Global init gets no signals it doesn't want.
> | > +		 * Container-init gets no signals it doesn't want from same
> | > +		 * container.
> | >  		 */
> | > -		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
> | > -		    !signal_group_exit(signal))
> | > +		if (sig_unkillable(signal, signr) && !signal_group_exit(signal))
> | >  			continue;
> | 
> | Again, I do not understand why do we need SIGNAL_UNKILLABLE_FROM_NS.
> | 
> | I thought about the change in get_signal_to_deliver() during the
> | previous discussion, and I think what we need is:
> | 
> | 		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
> | 		    !sig_kernel_only(sig))
> | 			continue;
> | 
> | and this was yet another reason for "protect init from unwanted signals more".
> 
> I was trying to avoid the clearing of the SIGNAL_UNKILLABLE in
> send_signal() that we had last time.

Well, my plan was to simplify the first series of patches as much
as possible, then I thought we can change get_signal_to_deliver().

But now I tend to agree, we should not clear SIGNAL_UNKILLABLE when
we send the signal, and we should pass same_ns/from_parent_ns to
prepare_signal() from the start. This way is more "clean".

> But yes, you are right. I even had a BUG_ON() to confirm SIGKILL/SIGSTOP
> will never happen for global-init :-). If so, SIGKLL/SIGSTOP to an init
> can come only from parent ns.
>
> So, yes, we can drop this flag.

Great!

Oleg.
