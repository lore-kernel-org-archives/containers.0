Return-Path: <SRS0=sUbK=FZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44474C433E0
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 16:58:25 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0369922525
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 16:58:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0369922525
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id B8872200ED;
	Mon, 21 Dec 2020 16:58:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1TOiV8r-bUp0; Mon, 21 Dec 2020 16:58:23 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 84431200E5;
	Mon, 21 Dec 2020 16:58:23 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7EA1BC1787;
	Mon, 21 Dec 2020 16:58:23 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B43C8C0893
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 16:58:21 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 9ED6387680
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 16:58:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id m3ZrnNigU2tf
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 16:58:20 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by hemlock.osuosl.org (Postfix) with ESMTPS id AD9588767B
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 16:58:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1608569899;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:in-reply-to:in-reply-to:references:references;
 bh=+i+JMKsqD72QK+018fcFda5qjUfGEpd+pjGX+hHsyHA=;
 b=hwKUAK+CVgG4pEEeYlKS9eI/Z95lCGvsxeXR1USvyc+siwNqwXlxTysdaMFym5rcU7jDWU
 F/fQzW5YBrq7aIDEXlnfmCtTBZTek1LE1qXbrPtgIfJkbxqKQOv5ztyajimPBwY7ZUzDOK
 anYeSmkg9yqZaa4dNQeTfRUjpdLQBJE=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-355-eyDwlp3XOU-p3EIRn1Fa9A-1; Mon, 21 Dec 2020 11:58:17 -0500
X-MC-Unique: eyDwlp3XOU-p3EIRn1Fa9A-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com
 [10.5.11.12])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 74A06801A9D;
 Mon, 21 Dec 2020 16:58:15 +0000 (UTC)
Received: from madcap2.tricolour.ca (unknown [10.10.110.9])
 by smtp.corp.redhat.com (Postfix) with ESMTP id AFF2560C0F;
 Mon, 21 Dec 2020 16:58:02 +0000 (UTC)
From: Richard Guy Briggs <rgb@redhat.com>
To: Linux Containers List <containers@lists.linux-foundation.org>,
 Linux API <linux-api@vger.kernel.org>,
 Linux-Audit Mailing List <linux-audit@redhat.com>,
 Linux FSdevel <linux-fsdevel@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Linux NetDev Upstream Mailing List <netdev@vger.kernel.org>,
 Netfilter Devel List <netfilter-devel@vger.kernel.org>
Subject: [PATCH ghak90 v10 09/11] audit: contid check descendancy and nesting
Date: Mon, 21 Dec 2020 11:55:43 -0500
Message-Id: <c089f67baff5abb060b0c1ba47273b2aa8cc6c41.1608225886.git.rgb@redhat.com>
In-Reply-To: <cover.1608225886.git.rgb@redhat.com>
References: <cover.1608225886.git.rgb@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Neil Horman <nhorman@tuxdriver.com>, Richard Guy Briggs <rgb@redhat.com>,
 David Howells <dhowells@redhat.com>,
 "Eric W. Biederman" <ebiederm@xmission.com>, Simo Sorce <simo@redhat.com>,
 Eric Paris <eparis@parisplace.org>, mpatel@redhat.com
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

Require the target task to be a descendant of the container
orchestrator/engine.

You would only change the audit container ID from one set or inherited
value to another if you were nesting containers.

If changing the contid, the container orchestrator/engine must be a
descendant and not same orchestrator as the one that set it so it is not
possible to change the contid of another orchestrator's container.

Since the task_is_descendant() function is used in YAMA and in audit,
remove the duplication and pull the function into kernel/core/sched.c

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
 include/linux/sched.h    |  3 +++
 kernel/audit.c           | 26 +++++++++++++++++++++++---
 kernel/sched/core.c      | 33 +++++++++++++++++++++++++++++++++
 security/yama/yama_lsm.c | 33 ---------------------------------
 4 files changed, 59 insertions(+), 36 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index b28348868b27..9e658e724543 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2055,4 +2055,7 @@ int sched_trace_rq_nr_running(struct rq *rq);
 
 const struct cpumask *sched_trace_rd_span(struct root_domain *rd);
 
+extern int task_is_descendant(struct task_struct *parent,
+			      struct task_struct *child);
+
 #endif
diff --git a/kernel/audit.c b/kernel/audit.c
index 8d03f07e7128..6eed8ed0cc8e 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -475,11 +475,13 @@ void audit_free(struct task_struct *tsk)
 	rcu_read_lock();
 	cont = _audit_contobj_get_bytask(tsk);
 	rcu_read_unlock();
-	spin_lock_irqsave(&_audit_contobj_list_lock, flags);
 	if (ns) {
 		audit_netns_contid_del(ns->net_ns, cont);
+		spin_lock_irqsave(&_audit_contobj_list_lock, flags);
 		_audit_contobj_put(cont);
+		spin_unlock_irqrestore(&_audit_contobj_list_lock, flags);
 	}
+	spin_lock_irqsave(&_audit_contobj_list_lock, flags);
 	_audit_contobj_put(cont);
 	spin_unlock_irqrestore(&_audit_contobj_list_lock, flags);
 	audit_free_syscall(tsk);
@@ -2923,6 +2925,21 @@ int audit_signal_info(int sig, struct task_struct *t)
 	return audit_signal_info_syscall(t);
 }
 
+static bool audit_contid_isnesting(struct task_struct *tsk)
+{
+	bool isowner = false;
+	bool ownerisparent = false;
+	struct audit_task_info *info = tsk->audit;
+
+	rcu_read_lock();
+	if (info && info->cont) {
+		isowner = current == info->cont->owner;
+		ownerisparent = task_is_descendant(info->cont->owner, current);
+	}
+	rcu_read_unlock();
+	return !isowner && ownerisparent;
+}
+
 /*
  * audit_set_contid - set current task's audit contid
  * @tsk: target task
@@ -2963,8 +2980,11 @@ int audit_set_contid(struct task_struct *tsk, u64 contid)
 		   !(thread_group_leader(tsk) && thread_group_empty(tsk))) {
 		/* if task has children or is not single-threaded, deny */
 		rc = -EBUSY;
-	} else if (info->cont) {
-		/* if contid is already set, deny */
+	} else if (tsk == current || !task_is_descendant(current, tsk)) {
+		/* if task is not descendant, block */
+		rc = -EXDEV;
+	} else if (info->cont && !audit_contid_isnesting(tsk)) {
+		/* only allow contid setting again if nesting */
 		rc = -EEXIST;
 	}
 	rcu_read_lock();
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index d2003a7d5ab5..6af7e6ee2498 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -8436,6 +8436,39 @@ void dump_cpu_task(int cpu)
 	sched_show_task(cpu_curr(cpu));
 }
 
+/*
+ * task_is_descendant - walk up a process family tree looking for a match
+ * @parent: the process to compare against while walking up from child
+ * @child: the process to start from while looking upwards for parent
+ *
+ * Returns 1 if child is a descendant of parent, 0 if not.
+ */
+int task_is_descendant(struct task_struct *parent,
+			      struct task_struct *child)
+{
+	int rc = 0;
+	struct task_struct *walker = child;
+
+	if (!parent || !child)
+		return 0;
+
+	rcu_read_lock();
+	if (!thread_group_leader(parent))
+		parent = rcu_dereference(parent->group_leader);
+	while (walker->pid > 0) {
+		if (!thread_group_leader(walker))
+			walker = rcu_dereference(walker->group_leader);
+		if (walker == parent) {
+			rc = 1;
+			break;
+		}
+		walker = rcu_dereference(walker->real_parent);
+	}
+	rcu_read_unlock();
+
+	return rc;
+}
+
 /*
  * Nice levels are multiplicative, with a gentle 10% change for every
  * nice level changed. I.e. when a CPU-bound task goes from nice 0 to
diff --git a/security/yama/yama_lsm.c b/security/yama/yama_lsm.c
index 06e226166aab..2930e42eafc2 100644
--- a/security/yama/yama_lsm.c
+++ b/security/yama/yama_lsm.c
@@ -262,39 +262,6 @@ static int yama_task_prctl(int option, unsigned long arg2, unsigned long arg3,
 	return rc;
 }
 
-/**
- * task_is_descendant - walk up a process family tree looking for a match
- * @parent: the process to compare against while walking up from child
- * @child: the process to start from while looking upwards for parent
- *
- * Returns 1 if child is a descendant of parent, 0 if not.
- */
-static int task_is_descendant(struct task_struct *parent,
-			      struct task_struct *child)
-{
-	int rc = 0;
-	struct task_struct *walker = child;
-
-	if (!parent || !child)
-		return 0;
-
-	rcu_read_lock();
-	if (!thread_group_leader(parent))
-		parent = rcu_dereference(parent->group_leader);
-	while (walker->pid > 0) {
-		if (!thread_group_leader(walker))
-			walker = rcu_dereference(walker->group_leader);
-		if (walker == parent) {
-			rc = 1;
-			break;
-		}
-		walker = rcu_dereference(walker->real_parent);
-	}
-	rcu_read_unlock();
-
-	return rc;
-}
-
 /**
  * ptracer_exception_found - tracer registered as exception for this tracee
  * @tracer: the task_struct of the process attempting ptrace
-- 
2.18.4

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
