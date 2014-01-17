From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 1/3] vfs: In d_path don't call d_dname on a mount
	point
Date: Thu, 16 Jan 2014 19:29:16 -0800
Message-ID: <874n53gub7.fsf__10813.4920396425$1389929384$gmane$org@xmission.com>
References: <52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com> <87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <8738mi1yya.fsf_-_@xmission.com>
	<20131130061525.GY10323@ZenIV.linux.org.uk>
	<20131130170226.GZ10323@ZenIV.linux.org.uk>
	<87a9glh838.fsf@xmission.com>
	<20131130224340.GA10323@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

> On Sat, Nov 30, 2013 at 01:51:07PM -0800, Eric W. Biederman wrote:
>> Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:
>> 
>> > Eric, what behaviour do you want there?
>> 
>> Here is the behavior I want.
>> 
>> a) Something reasonable in /proc/self/fd when I just open one of these.
>> 
>> root@unassigned:~# exec 5< /proc/self/ns/net
>> root@unassigned:~# ls -l /proc/self/fd
>> total 0
>> lrwx------ 1 root root 64 Nov 30 13:12 0 -> /dev/ttyS0
>> lrwx------ 1 root root 64 Nov 30 13:12 1 -> /dev/ttyS0
>> lrwx------ 1 root root 64 Nov 30 13:12 2 -> /dev/ttyS0
>> lr-x------ 1 root root 64 Nov 30 13:12 3 -> /proc/718/fd
>> lr-x------ 1 root root 64 Nov 30 13:12 5 -> net:[4026531955]
>> root@unassigned:~# ip netns add foo
>> 
>> b) Something reasonable in /proc/mounts when I bind mount one of these.
>> 
>> root@unassigned:~# ip netns add foo
>> root@unassigned:~# cat /proc/mounts 
>> [...]
>> proc /var/run/netns/foo proc rw,nosuid,nodev,noexec,relatime 0 0
>
> Sigh...  What do you want to see in /proc/self/mountinfo?

With or without my patch I see what I am after right now is:
31 12 0:3 / /var/run/netns/foo rw,nosuid,nodev,noexec,relatime - proc proc rw

Apologies for not being clear on that point.

However it would be nice to see:
28 13 0:3 net:[4026532127] /var/run/netns/foo rw,nosuid,nodev,noexec,relatime - proc proc rw

Not having the path be the magical floating path is not causing
regressions for people so I don't care much at the moment.

>> Any dentry allocated with d_alloc_pseudo will have the same problem if
>> it is ever in a context where it can be bind mounted.  So this is a
>> general issue with d_name.
>
> Yes, ->d_dname() is called in a wrong place.  It should be in prepend_path
> if not deeper.  What you are doing is growing a kludge on top of that
> mistake.

I disagree. I am not growing a kludge on of a mistake.  I am refining
the logic at the call site of d_dname.  The logic to not call d_dname
on a mountpoint should be there wherever we call d_dname.

Which makes my change completely orthogonal to moving the call of
d_dname into the strangeness that is prepend_path.

> Note that your patch does nothing for mountinfo.

And it doesn't need to do anything for mountinfo.  My desire and the
only sensible semantics I can think of is for non-mountpoints to have
d_dname called on them.  By definition /proc/mountinfo only shows mount
points, so there is never a neeed to call d_dpath is /proc/mountinfo.


Looking at what is going on in detail, the implementations of the
.d_dname method are:

arch/ia64/kernel/perfmon.c: pfmfs_dname
    ia64 perfmon files are unlinked character devices whose dentries are
    allocated with d_alloc, and the filesystem is mounted with kern_mount.
fs/aio.c:simple_dname
    aio private files that are non-directories whose dentries are 
    allocated with d_alloc_pseudo, and the filesystem is mounted with kern_mount.
fs/anon_inodes.c:anon_inodefs_dname
    anonymous inodes that are non-directories whose dentries are
    allocated with d_alloc_pseudo, and the filesystem is mounted with
    kern_mount.    
fs/pipe.c:pipefs_dname
    pipes that are non-directories whose dentries are allocated with
    d_alloc_psuedo, and the fs is mounted with kern_mount.
net/socket.c:sockfs_dname
    sockets are non-directories whose dentries are allocated with
    d_alloc_pseudo, and the filesystem is mounted with kern_mount.
mm/shmem.c:simple_dname
    shared memory segments are non-directories whose dentries are
    allocated with d_alloc_pseudo, and the filesystem is mounted with
    kern_mount.
fs/hugetlbfs/inode.c:simple_dname
    hugetlb shared memory segments are non-directories whose dentries
    are allocted with d_alloc_pseudo, and the filesystem is mounted with
    kern_mount_data.
fs/proc/namespaces.c:ns_dname
    namespace files are non-directories whose dentries are allocated
    with d_alloc_pseudo, and the filesystem is mounted normally.


In the worst case prepend_path is safe to use on the dentries that
implement d_dname as their dentry name field has valid data.

The callers of prepend_path that are not d_path are:
__d_path
d_absolute_path
getcwd



getcwd need not be worried about because get_fs_root_and_pwd will always
return directories.  And none of the implementations of d_dname are
directories.



__d_path is has only two callers: fs/seq_file.c:seq_path_root and
security/apparmor/path.c:d_namespace_path.

fs/seq_file.c: seq_path_root which is only used in
fs/proc_namespaces.c:show_mountinfo aka /proc/mountinfo.  Since this is
only dealing with mounted paths there will never be a need to call
d_dname.

security/apparmor/path.c:d_namespace_path in apparmor is almost
interesting, it is called on files that come from exec (brpm->file),
link, rename, open, unlink, create, truncate, chown, chmod, and getattr.
Which with clever usage of magic proc symlinks could conceivably point
to a file descriptor that implements d_dname.  However d_namespace_path
tests the mountpoint for MNT_INTERNAL and calls dentry_path if that is
the case, avoiding __d_path or d_absolute_path, except for the proc
namespace files.  In either case today if mounted a sensible result and
if not mounted an empty path.

The only other caller of d_absolute_path is
security/tomoyo/realpath.c:tomoyo_get_absolute_path.  However
tomyo_get_absolute_path is only called from tomoyo_realpath_from_path
which checks for dentries that implement d_dname and calls them
explicitly, only calling d_absolute_name if there is no such
implementation.  



Which is a long way of saying that right now moving the call of d_dname
into prepend_path would make no practical difference.   

At a practical level there are improvements to be had by calling d_dname
in dentry_path and by adding my avoidance of calling d_dname on a
mountpoint into tomoyo_realpath_from_path.

So while I see what you mean by prepend_path needing cleaning up that is
really orthogonal to the acidental regression that I am fixing.

> As for redesign...  That's exactly what is needed in that area, instead of
> letting it fester.

I can't backport a redesign to fix the regression, and a redesign
results in no practical benefit for me.  So I might be persuaded later
if I can find the time but right now a redesign is the wrong place to
start.

> As for check_mnt(old) in do_loopback()...  I wonder if we shouldn't just
> turn that puppy into (check_mnt(old) || (old->mnt.mnt_flags & MNT_INTERNAL)).
> Note that MS_NOUSER in superblock flags would prevent binding pipefs and
> all mount_pseudo() users, so we wouldn't change existing behaviour...

Strictly speaking behavior would change for the proc namespace files, as
now you could do things by finding a mount of proc in another mount
namespace where the namespace files were available.

I would be a lot more comfortable with changing do_loopback if we could
safely remove the check_mnt(old) test altogether.  Why do we have the
check_mnt(old) test in do_loopback?   If we can't remove the
check_mnt(old) test I need verify that the reasons for that test don't
apply to my namespace file descriptor case.  Otherwise I can't see any
real problems with making that change (time permitting).



After getting this regression fix merged, the windmill that I expect I
will be tilting at are fixing the user space visible races that let a
dentry be renamed while we are mounting something on it, and the messy
fact that check_submounts_and_drop isn't part of d_invalidate.  Both of
those can potentially result in user space visible insantiy.

Eric
