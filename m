From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Thu, 3 Nov 2011 13:08:56 -0700
Message-ID: <20111103200856.GK21134@count0.beaverton.ibm.com>
References: <20111103162238.27609.11515.stgit@rabbit.intern.cm-ag>
	<4EB2C4A5.6000406@parallels.com>
	<20111103165903.GA4755@Debian-60-squeeze-64-minimal>
	<20111103182101.5037c1e5@lxorguk.ukuu.org.uk>
	<20111103185108.GA5153@Debian-60-squeeze-64-minimal>
	<4EB2E3E6.6070401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4EB2E3E6.6070401-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Nov 03, 2011 at 04:56:38PM -0200, Glauber Costa wrote:
> On 11/03/2011 04:51 PM, Max Kellermann wrote:
> >On 2011/11/03 19:21, Alan Cox<alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>  wrote:
> >>>After little discussion, nobody seemed to be interested in it, and
> >>>nobody merged it.  I reposted it today, not knowing somebody else had
> >>>come up with a similar idea meanwhile.
> >>
> >>I don't really see a meaningful use case for this. Why should millions of
> >>users have this stuff in their kernel. What's the general purpose use
> >>case we should all be excited about ?
> >
> >Putting a reasonable limit on jobs that are expected to run only for a
> >limited amount of time, with a limited amount of total resources.  For
> >example: CGI, cron jobs, backup, munin plugins, virus scanners and
> >other email filters, procmail, ... - when the job is done, the group
> >can be deleted, and new instances will run in a new group.
> >
> >With just RLIMIT_NPROC or task_counter, you can limit the total number
> >of processes, but it will not stop a fork bomb - it will only slow it
> >down.  The fork bomb will still bounce between 1 and the limit, and
> >consume lots of resources for forking and exiting.
> >
> >(Glauber: the above should answer your last email, too)
> 
> Yet, the damage a fork bomb can pose into the system this way is
> severely limited. Combined with the cpu controller to guarantee that
> this group of process will never take the whole cpu for themselves,
> you have almost everything you need, if not everything.

Assuming we're only talking about fork bombs, I tend to agree.
Using Frederic's cgroup subsystem we can adjust the limit to the number of
legitimate tasks in the cgroup (0 if you can't distinguish them) and then
start killing the fork bombs. If the forkbomb goes into a fork-then-exit
loop in order to eat cpu once it's reached the task limit the cpu
controller becomes more useful.

However, isn't it possible that forking an extra task could be a sign of
a security issue other than a fork bomb? Imagine a CGI module that could
set the fork limit (not number of tasks) to the precise or maximum
number of tasks that CGI script should create (perhaps a per-script
limit known and configured somewhere by an admin). If the CGI script
attempts to go over that limit it could be a sign of an exploit attempt.
The fork limit could prevent the CGI script from creating a shell with
unintended privileges. Or the shell might be created but no non-builtin
commands could be executed. The exploit would not be able to kill an
existing task to make room. Anyhow, that's purely hypothetical --
I can imagine a use for this feature but I don't know that it's
been implemented or how practical it really is. Also, depending on how
such a CGI module+script drops privileges, there still may be acceptable
alternatives like syscall filtering...

Cheers,
	-Matt Helsley
