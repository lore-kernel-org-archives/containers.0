From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: kernel based checkpoint/restart: about X windows application
	checkpoint and restart support.
Date: Wed, 28 Oct 2009 11:02:43 -0400
Message-ID: <4AE85D13.9030108@librato.com>
References: <20091028084717.GO31446@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091028084717.GO31446-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Will Huang <will.huang-lvxLlxTUKJQIhP1ydL5T/A@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Wed, Oct 28, 2009 at 10:51:32AM +0800, Will Huang wrote:
>> Dear All,
>>
>>          Did the Kernel based checkpoint/restart patch support X windows
>> application such as firefox?
> 
> No, and I think it may be a long time before that happens.

In short: not yet, but we're getting closer.

For me details, let me first give some background: to successfully
restart an application that is not checkpoint/restart aware, we must
provide the application with everything it would have expected if
it were running originally. For instance, given a process, we also
need its children, the pipes between them, IPC shared memory, and
so on.

For this reason, we checkpoint groups of processes (and threads),
either a whole container or just a subtree of processes. A whole
container is preferable because it isolates the application and
makes it easier to ensure that we do include all the dependencies
of the application in the checkpoint.

Now back to your question: X applications cannot be checkpointed
standalone (unless, of course, X windows is modified for that).
Instead, one must checkpoint the entire user session, including
the X server itself.

The main problem is that the X server is "talking" to the bare
hardware, and the task of recording the specific hardware state
and restoring it later is daunting, and becomes impossible if the
session is to be restarted on different hardware.

The solution is to not run the regular X server. Instead, start
a virtual X server, such as VNC, and run the user session in it.
The main difference is that VNC server does not directly use any
hardware resources, so it is not tied to specific hardware state.
From the user's point of view - this setup is transparent with
suitable use of a VNC client.

If the VNC server is launched inside a new container, then that
server and all the applications running in that session become
isolated from the rest of the system, and you can checkpoint and
then restart them later. (This assumes, of course, that their
view of the file system does not change between checkpoint and
restart).

So now the question becomes: does the checkpoint/restart patch
support VNC, window managers (e.g. gnome, kde, etc), and then
X applications ?

The answer, from above, is that we're almost there. There are
still some features that are used by common desktop applications
and whose checkpoint/restart logic is in the works (e.g. inotify),
and we also need rudimentary support for checkpoint/restart of
files in opened in procfs (/proc/...).

We're working on it ... stay tuned :)

Oren.

> 
> (Disclaimer: I haven't even tried to see what part of checkpointing
> X breaks first. I suspect it'd be the open device files...)
> 
> The display and input device hardware presents a serious challenge for 
> one thing. They may not be available during restart if it occurs
> on a different machine -- or they may be entirely different hardware. 
> 
> Perhaps checkpoint/restart of programs with these devices open should
> "simulate" hot-[un]plug. Checkpoint could save enough information to make
> the kernel generate the necessary uevents. At restart the file
> descriptors for those devices are never opened and syscalls on them will
> return errno==EBADF. Next we'd need to send uevents for the
> "new-but-not-new" devices. There's a "new-but-not-new" uevent pathway in
> the kernel used during boot -- perhaps there's some way to reuse that.
> Lastly, we send the unplug uevents to get X to drop its use of the old
> devices -- send those last so X always thinks there's hardware.
> 
> That's one way it _could_ be done. Others might rely on device
> "virtualization" -- writing pseudo-device code (CUSE?).
> 
> X also has its own session support. As far as I know how that could
> work with kernel-based checkpoint/restart hasn't been discussed yet.
> 
> Of course this is all off the top of my head. Others are welcome to
> make considerate use of cluebats to inform me of any misconceptions I
> may have.
> 
> Cheers,
> 	-Matt Helsley
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
