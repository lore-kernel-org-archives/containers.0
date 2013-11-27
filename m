From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 3/3] vfs: Fix a regression in mounting proc
Date: Wed, 27 Nov 2013 10:51:40 -0800
Message-ID: <871u21oeyr.fsf@xmission.com>
References: <20131116164840.GA4441@mail.hallyn.com>
	<20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com> <87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <87pppmzoin.fsf_-_@xmission.com>
	<20131127161300.GA24773@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131127161300.GA24773-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Oleg Nesterov's message of
	"Wed, 27 Nov 2013 17:13:00 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> To all: sorry for noise, I can't comment this patch.
>
>
> But Eric, could you please help me to understand? I am totally confused.
>
> So, afaics, initially (even after MS_KERNMOUNT) fs_fully_visible("proc")
> should return false.
>
> After the normal "mout -t proc none /proc/" it becomes true.
>
> And it is still true after, say, "mount -t ramfs none /proc/sys" because
> "ls -ld /proc/sys" shows ->i_nlink == 1.
>
> However, say, "mount -t ramfs none /proc/tty/" should make
> fs_fully_visible() == F, because in this case ->i_nlink == 4.
>
> Correct?
>
> If yes, could you explain what this "!CAP_SYS_ADMIN && !fs_fully_visible"
> check actually tries to prevent and why?

Right now a more accurate name would be fs_visible.

The primary goal is to restrict the user namespace root to being able to
mount proc and sysfs if nothing new is revealed, preserving the
restrictions in jail type environments where proc and sysfs are not
mounted at all.

I would have dropped the ability for the userns root to create a fresh
mount of proc and syfs, and required a bind mount instead except
because of the namespace intertwining we need fresh mounts of proc and
sys after new namespaces are created.

What I really would love to have implemented would be a check that
nothing is mounted on top of proc of sysfs but that fails because we
have /sys/fs/.. and /proc/sys/fs_binfmt_misc.  So I had to implement
an empty directory check.

And when I first implemented that empty directory check I had a complete
and total brain fart.

So what is really implemented at the moment would be more accurately called
fs_visible().

For the real concern about jail environments where proc and sysfs are
not mounted at all a fs_visible check is all that is really required,
and if you look at 3.11? I think it was that is what was shipped.

Unfortunately I cleaned things up and totally had a massive brain fart
and failed to implement the is this an empty directory check properly
and somehow failed to test mounting /proc in a real world environment
and so caused a significant regression in 3.12 leading to a case where
proc is not mountable.  This patch just fixes that stupid regression.
As the overmount protection in general is not needed as to my knolwedge
no one overmounts proc or sysfs in a meaningful way.

Now it would be very good to go back and fix fs_fully_visible to either
be fs_visible and not care or to read overmounted directories and verify
that they are actually empty.  Reading directories at this point
requires opening a file and probably playing with locks.  Something I am
not prepared to do for a trivial bug fix.  Especially since getting it
right only closes theoretical holes at the moment.

Does that clarify things?

Eric
