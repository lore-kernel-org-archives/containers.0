From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH 1/2] pidns: Add a flag to indicate a pid namespace is dead.
Date: Thu, 08 Jul 2010 21:36:32 -0700
Message-ID: <m1r5jd5l0v.fsf_-_@fess.ebiederm.org>
References: <20100623203652.GA25298@redhat.com>
	<1277399329-18087-1-git-send-email-louis.rilling@kerlabs.com>
	<20100624191843.GA14205@redhat.com>
	<20100625102303.GG3773@hawkmoon.kerlabs.com>
	<20100625183733.GA2627@us.ibm.com> <20100625192945.GA25532@redhat.com>
	<20100625212618.GA11917@us.ibm.com>
	<20100625212758.GA30474@redhat.com>
	<20100625220713.GA31123@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100625220713.GA31123@us.ibm.com> (Sukadev Bhattiprolu's message of "Fri\, 25 Jun 2010 15\:07\:13 -0700")
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Louis Rilling <Louis.Rilling@kerlabs.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

Currently we have some subtle races when a pid namespace
exits and we need a simple way of close those races.

To close those races in a simple way I introduce an atomic
flag PIDNS_DEAD that we can teest to see if a pid namespace
has died.

When PIDNS_DEAD is set for a pid namespace all attempts to
lookup or add a pid to the pid namespace will fail.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/pid_namespace.h |    7 +++++++
 kernel/fork.c                 |    3 ++-
 kernel/pid.c                  |    7 +++++++
 kernel/pid_namespace.c        |    1 +
 4 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index 38d1032..dcee0b3 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -16,10 +16,17 @@ struct pidmap {
 
 struct bsd_acct_struct;
 
+enum pidns_flags {
+	PIDNS_DEAD, /* When set do not allow lookups of pids in the pid namespace,
+		     * or adding new pids to the pid namespace.
+		     */
+};
+
 struct pid_namespace {
 	struct kref kref;
 	struct pidmap pidmap[PIDMAP_ENTRIES];
 	int last_pid;
+	unsigned long flags;
 	struct task_struct *child_reaper;
 	struct kmem_cache *pid_cachep;
 	unsigned int level;
diff --git a/kernel/fork.c b/kernel/fork.c
index f36585c..9818b20 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1237,7 +1237,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	 * thread can't slip out of an OOM kill (or normal SIGKILL).
  	 */
 	recalc_sigpending();
-	if (signal_pending(current)) {
+	if (signal_pending(current) ||
+	    test_bit(PIDNS_DEAD, &p->nsproxy->pid_ns->flags)) {
 		spin_unlock(&current->sighand->siglock);
 		write_unlock_irq(&tasklist_lock);
 		retval = -ERESTARTNOINTR;
diff --git a/kernel/pid.c b/kernel/pid.c
index e9fd8c1..1a921c7 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -248,6 +248,10 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 	struct pid_namespace *tmp;
 	struct upid *upid;
 
+	pid = NULL;
+	if (test_bit(PIDNS_DEAD, &ns->flags))
+		goto out;
+
 	pid = kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL);
 	if (!pid)
 		goto out;
@@ -293,6 +297,9 @@ struct pid *find_pid_ns(int nr, struct pid_namespace *ns)
 	struct hlist_node *elem;
 	struct upid *pnr;
 
+	if (test_bit(PIDNS_DEAD, &ns->flags))
+		return NULL;
+
 	hlist_for_each_entry_rcu(pnr, elem,
 			&pid_hash[pid_hashfn(nr, ns)], pid_chain)
 		if (pnr->nr == nr && pnr->ns == ns)
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index cf8a562..92032d1 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -181,6 +181,7 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
 
 		nr = next_pidmap(pid_ns, nr);
 	}
+	set_bit(PIDNS_DEAD, &pid_ns->flags);
 	read_unlock(&tasklist_lock);
 
 	do {
-- 
1.6.5.2.143.g8cc62
