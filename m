From: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: [PATCH 7/9] Define get_init_pts_sb()
Date: Tue, 14 Oct 2008 22:37:03 -0700
Message-ID: <20081015053703.GG2215@us.ibm.com>
References: <20081015053000.GA2039@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081015053000.GA2039-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From 3a2b7147d5aa345ab96d321ffefd326cbc43e24d Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 7/9] Define get_init_pts_sb()

See comments in the function header for details. The new interface will
be used in a follow-on patch.

Changelog [v2]:
	[Dave Hansen] Replace get_sb_ref() in fs/super.c with get_init_pts_sb()
	and make the new interface private to devpts

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/devpts/inode.c |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 54 insertions(+), 1 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index bbdd7df..1dfdbf0 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -305,10 +305,63 @@ fail:
 	return -ENOMEM;
 }
 
+static int compare_init_pts_sb(struct super_block *s, void *p)
+{
+	if (devpts_mnt)
+		return devpts_mnt->mnt_sb == s;
+
+	return 0;
+}
+
+/*
+ * get_init_pts_sb()
+ *
+ *     This interface is needed to support multiple namespace semantics in
+ *     devpts while preserving backward compatibility of the current 'single-
+ *     namespace' semantics. i.e all mounts of devpts without the 'newinstance'
+ *     mount option should bind to the initial kernel mount, like
+ *     get_sb_single().
+ *
+ *     Mounts with 'newinstance' option create a new private namespace.
+ *
+ *     But for single-mount semantics, devpts cannot use get_sb_single(),
+ *     because get_sb_single()/sget() find and use the super-block from
+ *     the most recent mount of devpts. But that recent mount may be a
+ *     'newinstance' mount and get_sb_single() would pick the newinstance
+ *     super-block instead of the initial super-block.
+ *
+ *     This interface is identical to get_sb_single() except that it
+ *     consistently selects the 'single-namespace' superblock even in the
+ *     presence of the private namespace (i.e 'newinstance') super-blocks.
+ */
+static int get_init_pts_sb(struct file_system_type *fs_type, int flags,
+		void *data, struct vfsmount *mnt)
+{
+        struct super_block *s;
+        int error;
+
+        s = sget(fs_type, compare_init_pts_sb, set_anon_super, NULL);
+        if (IS_ERR(s))
+                return PTR_ERR(s);
+
+        if (!s->s_root) {
+                s->s_flags = flags;
+                error = devpts_fill_super(s, data, flags & MS_SILENT ? 1 : 0);
+                if (error) {
+                        up_write(&s->s_umount);
+                        deactivate_super(s);
+                        return error;
+                }
+                s->s_flags |= MS_ACTIVE;
+        }
+        do_remount_sb(s, flags, data, 0);
+        return simple_set_mnt(mnt, s);
+}
+
 static int devpts_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
 {
-	return get_sb_single(fs_type, flags, data, devpts_fill_super, mnt);
+	return get_init_pts_sb(fs_type, flags, data, mnt);
 }
 
 static void devpts_kill_sb(struct super_block *sb)
-- 
1.5.2.5
