From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH net-next 4/4] net: proc: remove proc_net_remove
Date: Mon, 18 Feb 2013 19:34:57 +0800
Message-ID: <1361187297-2527-4-git-send-email-gaofeng__5415.41907373375$1361187296$gmane$org@cn.fujitsu.com>
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

proc_net_remove has been replaced by remove_proc_entry.
we can remove it now.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/proc/proc_net.c      | 6 ------
 include/linux/proc_fs.h | 3 ---
 2 files changed, 9 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 30f7c67..3131a03 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -177,12 +177,6 @@ const struct file_operations proc_net_operations = {
 	.readdir	= proc_tgid_net_readdir,
 };
 
-void proc_net_remove(struct net *net, const char *name)
-{
-	remove_proc_entry(name, net->proc_net);
-}
-EXPORT_SYMBOL_GPL(proc_net_remove);
-
 static __net_init int proc_net_ns_init(struct net *net)
 {
 	struct proc_dir_entry *netd, *net_statd;
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 35ee189..319f694 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -171,7 +171,6 @@ static inline struct proc_dir_entry *create_proc_read_entry(const char *name,
 	return res;
 }
  
-extern void proc_net_remove(struct net *net, const char *name);
 extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 	struct proc_dir_entry *parent);
 
@@ -182,8 +181,6 @@ extern int proc_alloc_inum(unsigned int *pino);
 extern void proc_free_inum(unsigned int inum);
 #else
 
-static inline void proc_net_remove(struct net *net, const char *name) {}
-
 static inline void proc_flush_task(struct task_struct *task)
 {
 }
-- 
1.7.11.7
