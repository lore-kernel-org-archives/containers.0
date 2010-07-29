From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Remaining work for userns (WAS Re: [PATCH 3/3] cgroup : remove
	the ns_cgroup)
Date: Thu, 29 Jul 2010 18:23:52 -0500
Message-ID: <20100729232352.GC13902__47391.6580704556$1280445835$gmane$org@hallyn.com>
References: <20100729195629.GA13378@hallyn.com>
	<20100729195812.GB19015@hallyn.com>
	<20100729214008.GA2785@count0.beaverton.ibm.com>
	<20100729223957.GA12387@hallyn.com>
	<20100729230052.GB2785@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100729230052.GB2785-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Thu, Jul 29, 2010 at 05:39:57PM -0500, Serge E. Hallyn wrote:
> > Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > > On Thu, Jul 29, 2010 at 02:58:12PM -0500, Serge E. Hallyn wrote:
> 
> <snip>
> 
> > 
> > BTW in the past the only reason I saw for keeping ns cgroup was
> > to lock tasks into a devices cgroup.  Until that lazy guy who was
> > going to do it gets off his butt and implements user namespaces,
> > you'll just have to use LSMs, which is the right way.
> 
> And the only missing piece of userns is replacing the cred checks
> right? If so, it might be possible to come up with a coccinelle semantic
> patch which would do all/most of the hard work -- depends on whether the
> all the checks fit a small number of semantic patterns.

I think the thing that always puts the brakes on when I get started
is siginfo_t.  We need some way to reference user namespaces in there,
without enforcing lifetime rules on siginfo.

What you mention is definately a chunk as well, so if you are interested
in pursuing that that'd be great.

Also, reviewing the patches at the top of
http://git.kernel.org/?p=linux/kernel/git/sergeh/linux-cr.git;a=shortlog;h=refs/heads/userns.feb16.1
to give us some fresh feedback on the general approach is
valuable.

And from there, the whole discussion (which we've had several times
in the past) about how to have the VFS map userids should probably be
had again.  (I believe august 2008 was the last time we really got
into that)

thanks,
-serge
