From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 6/6] freezer: kill unused set_freezable_with_signal()
Date: Tue, 6 Sep 2011 12:28:55 +0900
Message-ID: <20110906032846.GA18425__45151.7472196885$1315279814$gmane$org@mtj.dyndns.org>
References: <1314988070-12244-1-git-send-email-tj@kernel.org>
	<1314988070-12244-7-git-send-email-tj@kernel.org>
	<20110904184626.GA30101@redhat.com>
	<20110905023315.GB9807@htj.dyndns.org>
	<20110905162012.GA4445@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110905162012.GA4445-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Mon, Sep 05, 2011 at 06:20:12PM +0200, Oleg Nesterov wrote:
> Perhaps it is correct... Just I do not understand what it should do.
> I thought it is "wait_for_event && do_not_block_freezer". And at first
> glance the code looks as if it tries to do this. Say, in the "likely"
> case we restart wait_event_interruptible() after refrigerator().
> 
> But this looks racy. Suppose that freezing() is already false when
> try_to_freeze() or __refrigerator() is called. Say, cgroup_freezer does
> freeze_task() + __thaw_task(). Why it returns -ERESTARTSYS in this case?

It may return -ERESTARTSYS when not strictly necessary but given that
it's supposed to trigger restart anyway I don't think it's actually
broken (it doesn't break the contract of the wait).  Another thing to
note is that kthread freezing via cgroup is almost fundamentally
broken.  With the removal of freezable_with_signal, this shouldn't be
an issue anymore although cgroup_freezer still needs to be fixed to
account for kthreads for xstate transitions (it currently triggers
BUG_ON).

> And if it can be used by the userspace thread, then we should probably
> do recalc_sigpending() somewhere, otherwise wait_event_freezable() will
> always return -ERESTARTSYS after __refrigerator().

Thankfully, currently, all the few users are kthreads.  I don't think
it makes sense for userland tasks at all.  Interruptible sleeps for
userland tasks necessiate the ability to return to signal delivery
path and restart or abort the current operation.  There's no point in
using wait_event_freezable() instead of wait_event_interruptible().

Thanks.

-- 
tejun
