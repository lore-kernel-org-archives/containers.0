From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/4] fix depvpts in user namespaces
Date: Mon, 18 Mar 2013 14:23:02 -0700
Message-ID: <87wqt49zd5.fsf@xmission.com>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
	<87boalt0vi.fsf@xmission.com> <20130315140040.GB3782@sergelap>
	<5143333E.1040100@parallels.com> <20130315152133.GB24305@sergelap>
	<51433DBE.9020109@parallels.com> <87txoce5qy.fsf@xmission.com>
	<20130318032052.GA5958@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130318032052.GA5958@sergelap> (Serge Hallyn's message of "Sun,
	17 Mar 2013 22:20:52 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
> ...
>> > What it a /dev/ptmx already exist? will it use it? That would be bad,
>> > since that /dev/ptmx could be a host-side one. I actually believe
>> > linking to $rootfs/dev/pts/ptmx is more robust than my solution against
>> > remounts. So provided it can guarantee that the ptmx is not ever the
>> > root ptmx, I would ack that.
>> 
>> For those playing with udev, especially older udev where udev is still
>> udev and creates devices you can use the following udev rule to create
>> the pts/ptmx symlink.
>> 
>> KERNEL=="ptmx" NAME:="pts/ptmx" SYMLINK="ptmx"
>> 
>> Before we do anything clever in the kernel it is definitely worth seeing
>> how far we can take that little udev rule.
>
> Before it was decided that it was ok to modify core packages to
> accomodate containers, we had to install (non-standard) init jobs to
> detect it was in a container and if so modify some behavior - for
> instance to bind-mount a smaller /lib/init/fstab so that mountall
> wouldn't try to mount some things.  That way the rootfs had to be
> updated to run in a container, but could then still be used as a
> rootfs for non-containers.

That little udev rule could be one of those trivial modifications.

> ...
>
>> As much as I hate the notion I suspect for most of device management
>> what we want is to act like devtmpfs, and run all of the device node
>> creation etc outside of the container (possibly even with bind mounts).
>
> So you mean a task which is unprivileged on the host, privileged wrt the
> container, and on host fs namespace, which bind mounts the host /dev
> files into the container?

That would be the implementation.  Although you could potentialy have
something privileged on the host doing the work from outside of the
container.

>> Acting like devtmpfs should be something that is possible with no kernel
>> changes.   Whereas allowing unprivileged processes to create device
>> nodes probably has issues I haven't thought of yet.
>
> Not sure what 'acting like devtmpfs' means (especially in contrast to
> acting like udev) - maybe i need to go look at the code.

devtmpfs is a magic kernel thread and instance of tmpfs that calls mknod
based on the default device name and permission policy that is new in
the kernel.

Which means that any distro that can use devmpts has no problems with
something else calling mknod and creating the devices.  And the initrd
is expected to have mounted devtmpfs last I looked.

Eric
