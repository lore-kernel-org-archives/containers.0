From: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/7][v8] SI_USER: Masquerade si_pid when crossing pid ns
	boundary
Date: Thu, 19 Feb 2009 17:06:00 -0800 (PST)
Message-ID: <20090220010600.DCEA7FC2F7@magilla.sf.frob.com>
References: <20090219030207.GA18783@us.ibm.com>
	<20090219030743.GG18990@us.ibm.com>
	<m1y6w21k6d.fsf@fess.ebiederm.org>
	<20090219185159.GA374@redhat.com>
	<m1fxiayss9.fsf@fess.ebiederm.org>
	<20090219223137.GA10378@redhat.com>
	<m1fxiaxbb5.fsf@fess.ebiederm.org>
	<20090219235159.6A542FC3BE@magilla.sf.frob.com>
	<m1bpsyt05t.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Eric W. Biederman's message of  Thursday,
	19 February 2009 16:35:58 -0800 <m1bpsyt05t.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

> It is especially useful, and this is a deliberate feature.  

Ok, I thought that might be so.

> In practice I don't care about si_pid and I doubt I care about processes
> sending signals outside of their pid namespace.  But I do care about
> sharing a tty and a session and having job control work.

Understood.

> >> pid 10 should see si_pid 12.
> >> pid 11 should see si_pid 2.
> >
> > We indeed have this problem if we think it's useful to continue to have
> > a concept of pgrp for the sub-init that can see outside its own NS.
> >
> >> Neither should see si_pid 0, as from_ancestor_ns will not be true.
> >
> > Perhaps replace from_ancestor_ns with struct pid_namespace *sender_ns?
> > (I don't know if there was already a can of worms with such an idea before.)
> > Then si_pid could be translated as appropriate for each recipient.
> > (Or perhaps just struct pid *sender and reset si_pid from that.)
> 
> The last was my original line of thinking.  I seem to recall Oleg
> figuring the code gets pretty ugly when you add in the necessary test
> to see if si_pid is actually present.

Well, the existing test to set from_ancestor_ns is in one place and we
think that its logic is OK.  What I had in mind was that when that logic
says "0", we pass NULL and the innards don't touch .si_pid (same as now);
when it says "1", we pass a pointer and the innards do rewrite it.

> There are several other cases where we also signal a process outside
> of our current pid namespace, where we have a pid inside the recipients
> pid namespace.  do_notify_parent is the easiest example.

It's the only example that Oleg has mentioned.  What others are there?

> a) We pass in struct pid *sender and we reset si_pid in send_signal.
> b) We make the rule that send_signal must receive a valid siginfo from
>    the caller and we only do the extra work for process groups.

That's what I said. ;-) The a) option seems cleaner to me regardless, to
the extent that the "from_ancestor_ns" approach is a "clean" one.  But I
think it would be best to fully elucidate what we think about desireable
semantics for the whole spectrum of cross-NS signal-sending cases before
actually choosing the implementation details.


Thanks,
Roland
