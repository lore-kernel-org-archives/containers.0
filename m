From: sukadev@us.ibm.com
Subject: [PATCH 3/5] [V2] Use task_pid() to find leader's pid
Date: Thu, 19 Jul 2007 00:20:52 -0700
Message-ID: <20070719072052.GC28216@us.ibm.com>
References: <20070719071206.GE10195@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934599AbXGSHVO@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070719071206.GE10195@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org
Cc: Containers <containers@lists.osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>, Pavel Emelianov <xemul@openvz.org>
List-Id: containers.vger.kernel.org


Subject: [PATCH 3/5] Use task_pid() to find leader's pid

From: Sukadev Bhattiprolu <sukadev@us.ibm.com>

Use task_pid() to get leader's 'struct pid' and avoid the find_pid().

Signed-off-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>
Acked-by: Pavel Emelianov <xemul@openvz.org>

Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Cedric Le Goater <clg@fr.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>
Cc: Serge Hallyn <serue@us.ibm.com>
Cc: Herbert Poetzel <herbert@13thfloor.at>
---
 fs/exec.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: lx26-22-rc6-mm1a/fs/exec.c
===================================================================
--- lx26-22-rc6-mm1a.orig/fs/exec.c	2007-07-13 18:23:55.000000000 -0700
+++ lx26-22-rc6-mm1a/fs/exec.c	2007-07-16 12:56:22.000000000 -0700
@@ -908,7 +908,7 @@ static int de_thread(struct task_struct 
 		 */
 		detach_pid(tsk, PIDTYPE_PID);
 		tsk->pid = leader->pid;
-		attach_pid(tsk, PIDTYPE_PID,  find_pid(tsk->pid));
+		attach_pid(tsk, PIDTYPE_PID,  task_pid(leader));
 		transfer_pid(leader, tsk, PIDTYPE_PGID);
 		transfer_pid(leader, tsk, PIDTYPE_SID);
 		list_replace_rcu(&leader->tasks, &tsk->tasks);
