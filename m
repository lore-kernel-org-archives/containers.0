From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/1] freezer: fix wait_event_freezable/__thaw_task races
Date: Sun, 11 Sep 2011 10:54:31 +0900
Message-ID: <20110911015431.GK29319__37702.9869276614$1315706186$gmane$org@htj.dyndns.org>
References: <20110905023315.GB9807@htj.dyndns.org>
	<20110905162012.GA4445@redhat.com>
	<20110906032846.GA18425@mtj.dyndns.org>
	<20110906151836.GA15568@redhat.com>
	<20110906152539.GA16899@redhat.com>
	<20110906155332.GF18425@mtj.dyndns.org>
	<20110907182156.GA13909@redhat.com>
	<20110907182217.GB13909@redhat.com>
	<20110908010530.GD3987@mtj.dyndns.org>
	<20110908175926.GA26986@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110908175926.GA26986-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Thu, Sep 08, 2011 at 07:59:26PM +0200, Oleg Nesterov wrote:
> > Indeed, nice catch.  This one actually is pretty dangerous.  We
> > probably want to make a separate fix for this and backport it to
> > -stable?
> 
> And I forgot to mention that wait_event_freezable_timeout() doesn't
> handle -ERESTARTSYS at all.
> 
> But I don't think -stable needs this fix. According to grep, nobody
> check the returned value, and none of the callers plays with signals.

Ah, no user, okay.

> > Yeap, with freezable_with_signal gone, this looks correct & simpler to
> > me
> 
> I don't really understand this... set_freezable_with_signal() has a
> lot of problems, yes... But even if it wasn't removed this fix makes
> sense anyway, afaics.
> 
> If freezable_with_signal caller does wait_event_freezable_timeout(),
> __retval becomes -ERESTARTSYS after freeze_task(). The next iteration
> will return 0 with the KERN_ERR message from schedule_timeout().

Hmmm... but with the change, if a kthread gets TIF_SIGPENDING from
freezer and then thawed, it would not enter try_to_freeze() and thus
won't clear TIF_SIGPENDING.  The original code was racy too but the
window would be much larger afterwards.  Anyways, this doesn't matter
anymore.

> > but it would be nice if you can sprinkle some documentation while
> > at it. :)
> 
> But they already have the comment ;) What can I add?

Proper /** - */ comment w/ return value documentation? :P

Thanks.

-- 
tejun
