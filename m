From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 07/11] mnt: Simplify umount_tree
Date: Mon,  5 Jan 2015 14:46:23 -0600
Message-ID: <1420490787-14387-7-git-send-email-ebiederm__26058.7752367885$1420491039$gmane$org@xmission.com>
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

Replace the open coded __detach_mnt with __detach_mnt.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index c3f526ce0522..9fae55f2242e 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1368,16 +1368,8 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 		if (how & UMOUNT_SYNC)
 			p->mnt.mnt_flags |= MNT_SYNC_UMOUNT;
 		if (mnt_has_parent(p)) {
-			hlist_del_init(&p->mnt_mp_list);
-			put_mountpoint(p->mnt_mp);
 			mnt_add_count(p->mnt_parent, -1);
-			/* move the reference to mountpoint into ->mnt_ex_mountpoint */
-			p->mnt_ex_mountpoint.dentry = p->mnt_mountpoint;
-			p->mnt_ex_mountpoint.mnt = &p->mnt_parent->mnt;
-			p->mnt_mountpoint = p->mnt.mnt_root;
-			p->mnt_parent = p;
-			p->mnt_mp = NULL;
-			hlist_del_init_rcu(&p->mnt_hash);
+			__detach_mnt(p, &p->mnt_ex_mountpoint);
 		}
 		change_mnt_propagation(p, MS_PRIVATE);
 	}
-- 
2.2.1
