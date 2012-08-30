From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Virtualizing /proc/sys/kernel/random/boot_id per container ?
Date: Thu, 30 Aug 2012 15:15:17 -0700
Message-ID: <878vcwjabu.fsf@xmission.com>
References: <20120830211832.GA3297@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120830211832.GA3297-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Daniel P. Berrange's message
	of "Thu, 30 Aug 2012 14:18:32 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

"Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> One of the features that SystemD folks have asked us to fix in LXC, is
> to make sure that /proc/sys/kernel/random/boot_id changes each time a
> container is started.

There may be a good reason for this.  Most of the time what I have seen
of kernel requests from the direction of SystemD is that while there may
be a real problem but usually their imagined solution is not a
particularly good solution.  So a description of the problem is needed.

Justifying something with just SystemD wants this is a good way to get
a nack.

> The current semantics are that this file produces a new random UUID each
> time the host OS is booted. Obviously each time we start a container now,
> they just see the host's random boot_id, so from a container's POV this
> does not change each time it starts.

That is correct.  As I recall the contract with boot_id is to provide
a unique per boot value to assist in dealing with boots etc.  I seem
to recall emacs uses the combination of hostname+boot_id to help
generate unique lock files names.

I would definitely need a refresher on how boot_id is used in practice
by applications other than SystemD before I could suggest a good design.

There is also a question of uptime.

> There seems to be general agreement that, aside from the PID directories,
> changes to data in  proc should be done by a FUSE filesystem overlay of
> some kind.

No.  I have yet to see a justification for using FUSE in containers on
top of proc files.

I have seen a lot of bad ideas suggested like hacking /proc/cpuinfo
instead of providing a proper mechanism to tell applications how
parallel they can/should be.

For hacks and controversial ideas FUSE is good because it makes it
someone else's problem and it means it isn't something we have to
support in the kernel for the indefinite future.  At the same time in
general a FUSE solution does not really solve anything it just sort of
papers over a problem.

For some problems papering over them is good enough, for other problems
they really should be solved properly.

> We could use that mechanism to fix 'boot_id' in userspace, but
> I'm wondering if this is a better candidate for dealing with in kernel
> space, since as well as the /proc/sys tree, the data is also visible via
> the sysctl() system call which a FUSE overlay won't address.

Any application that uses the sysctl() system call needs to be fixed.
When I looked years ago the number of applications using sysctl() could
be numbered on one hand and most of those applications were the fedora
installer, and the fedora installer hasn't used sysctl.

> The kernel doesn't have a real concept of a 'container' to associate
> a boot_id value with as such, but maybe it is reasonable to associate
> a boot_id value with each PID namespace ?

There is also the question of uptime and clocks and things like that.

The utsnamespace might be a more resasonable place to tack on that kind
of extended functionality.

Just changing boot_id itself and not all of the other bits that track
when we have booted does not seem reasonable.

Once we can sort out the details a kernel implementation should be quite
trivial.  It just requires the appropriate sysctl registration dance.

Eric
