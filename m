From: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: Re: [PATCH 08/10] Define get_sb_ref()
Date: Fri, 3 Oct 2008 20:09:21 -0700
Message-ID: <20081004030921.GA11664@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
	<20080912175308.GI17350@us.ibm.com>
	<1222286127.15523.66.camel@nimitz>
	<20080926212115.GD31505@us.ibm.com>
	<1222464662.25451.23.camel@nimitz>
	<20080927202924.GA16208@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080927202924.GA16208-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org [sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| | On Fri, 2008-09-26 at 14:21 -0700, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
| | > Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| | > | On Fri, 2008-09-12 at 10:53 -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
| | > | > + *     But for single-mount semantics, devpts cannot use get_sb_single(),
| | > | > + *     because get_sb_single()/sget() find and use the super-block from
| | > | > + *     the most recent mount of devpts. But that recent mount may be a
| | > | > + *     'newinstance' mount and get_sb_single() would pick the newinstance
| | > | > + *     super-block instead of the initial super-block.
| | > | 
| | > | Can't you just override the test() function to get what you want here?
| | > 
| | > get_sb_single() does not take a test() parameter and so I would still
| | > need a get_sb_ref() or get_sb_special() interface right ? 
| | > 
| | > This special interface could call sget() with a custom-test function,
| | > to get the super-block.  But in case of devpts, we already have the
| | > super-block. So we don't need to call sget(). We just need get a reference
| | > and remount.
| | 
| | Well, you shouldn't be using get_sb_single() at all any more, right?
| 

Since mqueue_ns is using a different approach, and devpts is the only one
needing this new interface, we can move this into fs/devpts/inode.c.

This patch again applies on current ptsns patchset.

---

From fc983c743daad24c599215500a2e06e7eff82239 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Fri, 3 Oct 2008 19:33:46 -0700
Subject: [PATCH] Define/use get_init_pts_sb()

get_init_pts_sb() is identical to get_sb_single() except that it
consistently picks up the super-block from initial kernel mount.

get_sb_single() fails to pick up the initial kernel mount if there
has been an 'newinstance' mount of devpts since the initial kernel
mount.

Touch-tested

TODO:
	This patch leaves the 'get_sb_ref() function unused which can be
	deleted.

	If this makes sense, integrate this patch into ptsns patchset.
---
 fs/devpts/inode.c |   53 +++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 41 insertions(+), 12 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 941a3ce..27aa6d3 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -408,6 +408,38 @@ static int is_new_instance_mount(void *data)
 	return rc;
 }
 
+static int compare_init_pts_sb(struct super_block *s, void *p)
+{
+	if (devpts_mnt)
+		return devpts_mnt->mnt_sb == s;
+
+	return 0;
+}
+
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
 /*
  * Mount or remount the initial kernel mount of devpts. This type of
  * mount maintains the legacy, single-instance semantics, while the
@@ -418,21 +450,18 @@ static int init_pts_mount(struct file_system_type *fs_type, int flags,
 {
 	int err;
 
-	if (!devpts_mnt) {
-		err = get_sb_single(fs_type, flags, data, devpts_fill_super,
-				mnt);
-
-		err = mknod_ptmx(mnt->mnt_sb);
-		if (err) {
-			dput(mnt->mnt_sb->s_root);
-			deactivate_super(mnt->mnt_sb);
-		} else
-			devpts_mnt = mnt;
-
+	err = get_init_pts_sb(fs_type, flags, data, mnt);
+	if (err || devpts_mnt)
 		return err;
+
+	/* first mount of devpts - make ptmx node */
+	err = mknod_ptmx(mnt->mnt_sb);
+	if (err) {
+		dput(mnt->mnt_sb->s_root);
+		deactivate_super(mnt->mnt_sb);
 	}
 
-	return get_sb_ref(devpts_mnt->mnt_sb, flags, data, mnt);
+	return err;
 }
 
 static int devpts_get_sb(struct file_system_type *fs_type,
-- 
1.5.2.5
