From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/6] pid:  Remove the child_reaper special case in init/main.c
Date: Sun, 20 Jun 2010 01:44:13 -0700
Message-ID: <m1ljaaqejm.fsf_-_@fess.ebiederm.org>
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


It turns out that the existing assignment in copy_process of
the child_reaper can handle the initial assignment of child_reaper
we just need to generalize the test in kernel/fork.c

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 init/main.c   |    9 ---------
 kernel/fork.c |    2 +-
 2 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/init/main.c b/init/main.c
index 3bdb152..38f7edc 100644
--- a/init/main.c
+++ b/init/main.c
@@ -865,15 +865,6 @@ static int __init kernel_init(void * unused)
 	 * init can run on any cpu.
 	 */
 	set_cpus_allowed_ptr(current, cpu_all_mask);
-	/*
-	 * Tell the world that we're going to be the grim
-	 * reaper of innocent orphaned children.
-	 *
-	 * We don't want people to have to make incorrect
-	 * assumptions about where in the task array this
-	 * can be found.
-	 */
-	init_pid_ns.child_reaper = current;
 
 	cad_pid = task_pid(current);
 
diff --git a/kernel/fork.c b/kernel/fork.c
index b6cce14..8b85b17 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1263,7 +1263,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		tracehook_finish_clone(p, clone_flags, trace);
 
 		if (thread_group_leader(p)) {
-			if (clone_flags & CLONE_NEWPID)
+			if (pid->numbers[pid->level].nr == 1)
 				p->nsproxy->pid_ns->child_reaper = p;
 
 			p->signal->leader_pid = pid;
-- 
1.6.5.2.143.g8cc62
