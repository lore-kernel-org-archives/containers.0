From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH v8 0/6] fuse: mounts from non-init user namespaces
Date: Fri, 02 Mar 2018 15:58:23 -0600
Message-ID: <87r2p287i8.fsf_-___37357.137053232$1520027828$gmane$org@xmission.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<878tbmf5vl.fsf@xmission.com> <87po4rz4ui.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87po4rz4ui.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Mon, 26 Feb 2018 17:52:21 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


This patchset builds on the work by Donsu Park and Seth Forshee and is
reduced to the set of patches that just affect fuse.  The non-fuse
vfs patches are far enough along we can ignore them except possibly for the
question of when does FS_USERNS_MOUNT get set in fuse_fs_type.

Fuse with a block device has been left as an exercise for a later time.

Since v5 I changed the core of this patchset around as the previous
patches were showing signs of bitrot.  Some important explanations were
missing, some important functionality was missing, and xattr handling
was completely absent.

Since v6 I have:
- Removed the failure case from fuse_get_req_nofail_nopages that I
  added.
- Updated fuse to always to use posix_acl_access_xattr_handler, and
  posix_acl_default_xattr_handler, by teaching fuse to set
  ACL_DONT_CACHE when FUSE_POSIX_ACL is not set.

Since v7 I have:
- Rethought and reworked how I am unifying the cached and the non-cached
  posix acl case so the code is cleaner and simpler.
  - I have dropped enhancements to caching negative acls when
    fc->no_getxattr is set.
  - Removed the need to wrap forget_all_cached_acls in fuse.
- Reorder the patches so the posix acl work comes first

Miklos can you take a look and see what you think?

I think this much of the fuse changes are ready, and as such I would
like to get them in this development cycle if possible.

These changes are also available at:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git userns-fuse-v8

Eric W. Biederman (5):
      fs/posix_acl: Update the comments and support lightweight cache skipping
      fuse: Simplfiy the posix acl handling logic.
      fuse: Remove the buggy retranslation of pids in fuse_dev_do_read
      fuse: Fail all requests with invalid uids or gids
      fuse: Support fuse filesystems outside of init_user_ns

Seth Forshee (1):
      fuse: Restrict allow_other to the superblock's namespace or a descendant


 fs/fuse/acl.c             | 10 ++++++----
 fs/fuse/cuse.c            |  7 ++++++-
 fs/fuse/dev.c             | 30 ++++++++++++++++------------
 fs/fuse/dir.c             | 18 ++++++++---------
 fs/fuse/fuse_i.h          |  9 ++++++---
 fs/fuse/inode.c           | 34 +++++++++++++++++++-------------
 fs/fuse/xattr.c           |  5 -----
 fs/posix_acl.c            | 50 ++++++++++++++++++++++++++++++++---------------
 include/linux/posix_acl.h | 17 ++++++++++++++++
 kernel/user_namespace.c   |  1 +
 10 files changed, 116 insertions(+), 65 deletions(-)
