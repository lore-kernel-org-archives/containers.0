From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Containers and /proc/sys/vm/drop_caches
Date: Fri, 7 Jan 2011 09:12:41 -0600
Message-ID: <20110107151241.GB4962@hallyn.com>
References: <20110105094022.GA5366@glandium.org> <4D243EC3.1050101@free.fr>
	<20110105140159.GC2718@hallyn.com>
	<AANLkTi=x=6gUZTxJC8LXxYNu029+firyzKqjMa6m+R-x@mail.gmail.com>
	<20110106214315.GJ29064@count0.beaverton.ibm.com>
	<4D270F34.8080305@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D270F34.8080305-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Rob Landley (rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> On 01/06/2011 03:43 PM, Matt Helsley wrote:
> > On Wed, Jan 05, 2011 at 07:46:17PM +0530, Balbir Singh wrote:
> >> On Wed, Jan 5, 2011 at 7:31 PM, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> >>> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> >>>> On 01/05/2011 10:40 AM, Mike Hommey wrote:
> >>>>> [Copy/pasted from a previous message to lkml, where it was suggested to
> >>>>>  try containers@]
> >>>>>
> >>>>> Hi,
> >>>>>
> >>>>> I noticed that from within a lxc container, writing "3" to
> >>>>> /proc/sys/vm/drop_caches would flush the host page cache. That sounds a
> >>>>> little dangerous for VPS offerings that would be based on lxc, as in one
> >>>>> VPS instance root user could impact the overall performance of the host.
> >>>>> I don't know about other containers but I've been told openvz isn't
> >>>>> subject to this problem.
> >>>>> I only tested the current Debian Squeeze kernel, which is based on
> >>>>> 2.6.32.27.
> >>>>
> >>>> There is definitively a big work to do with /proc.
> >>>>
> >>>> Some files should be not accessible (/proc/sys/vm/drop_caches,
> >>>> /proc/sys/kernel/sysrq, ...) and some other should be virtualized
> >>>> (/proc/meminfo, /proc/cpuinfo, ...).
> >>>>
> >>>> Serge suggested to create something similar to the cgroup device
> >>>> whitelist but for /proc, maybe it is a good approach for denying
> >>>> access a specific proc's file.
> >>>
> >>> Long-term, user namespaces should fix this - /proc will be owned
> >>> by the user namespace which mounted it, but we can tell proc to
> >>> always have some files (like drop_caches) be owned by init_user_ns.
> 
> Changing ownership so a script can't open a file that it otherwise
> could may cause scripts to fail when run in a container.  Makes the
> containers less transparent.

While my goal next week is to make containers more transparent, the
official stance from kernel summit a few years ago was:  transparent
containers are not a valid goal (as seen from kernel).

Not saying that what you're saying above is wrong, but I *do* argue
that 'silently ignoring the write' is more wrong than refusing the
write :)  Fooling userspace is a lose, imo.

Also, we can use a FUSE fs over proc to hide the files.  Doing that
now is insufficient because root in the container can just remount
proc over the filter.  But after user namespaces, root in the container
has the choice of leaving the filter in place for the sake of his own
usespace, or removing it and getting a bunch of files he can't use.

...

> A heavily loaded system that goes deep into swap without triggering
> the OOM killer can become pretty useless.  My home laptop with 2 gigs

Isn't a cgroup that controls both memory and swap access the right
answer to this?  (And do we have that now, btw?)

(I'm doing too many things at once so probably not thinking this
through enough)

-serge
