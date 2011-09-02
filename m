From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH pm-freezer 1/4] cgroup_freezer: fix freezer->state
	setting bug in freezer_change_state()
Date: Sat, 3 Sep 2011 02:31:27 +0900
Message-ID: <20110902173127.GA3083__44336.4465180368$1314984781$gmane$org@htj.dyndns.org>
References: <20110831102100.GA2828@mtj.dyndns.org>
	<20110902004231.GF1919@count0.beaverton.ibm.com>
	<20110902165839.GA7478@redhat.com>
	<20110902170844.GJ2752@htj.dyndns.org>
	<20110902171517.GA8247@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110902171517.GA8247-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Fri, Sep 02, 2011 at 07:15:17PM +0200, Oleg Nesterov wrote:
> > I guess it depends on the viewpoint.  A simple analogy would be using
> > WARN_ON_ONCE() instead of BUG_ON() so that the mode of failure is
> > softer.  This change isn't likely to make bugs significantly more
> > difficult to discover so why not?
> 
> I agree either way.
> 
> Personally I prefer your current patch. Because it is not clear why
> do we call try_to_freeze_cgroup() if it was already called. And, the
> 2nd call can silently hide the problem if we have some bug.
> 
> But of course, this is up to you and Matt.

I'm okay either way too.  It would make a bug in that area a bit less
annoying and thus may decrease the chance of bug report, but it means
that we ship with built-in easy work around (if it doesn't work at the
first kick, kick again), which can be beneficial in practice.

> > > But I agree either way. Rafael, I think 1-4 are fine, but I think
> > > we need the simple 5/4, will send in a minute...
> >
> > Can you please wait a bit?  The second one was broken (missing unlock)
> 
> Yes, I just noticed the small problem too, hopefully we mean the same
> bug ;)

Yeap, the same one.  I thought it was the second patch instead of the
third. :)

Thanks.

-- 
tejun
