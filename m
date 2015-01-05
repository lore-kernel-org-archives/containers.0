From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 0/11 Call for testing and review of mount detach fixes
	(take 2)
Date: Mon, 05 Jan 2015 14:45:50 -0600
Message-ID: <87mw5xq7lt.fsf@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871tncuaf6.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Fri, 02 Jan 2015 15:42:21 -0600")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
directory is deleted, and too many cpu cycles burned while doing that.

For those who like to see everything in a single tree the code is at:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing

Eric W. Biederman (11):
      mnt: Improve the umount_tree flags
      mnt: Don't propagate umounts in __detach_mounts
      mnt: In umount_tree reuse mnt_list instead of mnt_hash
      mnt: Add MNT_UMOUNT flag
      mnt: Delay removal from the mount hash.
      mnt: Factor out __detach_mnt from detach_mnt
      mnt: Simplify umount_tree
      mnt: Remove redundant NULL tests in namespace_unlock
      mnt: On an unmount propagate clearing of MNT_LOCKED
      mnt: Don't propagate unmounts to locked mounts
      mnt: Honor MNT_LOCKED when detaching mounts


 fs/namespace.c        | 152 +++++++++++++++++++++++++++++++-------------------
 fs/pnode.c            |  60 +++++++++++++++++---
 fs/pnode.h            |   7 ++-
 include/linux/mount.h |   1 +
 4 files changed, 154 insertions(+), 66 deletions(-)
