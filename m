From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 08/11] mnt: Remove redundant NULL tests in
	namespace_unlock
Date: Mon,  5 Jan 2015 14:46:24 -0600
Message-ID: <1420490787-14387-8-git-send-email-ebiederm__26295.8207786598$1420491021$gmane$org@xmission.com>
References: <87mw5xq7lt.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87mw5xq7lt.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

mntget, mntput, dput and pathput all test their arguments to see if
they are NULL before taking any action, so testing for NULL in
namespace_unlock is redundant.

Remove the redundant checks making namespace_unlock a little
shorter and easier to read.

This also makes it possible for mnt_ex_mountpoint.mnt to be NULL
allowing putting a dentry without a mount.  This is will be needed
in __detach_mounts when detaching already unmounted children,
as part of the fix for MNT_DETACH on MNT_LOCKED mounts.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 9fae55f2242e..3769dbd040c1 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1312,8 +1312,7 @@ static void namespace_unlock(void)
 
 	/* undo decrements we'd done in umount_tree() */
 	list_for_each_entry(mnt, &head, mnt_list)
-		if (mnt->mnt_ex_mountpoint.mnt)
-			mntget(mnt->mnt_ex_mountpoint.mnt);
+		mntget(mnt->mnt_ex_mountpoint.mnt);
 
 	up_write(&namespace_sem);
 
@@ -1322,8 +1321,7 @@ static void namespace_unlock(void)
 	while (!list_empty(&head)) {
 		mnt = list_first_entry(&head, struct mount, mnt_list);
 		list_del_init(&mnt->mnt_list);
-		if (mnt->mnt_ex_mountpoint.mnt)
-			path_put(&mnt->mnt_ex_mountpoint);
+		path_put(&mnt->mnt_ex_mountpoint);
 		mntput(&mnt->mnt);
 	}
 }
-- 
2.2.1
