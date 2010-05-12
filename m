From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4][cr]: Add uid, euid params to f_modown()
Date: Wed, 12 May 2010 16:12:58 -0400
Message-ID: <4BEB0BCA.6060009__31181.0726103888$1273695205$gmane$org@cs.columbia.edu>
References: <1273617500-13653-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1273617500-13653-2-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100512170513.GD19314@shareable.org>
	<20100512173048.GC11144@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100512173048.GC11144-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> Jamie Lokier [jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org] wrote:
> | Sukadev Bhattiprolu wrote:
> | > Checkpoint/restart of file-owner.
> | > 
> | > Add uid, euid parameters to f_modown(). These parameters will be needed
> | > when restarting an application (and hence restoring the file information),
> | > from a checkpoint image.
> | 
> | This is used to make sure I/O signals on sockets, ttys, devices and so
> | on are delivered to a particular process.
> 
> Good point.
> | 
> | If any of those signals are lost when an event happens around the same
> 
> Well, signals are not lost across C/R - if they were pending at
> checkpoint, they will be pending on restart.
> 
> | time as c/r (for example, more data arriving on a pipe, a device
> | becomes readable/writable, or room becoming available to write, or
> | urgent data on a socket), a process depending on it can get stuck -
> | unless the process knows that c/r happened, so it knows to call
> | select() on all those fds after the c/r.
> 
> Real devices like ttys are still TBD from C/R perspective - so data
> arriving from the tty is still a problem. Applications using such
> devices cannot be checkpointed.
> 
> But for pipes, (and sockets ?) we expect that both ends are checkpointed
> as a container. So before the container is frozen for checkpoint, either
> both the write() and SIGIO (due to new data on the pipe) both happen or
> neither.

To elaborate on this:

1) In a "full-container" checkpoint, everything must belong to the
container. Thus, pipes, sockets, and ptys are either all-in or
entirely out, and are inactive when the container is frozen - so
will not generate signals.

2) Only virtual devices can be checkpointed. Use of physical devices
will cause the checkpoint to fail. For instance, c/r supports ptys,
but not ttys. Virtual devices will have to behave nicely.

3) For network devices, the network must be frozen (in the case of
checkpoint for migration) in addition to the container. This protects
against signals due to incoming data (SIGIO, SIGURG).

4) The state of timers is saved atomically with signals.

5) Processes that waited in select/poll when checkpointed, will be
forced to re-invoke the syscall once restart succeeds.

----

All that said, it is still useful sometimes for userspace to learn
about a checkpoint or restart that took place. I plan to add some
interface by which a program can request to be notified about such
events (e.g. by a signal).

Oren.
