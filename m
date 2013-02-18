From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH net-next 2/4] net: proc: remove proc_net_fops_create
Date: Mon, 18 Feb 2013 19:34:55 +0800
Message-ID: <1361187297-2527-2-git-send-email-gaofeng__21215.6675210737$1361187293$gmane$org@cn.fujitsu.com>
References: <1361187297-2527-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1361187297-2527-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

proc_net_fops_create has been replaced by proc_create,
we can remove it now.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/proc/proc_net.c      | 8 --------
 include/linux/proc_fs.h | 3 ---
 2 files changed, 11 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index fe72cd0..30f7c67 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -177,14 +177,6 @@ const struct file_operations proc_net_operations = {
 	.readdir	= proc_tgid_net_readdir,
 };
 
-
-struct proc_dir_entry *proc_net_fops_create(struct net *net,
-	const char *name, umode_t mode, const struct file_operations *fops)
-{
-	return proc_create(name, mode, net->proc_net, fops);
-}
-EXPORT_SYMBOL_GPL(proc_net_fops_create);
-
 void proc_net_remove(struct net *net, const char *name)
 {
 	remove_proc_entry(name, net->proc_net);
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 32676b3..35ee189 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -171,8 +171,6 @@ static inline struct proc_dir_entry *create_proc_read_entry(const char *name,
 	return res;
 }
  
-extern struct proc_dir_entry *proc_net_fops_create(struct net *net,
-	const char *name, umode_t mode, const struct file_operations *fops);
 extern void proc_net_remove(struct net *net, const char *name);
 extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 	struct proc_dir_entry *parent);
@@ -184,7 +182,6 @@ extern int proc_alloc_inum(unsigned int *pino);
 extern void proc_free_inum(unsigned int inum);
 #else
 
-#define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
 static inline void proc_net_remove(struct net *net, const char *name) {}
 
 static inline void proc_flush_task(struct task_struct *task)
-- 
1.7.11.7
