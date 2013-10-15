From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 0/4] vfs: Detach mounts on unlink
Date: Tue, 15 Oct 2013 13:15:41 -0700
Message-ID: <87iowyxpci.fsf_-_@xmission.com>
References: <8761v7h2pt.fsf@tw-ebiederman.twitter.com>
	<CAJfpegtT7y-1HhbEVAMKkdQugTG_w7G_epGtQHGvQLpcZB5FVA@mail.gmail.com>
	<87li281wx6.fsf_-_@xmission.com> <87a9ioo37a.fsf_-_@xmission.com>
	<20131007043919.GB10284@mail.hallyn.com> <87vc191sf2.fsf@xmission.com>
	<CALCETrUaubASZyeoNZcYxn5-GJO68=Ng=GYmas7K_OBsjM7f0Q@mail.gmail.com>
	<87d2ngyb02.fsf@xmission.com>
	<20131008160601.GJ14242@tucsk.piliscsaba.szeredi.hu>
	<CALCETrWw=htmgxqq=RQztdJQ-a8c3860vmJh9Ni=Hhs0TkO3YA@mail.gmail.com>
	<20131008161135.GK14242@tucsk.piliscsaba.szeredi.hu>
	<87li23trll.fsf@tw-ebiederman.twitter.com>
	<CAJfpegv+h7xh_2e-X7is9dq1Fp06A0eKwsyWFMPX=azbbDCX5Q@mail.gmail.com>
	<87vc15mjuw.fsf@xmission.com>
	<CAJfpegvF89LzAvNB0h0otv7sKoS3rewZzQKAauQx3P+rCkCcSg@mail.gmail.com>
	<87iox38fkv.fsf@xmission.com> <87d2nb8dxy.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2nb8dxy.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Fri, 11 Oct 2013 18:39:53 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Linux-Fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Matthias Schniedermeyer <ms-QGhoYOTWWTg@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


This patchset is an addresses two problems:
1) Not all modifications to the filesystems happen through the vfs and
   since the vfs can not cope with a mount point being unlinked or
   renamed filesystems whose modifications that do not come through the
   vfs are required to lie.

2) Through an oversight it is now possible for one unprivileged user to
   mount something on another unprivileged users dentry and make it
   impossible for the other user to unlink or rename that dentry.

It is now technically possible to easily lift the restriction on
unlinking and renaming files with mount points on them, with a
corresponding reduction in complexity of the vfs semantics.

After review it seems that there are no objections to this approach as
long as we retain the -EBUSY semantics for rmdir, unlink, and rename of
mount points in the current mount namespace.  The first patch in this
series now adds those local mount namespace restrictions.

All of the review comments should now be addressed and folded in, and
I have take a careful look and it appears what I have is now correct
and complete.  So I am posting this for one last round of review.

Al if you want to take this through the vfs tree, point me at a branch
and I will give you versions of these patches that apply cleanly there.
Otherwise I will push these patches to my userns tree as soon as all of
these patches pass review.

Eric W. Biederman (4):
      vfs: Don't allow overwriting mounts in the current mount namespace
      vfs: Keep a list of mounts on a mount point
      vfs: Add a function to lazily unmount all mounts from any dentry. v3
      vfs: Lazily remove mounts on unlinked files and directories. v2

 fs/afs/dir.c           |    3 +-
 fs/dcache.c            |   80 ++++++++++++++++++++----------------------------
 fs/fuse/dir.c          |    3 +-
 fs/gfs2/dentry.c       |    4 +--
 fs/mount.h             |    3 ++
 fs/namei.c             |   55 +++++++++++++++++++++------------
 fs/namespace.c         |   30 ++++++++++++++++++
 fs/nfs/dir.c           |    5 +--
 fs/sysfs/dir.c         |    9 +-----
 include/linux/dcache.h |    3 +-
 10 files changed, 108 insertions(+), 87 deletions(-)
