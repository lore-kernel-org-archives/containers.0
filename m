From: Marco <marco.stornelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] Cgroup: add cgroup members's exit data statistics
Date: Tue, 02 Jun 2009 16:36:29 +0200
Message-ID: <4A2538ED.3030700__12539.240011438$1243954132$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Embedded <linux-embedded-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Marco Stornelli <marco.stornelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

This patch adds the possibility for an application to receive statistics information only
for processes belonging to a cgroup. The mechanism is the same of the cpu's exit data statistics.
With this patch, instead of waiting on a specific cpumask, an application can wait for
exit data on a specific container. Through this patch it's possible to have a simple death
notifier mechanism. We can select the processes to watch and wait for their death.
A death notify mechanism is especially useful for embedded systems.

Signed-off-by: Marco Stornelli <marco.stornelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

diff -uprN linux-2.6.29-orig/Documentation/accounting/getdelays.c linux-2.6.29/Documentation/accounting/getdelays.c
--- linux-2.6.29-orig/Documentation/accounting/getdelays.c	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/Documentation/accounting/getdelays.c	2009-06-02 15:47:01.000000000 +0200
@@ -77,9 +77,11 @@ static void usage(void)
 			"[-m cpumask] [-t tgid] [-p pid]\n");
 	fprintf(stderr, "  -d: print delayacct stats\n");
 	fprintf(stderr, "  -i: print IO accounting (works only with -p)\n");
+	fprintf(stderr, "  -q: print context switch accounting\n");
 	fprintf(stderr, "  -l: listen forever\n");
 	fprintf(stderr, "  -v: debug on\n");
-	fprintf(stderr, "  -C: container path\n");
+	fprintf(stderr, "  -C: container path (container statistics)\n");
+	fprintf(stderr, "  -N: container path (death notify)\n");
 }
 
 /*
@@ -263,13 +265,14 @@ int main(int argc, char *argv[])
 	char *logfile = NULL;
 	int loop = 0;
 	int containerset = 0;
+	int containernotify = 0;
 	char containerpath[1024];
 	int cfd = 0;
 
 	struct msgtemplate msg;
 
 	while (1) {
-		c = getopt(argc, argv, "qdiw:r:m:t:p:vlC:");
+		c = getopt(argc, argv, "qdiw:r:m:t:p:vlC:N:");
 		if (c < 0)
 			break;
 
@@ -290,6 +293,10 @@ int main(int argc, char *argv[])
 			containerset = 1;
 			strncpy(containerpath, optarg, strlen(optarg) + 1);
 			break;
+		case 'N':
+			containernotify = 1;
+			strncpy(containerpath, optarg, strlen(optarg) + 1);
+			break;
 		case 'w':
 			logfile = strdup(optarg);
 			printf("write to file %s\n", logfile);
@@ -364,8 +371,13 @@ int main(int argc, char *argv[])
 		}
 	}
 
-	if (tid && containerset) {
-		fprintf(stderr, "Select either -t or -C, not both\n");
+	if (tid && (containerset || containernotify)) {
+		fprintf(stderr, "Select either -t or -C or -N\n");
+		goto err;
+	}
+
+	if (containerset && containernotify) {
+		fprintf(stderr, "Select either -C or -N, not both\n");
 		goto err;
 	}
 
@@ -392,7 +404,23 @@ int main(int argc, char *argv[])
 			goto err;
 		}
 	}
-	if (!maskset && !tid && !containerset) {
+
+	if (containernotify) {
+		cfd = open(containerpath, O_RDONLY);
+		if (cfd < 0) {
+			perror("error opening container file");
+			goto err;
+		}
+		rc = send_cmd(nl_sd, id, mypid, CGROUPSTATS_CMD_GET,
+			      CGROUPSTATS_CMD_ATTR_REGISTER_FD,
+				&cfd, sizeof(__u32));
+		if (rc < 0) {
+			perror("error sending cgroupstats command");
+			goto err;
+		}
+	}
+
+	if (!maskset && !tid && !containerset && !containernotify) {
 		usage();
 		goto err;
 	}
@@ -400,6 +428,7 @@ int main(int argc, char *argv[])
 	do {
 		int i;
 
+		PRINTF("Recv...\n");
 		rep_len = recv(nl_sd, &msg, sizeof(msg), 0);
 		PRINTF("received %d bytes\n", rep_len);
 
@@ -495,6 +524,14 @@ done:
 		if (rc < 0)
 			err(rc, "error sending deregister cpumask\n");
 	}
+	if (containernotify) {
+		rc = send_cmd(nl_sd, id, mypid, CGROUPSTATS_CMD_GET,
+			      CGROUPSTATS_CMD_ATTR_DEREGISTER_FD,
+			      &cfd, sizeof(__u32));
+		printf("Sent deregister container, retval %d\n", rc);
+		if (rc < 0)
+			err(rc, "error sending deregister container\n");
+	}
 err:
 	close(nl_sd);
 	if (fd)
--- linux-2.6.29-orig/kernel/taskstats.c	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/kernel/taskstats.c	2009-06-02 15:54:37.000000000 +0200
@@ -56,6 +56,8 @@ __read_mostly = {
 static struct nla_policy
 cgroupstats_cmd_get_policy[CGROUPSTATS_CMD_ATTR_MAX+1] __read_mostly = {
 	[CGROUPSTATS_CMD_ATTR_FD] = { .type = NLA_U32 },
+	[CGROUPSTATS_CMD_ATTR_REGISTER_FD] = { .type = NLA_U32 },
+	[CGROUPSTATS_CMD_ATTR_DEREGISTER_FD] = { .type = NLA_U32 },
 };
 
 struct listener {
@@ -70,6 +72,16 @@ struct listener_list {
 };
 static DEFINE_PER_CPU(struct listener_list, listener_array);
 
+struct cgroup_listener {
+	struct list_head list;
+	pid_t pid;
+	char valid;
+	struct dentry *d_cgroup;
+	int ready_to_send;
+};
+
+static struct listener_list cgroup_listener_array;
+
 enum actions {
 	REGISTER,
 	DEREGISTER,
@@ -124,6 +136,63 @@ static int send_reply(struct sk_buff *sk
 }
 
 /*
+ * Send taskstats data in @skb to listeners registered for cgroup members exit
+ * data
+ */
+static void send_cgroup_listeners(struct sk_buff *skb,
+				struct listener_list *listeners)
+{
+	struct genlmsghdr *genlhdr = nlmsg_data(nlmsg_hdr(skb));
+	struct cgroup_listener *s, *tmp;
+	struct sk_buff *skb_next, *skb_cur = skb;
+	void *reply = genlmsg_data(genlhdr);
+	int rc, delcount = 0;
+
+	rc = genlmsg_end(skb, reply);
+	if (rc < 0) {
+		nlmsg_free(skb);
+		return;
+	}
+
+	rc = 0;
+	down_read(&listeners->sem);
+	list_for_each_entry(s, &listeners->list, list) {
+		if (!s->ready_to_send)
+			continue;
+		skb_next = NULL;
+		if (!list_is_last(&s->list, &listeners->list)) {
+			skb_next = skb_clone(skb_cur, GFP_KERNEL);
+			if (!skb_next)
+				break;
+		}
+		rc = genlmsg_unicast(skb_cur, s->pid);
+		if (rc == -ECONNREFUSED) {
+			s->valid = 0;
+			delcount++;
+		}
+		s->ready_to_send = 0;
+		skb_cur = skb_next;
+	}
+	up_read(&listeners->sem);
+
+	if (skb_cur)
+		nlmsg_free(skb_cur);
+
+	if (!delcount)
+		return;
+
+	/* Delete invalidated entries */
+	down_write(&listeners->sem);
+	list_for_each_entry_safe(s, tmp, &listeners->list, list) {
+		if (!s->valid) {
+			list_del(&s->list);
+			kfree(s);
+		}
+	}
+	up_write(&listeners->sem);
+}
+
+/*
  * Send taskstats data in @skb to listeners registered for @cpu's exit data
  */
 static void send_cpu_listeners(struct sk_buff *skb,
@@ -290,6 +359,43 @@ ret:
 	return;
 }
 
+
+static int add_cgroup_del_listener(pid_t pid, struct dentry *d_cgroup,
+								 int isadd)
+{
+	struct listener_list *listeners = &cgroup_listener_array;
+	struct cgroup_listener *s, *tmp;
+
+	if (isadd == REGISTER) {
+		s = kmalloc(sizeof(struct cgroup_listener), GFP_KERNEL);
+		if (!s)
+			goto cleanup;
+		s->pid = pid;
+		INIT_LIST_HEAD(&s->list);
+		s->valid = 1;
+		s->d_cgroup = d_cgroup;
+		s->ready_to_send = 0;
+
+		down_write(&listeners->sem);
+		list_add(&s->list, &listeners->list);
+		up_write(&listeners->sem);
+		return 0;
+	}
+
+	/* Deregister or cleanup */
+cleanup:
+	down_write(&listeners->sem);
+	list_for_each_entry_safe(s, tmp, &listeners->list, list) {
+		if (s->pid == pid) {
+			list_del(&s->list);
+			kfree(s);
+			break;
+		}
+	}
+	up_write(&listeners->sem);
+	return 0;
+}
+
 static int add_del_listener(pid_t pid, const struct cpumask *mask, int isadd)
 {
 	struct listener_list *listeners;
@@ -391,6 +497,32 @@ static int cgroupstats_user_cmd(struct s
 	struct file *file;
 	int fput_needed;
 
+	na = info->attrs[CGROUPSTATS_CMD_ATTR_REGISTER_FD];
+	if (na) {
+		fd = nla_get_u32(info->attrs[CGROUPSTATS_CMD_ATTR_REGISTER_FD]);
+		file = fget_light(fd, &fput_needed);
+		if (!file)
+			return 0;
+
+		rc = add_cgroup_del_listener(info->snd_pid, file->f_dentry,
+								REGISTER);
+		fput_light(file, fput_needed);
+		return rc;
+	}
+
+	na = info->attrs[CGROUPSTATS_CMD_ATTR_DEREGISTER_FD];
+	if (na) {
+		fd = nla_get_u32(info->attrs[CGROUPSTATS_CMD_ATTR_DEREGISTER_FD]);
+		file = fget_light(fd, &fput_needed);
+		if (!file)
+			return 0;
+
+		rc = add_cgroup_del_listener(info->snd_pid, file->f_dentry,
+								DEREGISTER);
+		fput_light(file, fput_needed);
+		return rc;
+	}
+
 	na = info->attrs[CGROUPSTATS_CMD_ATTR_FD];
 	if (!na)
 		return -EINVAL;
@@ -517,15 +649,32 @@ ret:
 	return sig->stats;
 }
 
+int check_ready_to_send(pid_t pid, struct listener_list *cgroup_list)
+{
+	struct listener_list *listeners = cgroup_list;
+	struct cgroup_listener *s, *tmp;
+	int ready = 0;
+
+	list_for_each_entry_safe(s, tmp, &listeners->list, list) {
+		if (cgroup_verify_pid(pid, s->d_cgroup) > 0) {
+			s->ready_to_send = 1;
+			ready = 1;
+		}
+	}
+
+	return ready;
+}
+
 /* Send pid data out on exit */
 void taskstats_exit(struct task_struct *tsk, int group_dead)
 {
 	int rc;
 	struct listener_list *listeners;
+	struct listener_list *cgroup_listeners = &cgroup_listener_array;
 	struct taskstats *stats;
 	struct sk_buff *rep_skb;
 	size_t size;
-	int is_thread_group;
+	int is_thread_group, target = 0;
 
 	if (!family_registered)
 		return;
@@ -545,7 +694,16 @@ void taskstats_exit(struct task_struct *
 	}
 
 	listeners = &__raw_get_cpu_var(listener_array);
-	if (list_empty(&listeners->list))
+	if (!list_empty(&listeners->list))
+		target |= CPU_TARGET;
+
+	down_write(&cgroup_listeners->sem);
+	if (!list_empty(&cgroup_listeners->list))
+		if (check_ready_to_send(tsk->pid, cgroup_listeners))
+			target |= CGROUP_TARGET;
+	up_write(&cgroup_listeners->sem);
+
+	if (!target)
 		return;
 
 	rc = prepare_reply(NULL, TASKSTATS_CMD_NEW, &rep_skb, size);
@@ -573,7 +731,10 @@ void taskstats_exit(struct task_struct *
 	memcpy(stats, tsk->signal->stats, sizeof(*stats));
 
 send:
-	send_cpu_listeners(rep_skb, listeners);
+	if (target & CPU_TARGET)
+		send_cpu_listeners(rep_skb, listeners);
+	if (target & CGROUP_TARGET)
+		send_cgroup_listeners(rep_skb, cgroup_listeners);
 	return;
 err:
 	nlmsg_free(rep_skb);
@@ -595,12 +756,15 @@ static struct genl_ops cgroupstats_ops =
 void __init taskstats_init_early(void)
 {
 	unsigned int i;
+	struct listener_list *listeners = &cgroup_listener_array;
 
 	taskstats_cache = KMEM_CACHE(taskstats, SLAB_PANIC);
 	for_each_possible_cpu(i) {
 		INIT_LIST_HEAD(&(per_cpu(listener_array, i).list));
 		init_rwsem(&(per_cpu(listener_array, i).sem));
 	}
+	INIT_LIST_HEAD(&listeners->list);
+	init_rwsem(&listeners->sem);
 }
 
 static int __init taskstats_init(void)
--- linux-2.6.29-orig/kernel/cgroup.c	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/kernel/cgroup.c	2009-06-02 15:50:57.000000000 +0200
@@ -2040,6 +2040,44 @@ static int pid_array_load(pid_t *pidarra
 }
 
 /**
+ * cgroup_verify_pid - it verifies if a pid is in a cgroup
+ * @dentry: A dentry entry belonging to the cgroup for which stats have
+ * been requested.
+ *
+ * Return value can be < 0 for error, 0 not pid not found, > 0 pid found
+ */
+int cgroup_verify_pid(pid_t pid, struct dentry *dentry)
+{
+	int ret = -EINVAL;
+	struct cgroup *cgrp;
+	struct cgroup_iter it;
+	struct task_struct *tsk;
+
+	/*
+	 * Validate dentry by checking the superblock operations,
+	 * and make sure it's a directory.
+	 */
+	if (dentry->d_sb->s_op != &cgroup_ops ||
+	    !S_ISDIR(dentry->d_inode->i_mode))
+		 goto err;
+
+	ret = 0;
+	cgrp = dentry->d_fsdata;
+
+	cgroup_iter_start(cgrp, &it);
+	while ((tsk = cgroup_iter_next(cgrp, &it))) {
+		if (tsk->pid == pid) {
+			cgroup_iter_end(cgrp, &it);
+			return 1;
+		}
+	}
+	cgroup_iter_end(cgrp, &it);
+
+err:
+	return ret;
+}
+
+/**
  * cgroupstats_build - build and fill cgroupstats
  * @stats: cgroupstats to fill information into
  * @dentry: A dentry entry belonging to the cgroup for which stats have
--- linux-2.6.29-orig/include/linux/cgroup.h	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/include/linux/cgroup.h	2009-06-02 15:55:11.000000000 +0200
@@ -32,6 +32,7 @@ extern void cgroup_fork(struct task_stru
 extern void cgroup_fork_callbacks(struct task_struct *p);
 extern void cgroup_post_fork(struct task_struct *p);
 extern void cgroup_exit(struct task_struct *p, int run_callbacks);
+extern int cgroup_verify_pid(pid_t pid, struct dentry *dentry);
 extern int cgroupstats_build(struct cgroupstats *stats,
 				struct dentry *dentry);
 
@@ -450,6 +451,10 @@ static inline void cgroup_exit(struct ta
 
 static inline void cgroup_lock(void) {}
 static inline void cgroup_unlock(void) {}
+static inline int cgroup_verify_pid(pid_t pid, struct dentry *dentry)
+{
+	return -EINVAL;
+}
 static inline int cgroupstats_build(struct cgroupstats *stats,
 					struct dentry *dentry)
 {
--- linux-2.6.29-orig/include/linux/cgroupstats.h	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/include/linux/cgroupstats.h	2009-06-01 11:37:46.000000000 +0200
@@ -63,6 +63,8 @@ enum {
 enum {
 	CGROUPSTATS_CMD_ATTR_UNSPEC = 0,
 	CGROUPSTATS_CMD_ATTR_FD,
+	CGROUPSTATS_CMD_ATTR_REGISTER_FD,
+	CGROUPSTATS_CMD_ATTR_DEREGISTER_FD,
 	__CGROUPSTATS_CMD_ATTR_MAX,
 };
 
--- linux-2.6.29-orig/include/linux/taskstats.h	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/include/linux/taskstats.h	2009-06-02 15:35:24.000000000 +0200
@@ -37,6 +37,9 @@
 #define TS_COMM_LEN		32	/* should be >= TASK_COMM_LEN
 					 * in linux/sched.h */
 
+#define CPU_TARGET			0x1
+#define CGROUP_TARGET			0x2
+
 struct taskstats {
 
 	/* The version number of this struct. This field is always set to
