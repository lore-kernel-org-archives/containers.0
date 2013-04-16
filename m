From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 25/28] proc: Supply an accessor to get the process ID
	associated with some proc files [RFC]
Date: Tue, 16 Apr 2013 19:27:30 +0100
Message-ID: <20130416182730.27773.88726.stgit@warthog.procyon.org.uk>
References: <20130416182550.27773.89310.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130416182550.27773.89310.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Supply an accessor to get the process ID associated with some proc files and
directories (get_proc_pid()).

Signed-off-by: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---

 fs/proc/base.c          |    5 +++++
 include/linux/proc_fs.h |    2 ++
 kernel/cgroup.c         |    3 +--
 kernel/cpuset.c         |    3 +--
 4 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index f2637c9..9ea16c8 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -157,6 +157,11 @@ static unsigned int pid_entry_count_dirs(const struct pid_entry *entries,
 	return count;
 }
 
+struct pid *get_proc_pid(const struct inode *inode)
+{
+	return PROC_I(inode)->pid;
+}
+
 static int get_task_root(struct task_struct *task, struct path *root)
 {
 	int result = -ENOENT;
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 718e966..7abc72a 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -88,6 +88,7 @@ extern void proc_set_size(struct proc_dir_entry *, loff_t);
 extern void proc_set_user(struct proc_dir_entry *, kuid_t, kgid_t);
 extern void *proc_get_parent_data(const struct inode *);
 extern const char *get_proc_name(const struct proc_dir_entry *);
+extern struct pid *get_proc_pid(const struct inode *);
 #else
 
 static inline void proc_flush_task(struct task_struct *task)
@@ -113,6 +114,7 @@ static inline struct proc_dir_entry *proc_mkdir_mode(const char *name,
 	umode_t mode, struct proc_dir_entry *parent) { return NULL; }
 static inline void proc_set_size(struct proc_dir_entry *de, loff_t size) {}
 static inline void proc_set_user(struct proc_dir_entry *de, kuid_t uid, kgid_t gid) {}
+static inline struct pid *get_proc_pid(const struct inode *inode) { return NULL; }
 
 #endif /* CONFIG_PROC_FS */
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a32f943..021548a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4823,8 +4823,7 @@ out:
 
 static int cgroup_open(struct inode *inode, struct file *file)
 {
-	struct pid *pid = PROC_I(inode)->pid;
-	return single_open(file, proc_cgroup_show, pid);
+	return single_open(file, proc_cgroup_show, get_proc_pid(inode));
 }
 
 const struct file_operations proc_cgroup_operations = {
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 4f9dfe4..0ec6edd 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2703,8 +2703,7 @@ out:
 
 static int cpuset_open(struct inode *inode, struct file *file)
 {
-	struct pid *pid = PROC_I(inode)->pid;
-	return single_open(file, proc_cpuset_show, pid);
+	return single_open(file, proc_cpuset_show, get_proc_pid(inode));
 }
 
 const struct file_operations proc_cpuset_operations = {
