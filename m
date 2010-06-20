From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/6] pidns: Don't allow new pids after the namespace is dead.
Date: Sun, 20 Jun 2010 01:47:09 -0700
Message-ID: <m1631eqeeq.fsf_-_@fess.ebiederm.org>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
	<20100617212003.GA4182@redhat.com>
	<20100618082033.GD16877@hawkmoon.kerlabs.com>
	<20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com>
	<20100618173320.GG16877@hawkmoon.kerlabs.com>
	<20100618175541.GA13680@redhat.com>
	<20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com>
	<m1pqzmqema.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqzmqema.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 20 Jun 2010 01\:42\:37 -0700")
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org


In the case of unsharing or joining a pid namespace, it becomes
possible to attempt to allocate a pid after zap_pid_namespace has
killed everything in the namespace.  Close the hole for now by simply
not allowing any of those pid allocations to succeed.  At least for
now it is too strange to think about.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/pid_namespace.h |    1 +
 kernel/pid.c                  |    4 ++++
 kernel/pid_namespace.c        |    2 ++
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index 38d1032..b447d37 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -20,6 +20,7 @@ struct pid_namespace {
 	struct kref kref;
 	struct pidmap pidmap[PIDMAP_ENTRIES];
 	int last_pid;
+	atomic_t dead;
 	struct task_struct *child_reaper;
 	struct kmem_cache *pid_cachep;
 	unsigned int level;
diff --git a/kernel/pid.c b/kernel/pid.c
index e9fd8c1..e1f26ec 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -248,6 +248,10 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 	struct pid_namespace *tmp;
 	struct upid *upid;
 
+	pid = NULL;
+	if (atomic_read(&ns->dead))
+		goto out;
+
 	pid = kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL);
 	if (!pid)
 		goto out;
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index b90e4ab..34a251d 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -90,6 +90,7 @@ static struct pid_namespace *create_pid_namespace(struct pid_namespace *parent_p
 	kref_init(&ns->kref);
 	ns->level = level;
 	ns->parent = get_pid_ns(parent_pid_ns);
+	atomic_set(&ns->dead, 0);
 
 	set_bit(0, ns->pidmap[0].page);
 	atomic_set(&ns->pidmap[0].nr_free, BITS_PER_PAGE - 1);
@@ -161,6 +162,7 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
 	 *
 	 */
 	read_lock(&tasklist_lock);
+	atomic_set(&pid_ns->dead, 1);
 	nr = next_pidmap(pid_ns, 1);
 	while (nr > 0) {
 		rcu_read_lock();
-- 
1.6.5.2.143.g8cc62
