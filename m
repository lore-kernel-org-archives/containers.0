From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] freezer: kill unused set_freezable_with_signal()
Date: Tue, 6 Sep 2011 17:18:36 +0200
Message-ID: <20110906151836.GA15568__42370.1212894686$1315322576$gmane$org@redhat.com>
References: <1314988070-12244-1-git-send-email-tj@kernel.org>
	<1314988070-12244-7-git-send-email-tj@kernel.org>
	<20110904184626.GA30101@redhat.com>
	<20110905023315.GB9807@htj.dyndns.org>
	<20110905162012.GA4445@redhat.com>
	<20110906032846.GA18425@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110906032846.GA18425-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

On 09/06, Tejun Heo wrote:
>
> Hello,
>
> On Mon, Sep 05, 2011 at 06:20:12PM +0200, Oleg Nesterov wrote:
> > Perhaps it is correct... Just I do not understand what it should do.
> > I thought it is "wait_for_event && do_not_block_freezer". And at first
> > glance the code looks as if it tries to do this. Say, in the "likely"
> > case we restart wait_event_interruptible() after refrigerator().
> >
> > But this looks racy. Suppose that freezing() is already false when
> > try_to_freeze() or __refrigerator() is called. Say, cgroup_freezer does
> > freeze_task() + __thaw_task(). Why it returns -ERESTARTSYS in this case?
>
> It may return -ERESTARTSYS when not strictly necessary but given that
> it's supposed to trigger restart anyway I don't think it's actually
> broken (it doesn't break the contract of the wait).

OK, but still this doesn't look right.

> Another thing to
> note is that kthread freezing via cgroup is almost fundamentally
> broken.

OK, let it be freeze_processes()+thaw_tasks(). Of course this is mostly
theoretical.

> > And if it can be used by the userspace thread, then we should probably
> > do recalc_sigpending() somewhere, otherwise wait_event_freezable() will
> > always return -ERESTARTSYS after __refrigerator().
>
> Thankfully, currently, all the few users are kthreads.  I don't think
> it makes sense for userland tasks at all.

Yes, agreed. In this case I think it should be

	#define wait_event_freezable(wq, condition)				\
	({									\
		int __retval;							\
		for (;;) {							\
			__retval = wait_event_interruptible(wq, 		\
					(condition) || freezing(current));	\
			if (__retval || (condition))				\
				break;						\
			try_to_freeze();					\
		}								\
		__retval;							\
	})

__retval/ERESTARTSYS is only needed for kthreads which play with allow_signal(),
probably nobody should do this.

Oleg.
