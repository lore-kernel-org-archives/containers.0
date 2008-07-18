From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Devel] [RFC PATCH 0/5] Resend -v2 - Use procfs to change
	a	syscall behavior
Date: Thu, 17 Jul 2008 19:40:45 -0700
Message-ID: <m1hcanoqxe.fsf@frodo.ebiederm.org>
References: <20080708112422.164370000@bull.net>
	<20080709221028.GA4926@martell.zuzino.mipt.ru>
	<m1tzeyd0x3.fsf@frodo.ebiederm.org> <487FCAF0.70607@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <487FCAF0.70607-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of "Thu,
	17 Jul 2008 18:42:56 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:

> I think the kernel space vs. user space must be the first issue on our
> table to solve, as it has a wide impact on the rest of the work.

We first need to talk about what kinds of problems we are trying to
solve.  If we don't agree what the problem is I expect we will have a
hard time agreeing on a solution.

For example we are using namespaces now instead of the potentially
simpler isolation mechanism of Vserver because checkpoint/restart
could not be done with the Vserver approach.

The use case that I expect we all have in common is migrating
an isolated container from one machine to another transparent
to applications.  Except those that directly access the hardware
at which point we can treat it as a hotplug event from the
perspective of userspace.

There are several other interesting use cases that I think we
should solve if possible.
- Live/Incremental migration.  
- Remote fork.  Which can be seen as an extreme case of migrating
  only a partial container.
- A checkpoint that can be restarted multiple times and work properly.
  Which means you need to include the state of the filesystem.
- A distributed checkpoint of multiple containers at the same time.

Given how brutally hard and inefficient it is to restore a checkpoint
using the existing system calls even with namespaces in the kernel.  We
can pretty much rule that implementation out as it does not match
our efficiency criteria, and likely isn't especially maintainble either.

On the maintenance side we can generally rule out an out of tree module.
As that does not afford visible to people changing a subsystem that the
checkpoint/restart code needs to change as well.

I believe the live migration will have the most stringent performance
requirements and at the same time be one of the most useful features,
as it immediately improve maintenance of clusters.

In the extreme case of a distributed checkpoint the kernel simply does
not have enough state so we need user space code coordinating all of
the pieces.

For a multi-start checkpoint I expect userspace will be coordinating
filesystem snapshots and checkpoints.

Eric
