From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [REVIEW][PATCH 3/3] vfs: Fix a regression in mounting proc
Date: Wed, 27 Nov 2013 16:29:28 +0000
Message-ID: <20131127162928.GB7358@mail.hallyn.com>
References: <20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <87pppmzoin.fsf_-_@xmission.com>
	<20131127161300.GA24773@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131127161300.GA24773-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
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

The idea is that some admin on a host where /a/b/c/d exists, c/d should
be hidden, so overmounts a tmpfs onto /a/b/c.  In that case, an unpriv
user could clone(CLONE_NEWUSER), then clone(CLONE_NEWNS), then umount
/a/b/c and see /a/b/c/d.  This patch was to try and prevent that.

I argue that it is easy enough for the admin to make /a/b/c permissions
such that it can't be crossed by an unprivileged user, but that does
require an action on the part of admins who used this (imo misguided)
approach.

-serge
