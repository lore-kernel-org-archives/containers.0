From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 0/19] Locked mount and loopback mount fixes
Date: Thu, 02 Apr 2015 20:53:18 -0500
Message-ID: <87a8yqou41.fsf_-___40072.5551801317$1428026265$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87mw5xq7lt.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Mon, 05 Jan 2015 14:45:50 -0600")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Omar Sandoval <osandov-nWWhXC5lh1RBDgjK7y7TUQ@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


Way back in October Andrey Vagin reported that umount(MNT_DETACH) could
be used to defeat MNT_LOCKED.  As I worked to fix this I discovered
that combined with mount propagation and an appropriate selection of
shared subtrees a reference to a directory on an unmounted filesystem is
not necessary.

That MNT_DETACH is allowed in user namespace in a form that can break
MNT_LOCKED comes from my early misunderstanding what MNT_DETACH does.

To avoid breaking existing userspace the conflict between MNT_DETACH and
MNT_LOCKED is fixed by leaving mounts that are locked to their parents
in the mount hash table until the last reference goes away.

While investigating this issue I also found an issue with
__detach_mounts.  The code was unnecessarily and incorrectly triggering
mount propagation.  Resulting in too many mounts going away when a
directory is deleted, and too many cpu cycles are burned while doing
that.

Looking some more I realized that __detach_mounts by only keeping mounts
connected that were MNT_LOCKED it had the potential to still leak
information so I tweaked the code to keep everything locked together
that possibly could be.

In the middle of all of this bug hunting and fixing it was reported that
with a strategically placed rename ".." on bind mounts could go up
past their root of the bind mount.  Which turned out to be very easy to
understand and test for but tricky to actually fix in a way that would
not slow down path name lookups in the common case.

These fixes are against on v4.0-rc6 which has all of Al's new fs_pin
code.

I have tested the code and I don't see any issues but as I am human I
may have missed a corner case or two.  So any feedback is appreciated.

For those who like to see everything in a single tree the code is at:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing

Eric W. Biederman (19):
      mnt: Use hlist_move_list in namespace_unlock
      mnt: Improve the umount_tree flags
      mnt: Don't propagate umounts in __detach_mounts
      mnt: In umount_tree reuse mnt_list instead of mnt_hash
      mnt: Add MNT_UMOUNT flag
      mnt: Delay removal from the mount hash.
      mnt: On an unmount propagate clearing of MNT_LOCKED
      mnt: Don't propagate unmounts to locked mounts
      mnt: Fail collect_mounts when applied to unmounted mounts
      mnt: Factor out unhash_mnt from detach_mnt and umount_tree
      mnt: Factor umount_mnt from umount_tree
      fs_pin: Allow for the possibility that m_list or s_list go unused.
      mnt: Honor MNT_LOCKED when detaching mounts
      mnt: Fix the error check in __detach_mounts
      mnt: Update detach_mounts to leave mounts connected
      mnt: Track which mounts use a dentry as root.
      vfs: Test for and handle paths that are unreachable from their mnt_root
      vfs: Handle mounts whose parents are unreachable from their mountpoint
      vfs: Do not allow escaping from bind mounts.

 fs/dcache.c            |  35 +++++-
 fs/fs_pin.c            |   4 +-
 fs/internal.h          |   2 +
 fs/mount.h             |   8 ++
 fs/namei.c             |  34 +++++-
 fs/namespace.c         | 325 +++++++++++++++++++++++++++++++++++++++++--------
 fs/pnode.c             |  60 +++++++--
 fs/pnode.h             |   7 +-
 include/linux/dcache.h |   7 ++
 include/linux/fs_pin.h |   2 +
 include/linux/mount.h  |   3 +
 include/linux/namei.h  |   2 +
 12 files changed, 424 insertions(+), 65 deletions(-)
