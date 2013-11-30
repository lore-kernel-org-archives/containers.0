From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 1/3] vfs: In d_path don't call d_dname on a mount
	point
Date: Sat, 30 Nov 2013 13:51:07 -0800
Message-ID: <87a9glh838.fsf@xmission.com>
References: <20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com> <87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <8738mi1yya.fsf_-_@xmission.com>
	<20131130061525.GY10323@ZenIV.linux.org.uk>
	<20131130170226.GZ10323@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131130170226.GZ10323-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Sat, 30 Nov 2013 17:02:26 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> Eric, what behaviour do you want there?

Here is the behavior I want.

a) Something reasonable in /proc/self/fd when I just open one of these.

root@unassigned:~# exec 5< /proc/self/ns/net
root@unassigned:~# ls -l /proc/self/fd
total 0
lrwx------ 1 root root 64 Nov 30 13:12 0 -> /dev/ttyS0
lrwx------ 1 root root 64 Nov 30 13:12 1 -> /dev/ttyS0
lrwx------ 1 root root 64 Nov 30 13:12 2 -> /dev/ttyS0
lr-x------ 1 root root 64 Nov 30 13:12 3 -> /proc/718/fd
lr-x------ 1 root root 64 Nov 30 13:12 5 -> net:[4026531955]
root@unassigned:~# ip netns add foo

b) Something reasonable in /proc/mounts when I bind mount one of these.

root@unassigned:~# ip netns add foo
root@unassigned:~# cat /proc/mounts 
[...]
proc /var/run/netns/foo proc rw,nosuid,nodev,noexec,relatime 0 0

The technical path that lead me to changing d_path looks something like this.

- I want bind mounts to work. So I need check_mnt to pass.
- I can't have these file descriptors show up directly in proc or useful
  permission checks will be bypassed.  Therefore d_unhashed must be true.
- I don't want every call of d_path to add (deleted) so I need
  d_unlinked to be false. Therefore S_ISROOT must be true.
- When looking at one of these file descriptors when they are not
  mounted prepend_path see that IS_ROOT is true and report /proc/ unless
  I implement d_name.
- When looking at one of these file descriptors when they are bind
  mounted I want /proc/mounts to reflect where they are mounted, which
  means I shouldn't call d_path.

Any dentry allocated with d_alloc_pseudo will have the same problem if
it is ever in a context where it can be bind mounted.  So this is a
general issue with d_name.

The other path to where I am at starts at this comment in prepend_path:
	/*
	 * Filesystems needing to implement special "root names"
	 * should do so with ->d_dname()
	 */
Which is exactly what I did only later to discover that d_path get's it
wrong if the dentry is mounted.

If I remove ns_dname I get the following:
root@unassigned:~# exec 5< /proc/self/ns/net 
root@unassigned:~# ls -l /proc/self/fd/
total 0
lrwx------ 1 root root 64 Nov 30 13:31 0 -> /dev/ttyS0
lrwx------ 1 root root 64 Nov 30 13:31 1 -> /dev/ttyS0
lrwx------ 1 root root 64 Nov 30 13:31 2 -> /dev/ttyS0
lr-x------ 1 root root 64 Nov 30 13:31 3 -> /proc/708/fd
lr-x------ 1 root root 64 Nov 30 13:31 5 -> /proc

Which is livable but particularly ugly to look at.

As for simple correctness.  There are only a handful of implementations
of d_dname today and the all set a valid path in the file descriptors
returned, in anything that can make it to d_path.  Which makes the test
for a psuedo dentry in d_path safe.  And at a very simply level we never
want to call d_dname on an actual mount point.

So in the small I will argue what I have done is very much correct.  In
the large I don't see any other set of implementation choices that does
not result in a significant redesign of something.

Furthermore I have a regression dating back a couple of kernels that
breaks /proc/mounts that should be resolved, and this patch is the
cleanest, safest, simplest solution I can see.

Eric
