From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 79/85] cifs: Convert struct tcon_link to use a kuid.
Date: Wed, 13 Feb 2013 09:52:08 -0800
Message-ID: <1360777934-5663-79-git-send-email-ebiederm__40257.7786393978$1360779048$gmane$org@xmission.com>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1360777934-5663-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/cifs/cifsglob.h |    2 +-
 fs/cifs/connect.c  |   12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index aea1eec..7993a7a 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -837,7 +837,7 @@ struct cifs_tcon {
  */
 struct tcon_link {
 	struct rb_node		tl_rbnode;
-	uid_t			tl_uid;
+	kuid_t			tl_uid;
 	unsigned long		tl_flags;
 #define TCON_LINK_MASTER	0
 #define TCON_LINK_PENDING	1
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 17c3643..5411694 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -3919,7 +3919,7 @@ cifs_set_vol_auth(struct smb_vol *vol, struct cifs_ses *ses)
 }
 
 static struct cifs_tcon *
-cifs_construct_tcon(struct cifs_sb_info *cifs_sb, uid_t fsuid)
+cifs_construct_tcon(struct cifs_sb_info *cifs_sb, kuid_t fsuid)
 {
 	int rc;
 	struct cifs_tcon *master_tcon = cifs_sb_master_tcon(cifs_sb);
@@ -3989,7 +3989,7 @@ cifs_sb_tcon_pending_wait(void *unused)
 
 /* find and return a tlink with given uid */
 static struct tcon_link *
-tlink_rb_search(struct rb_root *root, uid_t uid)
+tlink_rb_search(struct rb_root *root, kuid_t uid)
 {
 	struct rb_node *node = root->rb_node;
 	struct tcon_link *tlink;
@@ -3997,9 +3997,9 @@ tlink_rb_search(struct rb_root *root, uid_t uid)
 	while (node) {
 		tlink = rb_entry(node, struct tcon_link, tl_rbnode);
 
-		if (tlink->tl_uid > uid)
+		if (uid_gt(tlink->tl_uid, uid))
 			node = node->rb_left;
-		else if (tlink->tl_uid < uid)
+		else if (uid_lt(tlink->tl_uid, uid))
 			node = node->rb_right;
 		else
 			return tlink;
@@ -4018,7 +4018,7 @@ tlink_rb_insert(struct rb_root *root, struct tcon_link *new_tlink)
 		tlink = rb_entry(*new, struct tcon_link, tl_rbnode);
 		parent = *new;
 
-		if (tlink->tl_uid > new_tlink->tl_uid)
+		if (uid_gt(tlink->tl_uid, new_tlink->tl_uid))
 			new = &((*new)->rb_left);
 		else
 			new = &((*new)->rb_right);
@@ -4048,7 +4048,7 @@ struct tcon_link *
 cifs_sb_tlink(struct cifs_sb_info *cifs_sb)
 {
 	int ret;
-	uid_t fsuid = current_fsuid();
+	kuid_t fsuid = current_fsuid();
 	struct tcon_link *tlink, *newtlink;
 
 	if (!(cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MULTIUSER))
-- 
1.7.5.4
