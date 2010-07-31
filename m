From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Remaining work for userns
Date: Fri, 30 Jul 2010 17:23:26 -0700
Message-ID: <m139v0ts75.fsf_-___17611.8600917563$1280535852$gmane$org@fess.ebiederm.org>
References: <20100729195629.GA13378@hallyn.com>
	<20100729195812.GB19015@hallyn.com>
	<20100729214008.GA2785@count0.beaverton.ibm.com>
	<20100729223957.GA12387@hallyn.com>
	<20100729230052.GB2785@count0.beaverton.ibm.com>
	<20100729232352.GC13902@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100729232352.GC13902-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Thu\, 29 Jul 2010 18\:23\:52 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> On Thu, Jul 29, 2010 at 05:39:57PM -0500, Serge E. Hallyn wrote:
>> > Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> > > On Thu, Jul 29, 2010 at 02:58:12PM -0500, Serge E. Hallyn wrote:
>> 
>> <snip>
>> 
>> > 
>> > BTW in the past the only reason I saw for keeping ns cgroup was
>> > to lock tasks into a devices cgroup.  Until that lazy guy who was
>> > going to do it gets off his butt and implements user namespaces,
>> > you'll just have to use LSMs, which is the right way.
>> 
>> And the only missing piece of userns is replacing the cred checks
>> right? If so, it might be possible to come up with a coccinelle semantic
>> patch which would do all/most of the hard work -- depends on whether the
>> all the checks fit a small number of semantic patterns.
>
> I think the thing that always puts the brakes on when I get started
> is siginfo_t.  We need some way to reference user namespaces in there,
> without enforcing lifetime rules on siginfo.

As I recall signal delivery in the kernel lands the signal in the
queue of the destination process before the syscall returns.  If that
is true we should be able to handle signal delivery by just doing
whatever conversions are needed during delivery.

aka the userns should just be task->nsproxy->user_ns for
task->signal->queue.  We cannot unshare the user namespace so there
are no nasty races.

I am reminded that I may want to play with the user namespace and
unshare when I get setns refresh and reviewed for inclusion.  Still
none of that should affect the fact that a task should never be
able to change user namespaces.

> What you mention is definately a chunk as well, so if you are interested
> in pursuing that that'd be great.
>
> Also, reviewing the patches at the top of
> http://git.kernel.org/?p=linux/kernel/git/sergeh/linux-cr.git;a=shortlog;h=refs/heads/userns.feb16.1
> to give us some fresh feedback on the general approach is
> valuable.
>
> And from there, the whole discussion (which we've had several times
> in the past) about how to have the VFS map userids should probably be
> had again.  (I believe august 2008 was the last time we really got
> into that)

We now have user_ns_map_uid and user_ns_map_gid in next-next.git
Serge I'm not certain how that interacts with your other work, but
it is definitely something we want to build on.

Eric
