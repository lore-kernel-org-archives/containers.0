From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [REVIEW][PATCH 1/3] vfs: In d_path don't call d_dname on a mount
	point
Date: Sat, 30 Nov 2013 22:43:40 +0000
Message-ID: <20131130224340.GA10323@ZenIV.linux.org.uk>
References: <52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <8738mi1yya.fsf_-_@xmission.com>
	<20131130061525.GY10323@ZenIV.linux.org.uk>
	<20131130170226.GZ10323@ZenIV.linux.org.uk>
	<87a9glh838.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87a9glh838.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Nov 30, 2013 at 01:51:07PM -0800, Eric W. Biederman wrote:
> Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:
> 
> > Eric, what behaviour do you want there?
> 
> Here is the behavior I want.
> 
> a) Something reasonable in /proc/self/fd when I just open one of these.
> 
> root@unassigned:~# exec 5< /proc/self/ns/net
> root@unassigned:~# ls -l /proc/self/fd
> total 0
> lrwx------ 1 root root 64 Nov 30 13:12 0 -> /dev/ttyS0
> lrwx------ 1 root root 64 Nov 30 13:12 1 -> /dev/ttyS0
> lrwx------ 1 root root 64 Nov 30 13:12 2 -> /dev/ttyS0
> lr-x------ 1 root root 64 Nov 30 13:12 3 -> /proc/718/fd
> lr-x------ 1 root root 64 Nov 30 13:12 5 -> net:[4026531955]
> root@unassigned:~# ip netns add foo
> 
> b) Something reasonable in /proc/mounts when I bind mount one of these.
> 
> root@unassigned:~# ip netns add foo
> root@unassigned:~# cat /proc/mounts 
> [...]
> proc /var/run/netns/foo proc rw,nosuid,nodev,noexec,relatime 0 0

Sigh...  What do you want to see in /proc/self/mountinfo?

> Any dentry allocated with d_alloc_pseudo will have the same problem if
> it is ever in a context where it can be bind mounted.  So this is a
> general issue with d_name.

Yes, ->d_dname() is called in a wrong place.  It should be in prepend_path(),
if not deeper.  What you are doing is growing a kludge on top of that mistake.

Note that your patch does nothing for mountinfo.

As for redesign...  That's exactly what is needed in that area, instead of
letting it fester.  Just look at the rats' nest in there - we have a maze
of helper functions, all alike, with slightly varying semantics.  With
prepend_path() having oh-so-wonderful calling conventions (0/-ENAMETOOLONG/1/2
for return value with rather opaque callers).  Outside of fs/dcache.c we
have the following pile:
	d_path() - most of the callers, periodically misused (see lustre
bug upthread)
	d_absolute_path(), __d_path(), dentry_path() - very few callers,
most in apparmour and tomoyo attempts to implement more or less the same
kind of thing.  Plus handling of /proc/<pid>/mountinfo.

As for check_mnt(old) in do_loopback()...  I wonder if we shouldn't just
turn that puppy into (check_mnt(old) || (old->mnt.mnt_flags & MNT_INTERNAL)).
Note that MS_NOUSER in superblock flags would prevent binding pipefs and
all mount_pseudo() users, so we wouldn't change existing behaviour...
