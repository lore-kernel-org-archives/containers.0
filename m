From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 09/43] mqueue: Explicitly capture the user namespace to send
	the notification to.
Date: Sat,  7 Apr 2012 22:15:05 -0700
Message-ID: <1333862139-31737-9-git-send-email-ebiederm@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Stop relying on user->user_ns which is going away and instead capture
the user_namespace of the process we are supposed to notify.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 ipc/mqueue.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 28bd64d..b53cf34 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -66,6 +66,7 @@ struct mqueue_inode_info {
 
 	struct sigevent notify;
 	struct pid* notify_owner;
+	struct user_namespace *notify_user_ns;
 	struct user_struct *user;	/* user who created, for accounting */
 	struct sock *notify_sock;
 	struct sk_buff *notify_cookie;
@@ -139,6 +140,7 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 		INIT_LIST_HEAD(&info->e_wait_q[0].list);
 		INIT_LIST_HEAD(&info->e_wait_q[1].list);
 		info->notify_owner = NULL;
+		info->notify_user_ns = NULL;
 		info->qsize = 0;
 		info->user = NULL;	/* set when all is ok */
 		memset(&info->attr, 0, sizeof(info->attr));
@@ -536,7 +538,7 @@ static void __do_notify(struct mqueue_inode_info *info)
 			rcu_read_lock();
 			sig_i.si_pid = task_tgid_nr_ns(current,
 						ns_of_pid(info->notify_owner));
-			sig_i.si_uid = user_ns_map_uid(info->user->user_ns,
+			sig_i.si_uid = user_ns_map_uid(info->notify_user_ns,
 						current_cred(), current_uid());
 			rcu_read_unlock();
 
@@ -550,7 +552,9 @@ static void __do_notify(struct mqueue_inode_info *info)
 		}
 		/* after notification unregisters process */
 		put_pid(info->notify_owner);
+		put_user_ns(info->notify_user_ns);
 		info->notify_owner = NULL;
+		info->notify_user_ns = NULL;
 	}
 	wake_up(&info->wait_q);
 }
@@ -575,7 +579,9 @@ static void remove_notification(struct mqueue_inode_info *info)
 		netlink_sendskb(info->notify_sock, info->notify_cookie);
 	}
 	put_pid(info->notify_owner);
+	put_user_ns(info->notify_user_ns);
 	info->notify_owner = NULL;
+	info->notify_user_ns = NULL;
 }
 
 static int mq_attr_ok(struct ipc_namespace *ipc_ns, struct mq_attr *attr)
@@ -1140,6 +1146,7 @@ retry:
 		}
 
 		info->notify_owner = get_pid(task_tgid(current));
+		info->notify_user_ns = get_user_ns(current_user_ns());
 		inode->i_atime = inode->i_ctime = CURRENT_TIME;
 	}
 	spin_unlock(&info->lock);
-- 
1.7.2.5
