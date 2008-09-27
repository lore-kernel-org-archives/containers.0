From: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: Re: [PATCH 08/10] Define get_sb_ref()
Date: Sat, 27 Sep 2008 13:29:24 -0700
Message-ID: <20080927202924.GA16208@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
	<20080912175308.GI17350@us.ibm.com>
	<1222286127.15523.66.camel@nimitz>
	<20080926212115.GD31505@us.ibm.com>
	<1222464662.25451.23.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1222464662.25451.23.camel@nimitz>
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

Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| On Fri, 2008-09-26 at 14:21 -0700, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
| > Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| > | On Fri, 2008-09-12 at 10:53 -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
| > | > + *     But for single-mount semantics, devpts cannot use get_sb_single(),
| > | > + *     because get_sb_single()/sget() find and use the super-block from
| > | > + *     the most recent mount of devpts. But that recent mount may be a
| > | > + *     'newinstance' mount and get_sb_single() would pick the newinstance
| > | > + *     super-block instead of the initial super-block.
| > | 
| > | Can't you just override the test() function to get what you want here?
| > 
| > get_sb_single() does not take a test() parameter and so I would still
| > need a get_sb_ref() or get_sb_special() interface right ? 
| > 
| > This special interface could call sget() with a custom-test function,
| > to get the super-block.  But in case of devpts, we already have the
| > super-block. So we don't need to call sget(). We just need get a reference
| > and remount.
| 
| Well, you shouldn't be using get_sb_single() at all any more, right?

How about something along these lines.

(applies on current devpts patchset.  Touch tested on 2.6.27-rc6+ttydev-0918)

Suka

---
From f021ad44e1b21bdc9f47c152830f40893fbaaf6a Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Sat, 27 Sep 2008 11:22:48 -0700
Subject: [PATCH] Define/use get_sb_specific()

See function header of get_sb_specific() for details of new interface.

TODO: 	This is a quick/dirty patch and needs to be properly integrated into
  	the patchset, by:
		- replace patch that defines get_sb_ref() with a patch that
		  defines get_sb_specific()
		- update patch that uses get_sb_ref() to use get_sb_specific()
		- extract common code in get_sb_specific() and get_sb_single()
		  into a new function ?
---
 fs/devpts/inode.c  |   20 +++++++++------
 fs/super.c         |   67 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/fs.h |    5 ++++
 3 files changed, 83 insertions(+), 9 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index c54b010..2f6bfb9 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -416,22 +416,26 @@ static int init_pts_mount(struct file_system_type *fs_type, int flags,
 		void *data, struct vfsmount *mnt)
 {
 	int err;
+	struct super_block *test_sb;
 
-	if (!devpts_mnt) {
-		err = get_sb_single(fs_type, flags, data, devpts_fill_super,
-				mnt);
+	test_sb = NULL;
+	if (devpts_mnt)
+		test_sb = devpts_mnt->mnt_sb;
 
+	err = get_sb_specific(fs_type, flags, data, devpts_fill_super,
+			test_sb, mnt);
+	if (err)
+		return err;
+
+	if (!devpts_mnt) {
 		err = mknod_ptmx(mnt->mnt_sb);
 		if (err) {
 			dput(mnt->mnt_sb->s_root);
 			deactivate_super(mnt->mnt_sb);
-		} else
-			devpts_mnt = mnt;
-
-		return err;
+		}
 	}
 
-	return get_sb_ref(devpts_mnt->mnt_sb, flags, data, mnt);
+	return err;
 }
 
 static int devpts_get_sb(struct file_system_type *fs_type,
diff --git a/fs/super.c b/fs/super.c
index ba7059c..e766bac 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -882,9 +882,74 @@ int get_sb_single(struct file_system_type *fs_type,
 }
 
 EXPORT_SYMBOL(get_sb_single);
+
+static int compare_specific(struct super_block *s, void *test_sb)
+{
+	return s == test_sb;
+}
+
+/*
+ * int get_sb_specific(fs_type, flags, *data, fill_super, test_sb, mnt)
+ *
+ * 	If super_block @test_sb exists, get it and remount it Otherwise,
+ * 	allocate a new super-block and mount it.
+ *
+ * 	This interface is needed to support multiple mounts in devpts while
+ * 	preserving backward compatibility of the current 'single-mount'
+ * 	semantics i.e all mounts of devpts without the 'newinstance' mount
+ * 	option should bind to the initial kernel mount, like get_sb_single().
+ * 	Mounts with 'newinstance' option create a new private namespace.
+ *
+ * 	But for single-mount semantics, devpts cannot use get_sb_single(),
+ * 	because get_sb_single()/sget() find and use the super-block from
+ * 	the most recent mount of devpts. But that recent mount may be a
+ * 	'newinstance' mount and get_sb_single() would pick the newinstance
+ * 	super-block instead of the initial super-block.
+ *
+ * TODO:
+ * 	Except for the sget() call and test_sb parameter, this
+ * 	function is identical to get_sb_single(). Extract common
+ * 	code to a separate function.
+ */
+
+ */
+int get_sb_specific(struct file_system_type *fs_type,
+	int flags, void *data,
+	int (*fill_super)(struct super_block *, void *, int),
+	struct super_block *test_sb,
+	struct vfsmount *mnt)
+{
+	struct super_block *s;
+	int error;
+
+	/*
+	 * Unlike other get_sb_* functions, the 'data' used for comparison
+	 * is different from the options data.
+	 *
+	 * We use set_anon_super() which ignores 'data' parameter, so
+	 * 'test_sb' being different from 'data' should not matter ?
+	 */
+	s = sget(fs_type, compare_specific, set_anon_super, test_sb);
+	if (IS_ERR(s))
+		return PTR_ERR(s);
+	if (!s->s_root) {
+		s->s_flags = flags;
+		error = fill_super(s, data, flags & MS_SILENT ? 1 : 0);
+		if (error) {
+			up_write(&s->s_umount);
+			deactivate_super(s);
+			return error;
+		}
+		s->s_flags |= MS_ACTIVE;
+	}
+	do_remount_sb(s, flags, data, 0);
+	return simple_set_mnt(mnt, s);
+}
+
+EXPORT_SYMBOL(get_sb_specific);
 /*
  * int get_sb_ref(struct super_block *sb, int flags, void *data,
-                struct vfsmount *mnt)
+ * 	struct vfsmount *mnt)
  *
  * 	This interface is needed to support multiple mounts in devpts while
  * 	preserving backward compatibility of the current 'single-mount'
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3bda46d..72fdfd5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1512,6 +1512,11 @@ extern int get_sb_single(struct file_system_type *fs_type,
 	int flags, void *data,
 	int (*fill_super)(struct super_block *, void *, int),
 	struct vfsmount *mnt);
+extern int get_sb_specific(struct file_system_type *fs_type,
+	int flags, void *data,
+	int (*fill_super)(struct super_block *, void *, int),
+	struct super_block *test_sb,
+	struct vfsmount *mnt);
 extern int get_sb_ref(struct super_block *sb, int flags, void *data,
 	struct vfsmount *mnt);
 extern int get_sb_nodev(struct file_system_type *fs_type,
-- 
1.5.2.5
