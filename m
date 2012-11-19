From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 14/16] proc: Generalize proc inode allocation
Date: Mon, 19 Nov 2012 07:12:39 -0800
Message-ID: <1353337961-12962-14-git-send-email-ebiederm@xmission.com>
References: <87lidx8wbo.fsf@xmission.com>
	<1353337961-12962-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353337961-12962-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Generalize the proc inode allocation so that it can be
used without having to having to create a proc_dir_entry.

This will allow namespace file descriptors to remain light
weight entitities but still have the same inode number
when the backing namespace is the same.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/generic.c       |   26 +++++++++++++-------------
 include/linux/proc_fs.h |   10 ++++++++++
 2 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 0d80cef..7b3ae3c 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -350,14 +350,14 @@ static DEFINE_SPINLOCK(proc_inum_lock); /* protects the above */
  * Return an inode number between PROC_DYNAMIC_FIRST and
  * 0xffffffff, or zero on failure.
  */
-static unsigned int get_inode_number(void)
+int proc_alloc_inum(unsigned int *inum)
 {
 	unsigned int i;
 	int error;
 
 retry:
-	if (ida_pre_get(&proc_inum_ida, GFP_KERNEL) == 0)
-		return 0;
+	if (!ida_pre_get(&proc_inum_ida, GFP_KERNEL))
+		return -ENOMEM;
 
 	spin_lock(&proc_inum_lock);
 	error = ida_get_new(&proc_inum_ida, &i);
@@ -365,18 +365,19 @@ retry:
 	if (error == -EAGAIN)
 		goto retry;
 	else if (error)
-		return 0;
+		return error;
 
 	if (i > UINT_MAX - PROC_DYNAMIC_FIRST) {
 		spin_lock(&proc_inum_lock);
 		ida_remove(&proc_inum_ida, i);
 		spin_unlock(&proc_inum_lock);
-		return 0;
+		return -ENOSPC;
 	}
-	return PROC_DYNAMIC_FIRST + i;
+	*inum = PROC_DYNAMIC_FIRST + i;
+	return 0;
 }
 
-static void release_inode_number(unsigned int inum)
+void proc_free_inum(unsigned int inum)
 {
 	spin_lock(&proc_inum_lock);
 	ida_remove(&proc_inum_ida, inum - PROC_DYNAMIC_FIRST);
@@ -554,13 +555,12 @@ static const struct inode_operations proc_dir_inode_operations = {
 
 static int proc_register(struct proc_dir_entry * dir, struct proc_dir_entry * dp)
 {
-	unsigned int i;
 	struct proc_dir_entry *tmp;
+	int ret;
 	
-	i = get_inode_number();
-	if (i == 0)
-		return -EAGAIN;
-	dp->low_ino = i;
+	ret = proc_alloc_inum(&dp->low_ino);
+	if (ret)
+		return ret;
 
 	if (S_ISDIR(dp->mode)) {
 		if (dp->proc_iops == NULL) {
@@ -764,7 +764,7 @@ EXPORT_SYMBOL(proc_create_data);
 
 static void free_proc_entry(struct proc_dir_entry *de)
 {
-	release_inode_number(de->low_ino);
+	proc_free_inum(de->low_ino);
 
 	if (S_ISLNK(de->mode))
 		kfree(de->data);
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 3144781..bf1d000 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -176,6 +176,8 @@ extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 extern struct file *proc_ns_fget(int fd);
 extern bool proc_ns_inode(struct inode *inode);
 
+extern int proc_alloc_inum(unsigned int *pino);
+extern void proc_free_inum(unsigned int inum);
 #else
 
 #define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
@@ -235,6 +237,14 @@ static inline bool proc_ns_inode(struct inode *inode)
 	return false;
 }
 
+static inline int proc_alloc_inum(unsigned int *inum)
+{
+	*inum = 1;
+	return 0;
+}
+static inline void proc_free_inum(unsigned int inum)
+{
+}
 #endif /* CONFIG_PROC_FS */
 
 #if !defined(CONFIG_PROC_KCORE)
-- 
1.7.5.4
