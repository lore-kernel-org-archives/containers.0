From: Greg Kurz <gkurz@fr.ibm.com>
Subject: [PATCH] Introduce ActivePid: in /proc/self/status (v3)
Date: Wed, 22 Jun 2011 17:44:46 +0200
Message-ID: <20110622154445.20926.21422.stgit@bahia.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org, serge@hallyn.com, daniel.lezcano@free.fr, ebiederm@xmission.com, oleg@redhat.com, xemul@openvz.org, clg@fr.ibm.com
List-Id: containers.vger.kernel.org

Since pid namespaces were introduced, there's a recurring demand: how one
can correlate a pid from a child pid ns with a pid from a parent pid ns ?
The need arises in the LXC community when one wants to send a signal from
the host (aka. init_pid_ns context) to a container process for which one
only knows the pid inside the container.

In the future, this should be achievable thanks to Eric Biederman's setns()
syscall but there's still some work to be done to support pid namespaces:

https://lkml.org/lkml/2011/5/21/162

As stated by Serge Hallyn in:

http://sourceforge.net/mailarchive/message.php?msg_id=27424447

"There is nothing that gives you a 100% guaranteed correct race-free
correspondence right now.  You can look under /proc/<pid>/root/proc/ to
see the pids valid in the container, and you can relate output of
lxc-ps --forest to ps --forest output.  But nothing under /proc that I
know of tells you "this task is the same as that task".  You can't
even look at /proc/<pid> inode numbers since they are different
filesystems for each proc mount."

This patch adds a single line to /proc/self/status. Provided one has kept
track of its container tasks (with a cgroup like liblxc does for example),
he may correlate global pids and container pids. This is still racy but
definitely easier than what we have today.

ChangeLog:
	v2: - changed Vpid: to ActivePid:
	    - lock ->sighand before calling task_active_pid_ns()
	v3: - use pid arg passed to task_state()

Signed-off-by: Greg Kurz <gkurz@fr.ibm.com>
Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
---

 fs/proc/array.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 5e4f776..b7316cc 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -183,12 +183,14 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 		"Pid:\t%d\n"
 		"PPid:\t%d\n"
 		"TracerPid:\t%d\n"
+		"ActivePid:\t%d\n"
 		"Uid:\t%d\t%d\t%d\t%d\n"
 		"Gid:\t%d\t%d\t%d\t%d\n",
 		get_task_state(p),
 		task_tgid_nr_ns(p, ns),
 		pid_nr_ns(pid, ns),
 		ppid, tpid,
+		pid_nr_ns(pid, ns_of_pid(pid)),
 		cred->uid, cred->euid, cred->suid, cred->fsuid,
 		cred->gid, cred->egid, cred->sgid, cred->fsgid);
 
