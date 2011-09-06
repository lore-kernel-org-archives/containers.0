From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 6/6] freezer: kill unused set_freezable_with_signal()
Date: Wed, 7 Sep 2011 00:53:32 +0900
Message-ID: <20110906155332.GF18425__3769.82958191565$1315324465$gmane$org@mtj.dyndns.org>
References: <1314988070-12244-1-git-send-email-tj@kernel.org>
	<1314988070-12244-7-git-send-email-tj@kernel.org>
	<20110904184626.GA30101@redhat.com>
	<20110905023315.GB9807@htj.dyndns.org>
	<20110905162012.GA4445@redhat.com>
	<20110906032846.GA18425@mtj.dyndns.org>
	<20110906151836.GA15568@redhat.com>
	<20110906152539.GA16899@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110906152539.GA16899-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Tue, Sep 06, 2011 at 05:25:39PM +0200, Oleg Nesterov wrote:
> On 09/06, Oleg Nesterov wrote:
> >
> > Yes, agreed. In this case I think it should be
> >
> > 	#define wait_event_freezable(wq, condition)				\
> > 	({									\
> > 		int __retval;							\
> > 		for (;;) {							\
> > 			__retval = wait_event_interruptible(wq, 		\
> > 					(condition) || freezing(current));	\
> > 			if (__retval || (condition))				\
> > 				break;						\
> > 			try_to_freeze();					\
> > 		}								\
> > 		__retval;							\
> > 	})
> >
> > __retval/ERESTARTSYS is only needed for kthreads which play with allow_signal(),
> > probably nobody should do this.
> 
> I meant, unless the caller plays with allow_signal(), it has all rights to do
> 
> 	if (wait_event_freezable(...))
> 		BUG();
> 
> This becomes correct with the code above.

Yeap, sure, w/ freezable_with_signal gone, the above should work fine.
Care to create a patch?

Thanks.

-- 
tejun
