From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] [RFC][WIP] namespace.c: Allow some unprivileged proc
	mounts when not fully visible
Date: Wed, 04 Apr 2018 09:45:43 -0500
Message-ID: <87tvsrjai0.fsf__29615.3918178335$1522853120$gmane$org@xmission.com>
References: <20180404115311.725-1-alban@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180404115311.725-1-alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> (Alban Crequy's message
	of "Wed, 4 Apr 2018 13:53:11 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Iago Lopez Galeiras <iago-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Crosby <crosbymichael-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Stephen J Day <stephen.day-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jess Frazelle <acidburn-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
List-Id: containers.vger.kernel.org

Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Since Linux v4.2 with commit 1b852bceb0d1 ("mnt: Refactor the logic for
> mounting sysfs and proc in a user namespace"), new mounts of proc or
> sysfs in non init userns are only allowed when there is at least one
> fully-visible proc or sysfs mount.
>
> This is to enforce that proc/sysfs files masked by a mount are still
> masked in a new mount in a unprivileged userns. The locked mount logic
> for bind mounts (has_locked_children()) was not enough in the case of
> proc/sysfs new mounts because some files in proc (/proc/kcore) exist as
> a singleton rather than being owned by a specific proc mount.
>
> Unfortunately, this blocks me from using userns from within a Docker
> container because Docker containers mask entries such as /proc/kcore. My
> use case is to build container images with arbitrary commands (such as
> using "RUN" commands in Dockerfiles) without privileges and from within
> a Docker container. Those arbitrary commands could be shell scripts that
> require /proc.

This is an understandable problem.  /proc/kcore is a file that policy
has a very reasonable right to make inaccessible.  Allowing unprivileged
users to bypass the policy setup by root is not ok, and is the whole
point of the restrictions.


I need to hear why you can't fix Docker.  Why your subcommand needs to
mount proc in the first place.  Neither have been mentioned.  So far
this looks like ``my sysadmin told me no, can I have a kernel patch to
get around that''.  Not something I support at all.



Before we get a kernel change for something like this there need to be
clear evidence this raises to the point of something that is really
going to be used and will have multiple users, and the proposal will
be simple and maintainble.

Hiding files in /proc simply because they were mounted over in the
parent proc does not qualify as simple or maintainble by any means.
Way too much mixing of the layers.  Needing to read from the parent
proc to find which files were already hidden makes this doubly complex.

Files like /proc/kcore can not be hidden always and automatically
because their attributes can change so they may reasonably be made
available to users who are not the global root.

The only option I have seen proposed that might qualify as something
general purpose and simple is a new filesystem that is just the process
directories of proc.  As there would in essence be no files that would
need restrictions it would be safe to allow anyone to mount without
restriction.

> The following commands show my problem:
>
> $ sudo docker run -ti --rm --cap-add=SYS_ADMIN busybox sh -c 'unshare -U -r -p -m -f mount -t proc proc /home && echo ok'
> mount: permission denied (are you root?)
>
> $ sudo docker run -ti --rm --cap-add=SYS_ADMIN busybox sh -c 'mkdir -p /unmasked-proc && mount -t proc proc /unmasked-proc && unshare -U -r -p -m -f mount -t proc proc /home && echo ok'
> ok

Actually this does not show your problem because it does not reveal why
you need to mount proc.

That is a ``Doctor it hurts when I do this'' example where the Doctor
will reasonably tell you ``Don't do that then''.


> For my use case, I will need to support at least the following entries:
>
> $ sudo docker run -ti --rm busybox sh -c 'mount|grep /proc/'
> proc on /proc/asound type proc (ro,nosuid,nodev,noexec,relatime)
> proc on /proc/bus type proc (ro,nosuid,nodev,noexec,relatime)
> proc on /proc/fs type proc (ro,nosuid,nodev,noexec,relatime)
> proc on /proc/irq type proc (ro,nosuid,nodev,noexec,relatime)
> proc on /proc/sys type proc (ro,nosuid,nodev,noexec,relatime)
> proc on /proc/sysrq-trigger type proc (ro,nosuid,nodev,noexec,relatime)
> tmpfs on /proc/kcore type tmpfs (rw,context="...",nosuid,mode=755)
> tmpfs on /proc/latency_stats type tmpfs (rw,context="...",nosuid,mode=755)
> tmpfs on /proc/timer_list type tmpfs (rw,context="...",nosuid,mode=755)
> tmpfs on /proc/sched_debug type tmpfs (rw,context="...",nosuid,mode=755)
> tmpfs on /proc/scsi type tmpfs (ro,seclabel,relatime)

It looks like a cruft free cousin of proc that is just processes would
be applicable to your usecase.

Eric
