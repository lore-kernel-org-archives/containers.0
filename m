From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 0/8] Bind mount escape fixes
Date: Thu, 13 Aug 2015 23:29:23 -0500
Message-ID: <87wpwyjxwc.fsf_-_@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<87egjk9i61.fsf_-_@x220.int.ebiederm.org>
	<20150810043637.GC14139@ZenIV.linux.org.uk>
	<877foymrwt.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877foymrwt.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Thu, 13 Aug 2015 23:10:26 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


It is possible in some situations to rename a file or directory through
one mount point such that it can start out inside of a bind mount and
after the rename wind up outside of the bind mount.  Unfortunately with
user namespaces these conditions can be trivially created by creating a
bind mount under an existing bind mount.

I have identified four situations in which this may be a problem.
- __d_path and d_absolute_path need to error on disconnected paths
  that can not reach some root directory or lsm path based security
  checks can incorrectly succeed.

- Normal path name resolution following .. can lead to a directory
  that is outside of the original loopback mount.

- file handle reconsititution aka exportfs_decode_fh can yield a dentry
  from which d_parent can be followed up to mnt->sb->s_root, but
  d_parent can not be followed up to mnt->mnt_root.

- Mounts on a path that has been renamed outside of a loopback mount
  become unreachable, as there is no possible path that can be passed
  to umount to unmount them.

My strategy:

o File handle reconsitituion problems can be prevented by enabling
  the nfsd subtree checks for nfs exports, and open_by_handle_at
  requires capable(CAP_DAC_READ_SEARCH) so is only usable by the global
  root.  This makes any problems difficult if not impossible to exploit
  in practice so I have not yet written code to address that issue.

o The functions __d_path and d_absolute_path are agumented so that the
  security modules will not be fed a problematic path to work with.

o Following of .. has been agumented to test that after d_parent has
  been resolved the original  directory is connected, and if not
  an error of -ENOENT is returned.

o I do not worry about mounts that are disconnected from their bind
  mount as these mounts can always be freed by either umount -l on
  the bind mount they have escaped from, or by freeing the mount
  namespace.  So I do not believe there is an actual problem.

Pathname resolution is a common fast path and most of the code in this
patchset to support keeping .. from becoming expensive in the common
case.

After hearing the Al's feedback and running some numbers I have given
up attempting to keeping the number of d_ancestor calls during pathname
resolution to an absolute minimum.  It appears that simply preventing
calls d_ancestor unless a directory has escaped is good enough.  This
change in approach has significantly simplified the code.

The big implementation change to note is that I have rewritten
d_splice_alias and made some significant progress in cleaning up how the
locks are dealt with.  The only limitation now is that
dentry->d_parent->d_inode->i_mutex is taken in lookup held when
d_splice_alias is called.    If that ever goes away my new
d_splice_alias can easily take all of the locks it needs to rename
a directory in the proper order.

Does anyone see anything significant that I have missed?

These changes are all against v4.2-rc1. 

For those who like to see everything in a single tree the code is at:

     git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing

Eric W. Biederman (8):
      dcache: Handle escaped paths in prepend_path
      dcache: Reduce the scope of i_lock in d_splice_alias
      dcache: Clearly separate the two directory rename cases in d_splice_alias
      mnt: Track which mounts use a dentry as root.
      dcache: Implement d_common_ancestor
      dcache: Only read d_flags once is d_is_dir
      mnt: Track when a directory escapes a bind mount
      vfs: Test for and handle paths that are unreachable from their mnt_root

 fs/dcache.c            | 193 +++++++++++++++++++++++++++++++++++++------------
 fs/mount.h             |   9 +++
 fs/namei.c             |  26 ++++++-
 fs/namespace.c         | 152 +++++++++++++++++++++++++++++++++++++-
 include/linux/dcache.h |  11 ++-
 include/linux/mount.h  |   1 +
 6 files changed, 338 insertions(+), 54 deletions(-)
