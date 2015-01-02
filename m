From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 6/9] mnt: Factor out __detach_mnt from detach_mnt
Date: Fri,  2 Jan 2015 15:52:51 -0600
Message-ID: <1420235574-15177-6-git-send-email-ebiederm__46650.6128119819$1420235786$gmane$org@xmission.com>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871tncuaf6.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

An upcoming change is going to need a version of detach_mnt
that leaves the mount on the parents mnt_mounts list.  Create
that version of detach_mnt now and call it __detach_mnt.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index a8afec9c81b6..c3f526ce0522 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -789,13 +789,12 @@ static void __touch_mnt_namespace(struct mnt_namespace *ns)
 /*
  * vfsmount lock must be held for write
  */
-static void detach_mnt(struct mount *mnt, struct path *old_path)
+static void __detach_mnt(struct mount *mnt, struct path *old_path)
 {
 	old_path->dentry = mnt->mnt_mountpoint;
 	old_path->mnt = &mnt->mnt_parent->mnt;
 	mnt->mnt_parent = mnt;
 	mnt->mnt_mountpoint = mnt->mnt.mnt_root;
-	list_del_init(&mnt->mnt_child);
 	hlist_del_init_rcu(&mnt->mnt_hash);
 	hlist_del_init(&mnt->mnt_mp_list);
 	put_mountpoint(mnt->mnt_mp);
@@ -805,6 +804,15 @@ static void detach_mnt(struct mount *mnt, struct path *old_path)
 /*
  * vfsmount lock must be held for write
  */
+static void detach_mnt(struct mount *mnt, struct path *old_path)
+{
+	__detach_mnt(mnt, old_path);
+	list_del_init(&mnt->mnt_child);
+}
+
+/*
+ * vfsmount lock must be held for write
+ */
 void mnt_set_mountpoint(struct mount *mnt,
 			struct mountpoint *mp,
 			struct mount *child_mnt)
-- 
2.2.1
