From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [RFC][PATCH] locks: Allow disabling mandatory locking at compile time
Date: Wed, 11 Nov 2015 11:49:20 -0600
Message-ID: <876118v333.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Mandatory locking appears to be almost unused and buggy and there
appears no real interest in doing anything with it.  Since effectively
no one uses the code and since the code is buggy let's allow it to be
disabled at compile time.  I would just suggest removing the code but
undoubtedly that will break some piece of userspace code somewhere.

For the distributions that don't care about this piece of code
this gives a nice starting point to make mandatory locking go away.

Cc: Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Cc: J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---

A piece of userspace software having problematic interactions with
mandatory locking recently came up as an issue and I am wondering if
there are enough people actually using and interested in mandatory
locking that it makes sense to push people to support it, or if
mandatory locking should be confined to it's own little corner of
existence where it can wither and die.

From what little I can glean we want to discourage people from using
mandatory locking and to let it wither and die.  A Kconfig option that
allows mandatory locking to be disabled at compile time seems like the
first step in making that happen.  Perhaps in a decade or so when all
linux distributions are setting the option we can remove the code.

Does anyone know of any real world use cases of mandatory locking?

 fs/Kconfig         | 10 ++++++++
 fs/locks.c         |  2 ++
 fs/namespace.c     | 10 ++++++++
 include/linux/fs.h | 74 +++++++++++++++++++++++++++++-------------------------
 4 files changed, 62 insertions(+), 34 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index da3f32f1a4e4..59322e6e76f4 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -67,6 +67,16 @@ config FILE_LOCKING
           for filesystems like NFS and for the flock() system
           call. Disabling this option saves about 11k.
 
+config MANDATORY_FILE_LOCKING
+	bool "Enable Mandatory file locking"
+	depends on FILE_LOCKING
+	default y
+	help
+	  This option enables files appropriately marked files on appropriely
+	  mounted filesystems to support mandatory locking.
+
+	  To the best of my knowledge this is dead code that no one cares about.
+
 source "fs/notify/Kconfig"
 
 source "fs/quota/Kconfig"
diff --git a/fs/locks.c b/fs/locks.c
index 0d2b3267e2a3..86c94674ab22 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1191,6 +1191,7 @@ static int posix_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 	return error;
 }
 
+#ifdef CONFIG_MANDATORY_FILE_LOCKING
 /**
  * locks_mandatory_locked - Check for an active lock
  * @file: the file to check
@@ -1289,6 +1290,7 @@ int locks_mandatory_area(int read_write, struct inode *inode,
 }
 
 EXPORT_SYMBOL(locks_mandatory_area);
+#endif /* CONFIG_MANDATORY_FILE_LOCKING */
 
 static void lease_clear_pending(struct file_lock *fl, int arg)
 {
diff --git a/fs/namespace.c b/fs/namespace.c
index da70f7c4ece1..dee44b4791f0 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1584,6 +1584,14 @@ static inline bool may_mount(void)
 	return ns_capable(current->nsproxy->mnt_ns->user_ns, CAP_SYS_ADMIN);
 }
 
+static inline bool may_mandlock(void)
+{
+#ifndef	CONFIG_MANDATORY_FILE_LOCKING
+	return false;
+#endif
+	return true;
+}
+
 /*
  * Now umount can handle mount points as well as block devices.
  * This is important for filesystems which use unnamed block devices.
@@ -2667,6 +2675,8 @@ long do_mount(const char *dev_name, const char __user *dir_name,
 				   type_page, flags, data_page);
 	if (!retval && !may_mount())
 		retval = -EPERM;
+	if (!retval && (flags & MS_MANDLOCK) && !may_mandlock())
+		retval = -EPERM;
 	if (retval)
 		goto dput_out;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 08ae58dac726..e422714a0853 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2045,7 +2045,7 @@ extern struct kobject *fs_kobj;
 #define FLOCK_VERIFY_READ  1
 #define FLOCK_VERIFY_WRITE 2
 
-#ifdef CONFIG_FILE_LOCKING
+#ifdef CONFIG_MANDATORY_FILE_LOCKING
 extern int locks_mandatory_locked(struct file *);
 extern int locks_mandatory_area(int, struct inode *, struct file *, loff_t, size_t);
 
@@ -2090,6 +2090,45 @@ static inline int locks_verify_truncate(struct inode *inode,
 	return 0;
 }
 
+#else /* !CONFIG_MANDATORY_FILE_LOCKING */
+
+static inline int locks_mandatory_locked(struct file *file)
+{
+	return 0;
+}
+
+static inline int locks_mandatory_area(int rw, struct inode *inode,
+				       struct file *filp, loff_t offset,
+				       size_t count)
+{
+	return 0;
+}
+
+static inline int __mandatory_lock(struct inode *inode)
+{
+	return 0;
+}
+
+static inline int mandatory_lock(struct inode *inode)
+{
+	return 0;
+}
+
+static inline int locks_verify_locked(struct file *file)
+{
+	return 0;
+}
+
+static inline int locks_verify_truncate(struct inode *inode, struct file *filp,
+					size_t size)
+{
+	return 0;
+}
+
+#endif /* CONFIG_MANDATORY_FILE_LOCKING */
+
+
+#ifdef CONFIG_FILE_LOCKING
 static inline int break_lease(struct inode *inode, unsigned int mode)
 {
 	/*
@@ -2151,39 +2190,6 @@ static inline int break_layout(struct inode *inode, bool wait)
 }
 
 #else /* !CONFIG_FILE_LOCKING */
-static inline int locks_mandatory_locked(struct file *file)
-{
-	return 0;
-}
-
-static inline int locks_mandatory_area(int rw, struct inode *inode,
-				       struct file *filp, loff_t offset,
-				       size_t count)
-{
-	return 0;
-}
-
-static inline int __mandatory_lock(struct inode *inode)
-{
-	return 0;
-}
-
-static inline int mandatory_lock(struct inode *inode)
-{
-	return 0;
-}
-
-static inline int locks_verify_locked(struct file *file)
-{
-	return 0;
-}
-
-static inline int locks_verify_truncate(struct inode *inode, struct file *filp,
-					size_t size)
-{
-	return 0;
-}
-
 static inline int break_lease(struct inode *inode, unsigned int mode)
 {
 	return 0;
-- 
2.2.1
