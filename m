From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH -last version] freezer_cg: disable writing freezer.state of
	root  cgroup
Date: Thu, 06 Nov 2008 10:01:42 +0800
Message-ID: <49125006.4050206__26299.3930875838$1225937320$gmane$org@cn.fujitsu.com>
References: <491245F1.5070707@cn.fujitsu.com>
	<6599ad830811051724p1f97026fl96be5efe38b33152@mail.gmail.com>
	<49124DFF.1090702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49124DFF.1090702-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
>> Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>
>> I might use the term "non-freezable" rather than "unfreezable".
>>
> 
> My bad English :(
> 
> patch updated. (some annoying leading tabs are also removed in the doc)
> 

And I forgot to s/EIO/EINVAL in the document..

This patch should be the last version.. Sorry for the bothering.


======================

From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date: Tue, 4 Nov 2008 15:26:29 +0800
Subject: [PATCH] freezer_cg: disable writing freezer.state of root cgroup

With this change, control file 'freezer.state' doesn't exist in root
cgroup, making root cgroup unfreezable.

I think it's reasonable to disallow freeze tasks in the root cgroup.
And then we can avoid fork overhead when freezer subsystem is
compiled but not used.

Also make writing invalid value to freezer.state returns EINVAL
rather than EIO. This is more consistent with other cgroup subsystem.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---

patch is based on freezer_cg-remove-task_lock-from-freezer_fork.patch

---
 Documentation/cgroups/freezer-subsystem.txt |   21 ++++++++++++---------
 kernel/cgroup_freezer.c                     |   11 ++++++++++-
 2 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/Documentation/cgroups/freezer-subsystem.txt b/Documentation/cgroups/freezer-subsystem.txt
index c50ab58..41f37fe 100644
--- a/Documentation/cgroups/freezer-subsystem.txt
+++ b/Documentation/cgroups/freezer-subsystem.txt
@@ -1,4 +1,4 @@
-	The cgroup freezer is useful to batch job management system which start
+The cgroup freezer is useful to batch job management system which start
 and stop sets of tasks in order to schedule the resources of a machine
 according to the desires of a system administrator. This sort of program
 is often used on HPC clusters to schedule access to the cluster as a
@@ -6,7 +6,7 @@ whole. The cgroup freezer uses cgroups to describe the set of tasks to
 be started/stopped by the batch job management system. It also provides
 a means to start and stop the tasks composing the job.
 
-	The cgroup freezer will also be useful for checkpointing running groups
+The cgroup freezer will also be useful for checkpointing running groups
 of tasks. The freezer allows the checkpoint code to obtain a consistent
 image of the tasks by attempting to force the tasks in a cgroup into a
 quiescent state. Once the tasks are quiescent another task can
@@ -16,7 +16,7 @@ recoverable error occur. This also allows the checkpointed tasks to be
 migrated between nodes in a cluster by copying the gathered information
 to another node and restarting the tasks there.
 
-	Sequences of SIGSTOP and SIGCONT are not always sufficient for stopping
+Sequences of SIGSTOP and SIGCONT are not always sufficient for stopping
 and resuming tasks in userspace. Both of these signals are observable
 from within the tasks we wish to freeze. While SIGSTOP cannot be caught,
 blocked, or ignored it can be seen by waiting or ptracing parent tasks.
@@ -37,26 +37,29 @@ demonstrate this problem using nested bash shells:
 
 	<at this point 16990 exits and causes 16644 to exit too>
 
-	This happens because bash can observe both signals and choose how it
+This happens because bash can observe both signals and choose how it
 responds to them.
 
-	Another example of a program which catches and responds to these
+Another example of a program which catches and responds to these
 signals is gdb. In fact any program designed to use ptrace is likely to
 have a problem with this method of stopping and resuming tasks.
 
-	 In contrast, the cgroup freezer uses the kernel freezer code to
+In contrast, the cgroup freezer uses the kernel freezer code to
 prevent the freeze/unfreeze cycle from becoming visible to the tasks
 being frozen. This allows the bash example above and gdb to run as
 expected.
 
-	The freezer subsystem in the container filesystem defines a file named
+The freezer subsystem in the container filesystem defines a file named
 freezer.state. Writing "FROZEN" to the state file will freeze all tasks in the
 cgroup. Subsequently writing "THAWED" will unfreeze the tasks in the cgroup.
 Reading will return the current state.
 
+Note freezer.state doesn't exist in root cgroup, which means root cgroup
+is non-freezable.
+
 * Examples of usage :
 
-   # mkdir /containers/freezer
+   # mkdir /containers
    # mount -t cgroup -ofreezer freezer  /containers
    # mkdir /containers/0
    # echo $some_pid > /containers/0/tasks
@@ -94,6 +97,6 @@ things happens:
 		the freezer.state file
 	2) Userspace retries the freezing operation by writing "FROZEN" to
 		the freezer.state file (writing "FREEZING" is not legal
-		and returns EIO)
+		and returns EINVAL)
 	3) The tasks that blocked the cgroup from entering the "FROZEN"
 		state disappear from the cgroup's set of tasks.
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 6605907..fb249e2 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -192,6 +192,13 @@ static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
 	 */
 	freezer = task_freezer(task);
 
+	/*
+	 * The root cgroup is non-freezable, so we can skip the
+	 * following check.
+	 */
+	if (!freezer->css.cgroup->parent)
+		return;
+
 	spin_lock_irq(&freezer->lock);
 	BUG_ON(freezer->state == CGROUP_FROZEN);
 
@@ -335,7 +342,7 @@ static int freezer_write(struct cgroup *cgroup,
 	else if (strcmp(buffer, freezer_state_strs[CGROUP_FROZEN]) == 0)
 		goal_state = CGROUP_FROZEN;
 	else
-		return -EIO;
+		return -EINVAL;
 
 	if (!cgroup_lock_live_group(cgroup))
 		return -ENODEV;
@@ -354,6 +361,8 @@ static struct cftype files[] = {
 
 static int freezer_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
 {
+	if (!cgroup->parent)
+		return 0;
 	return cgroup_add_files(cgroup, ss, files, ARRAY_SIZE(files));
 }
 
-- 
1.5.4.rc3
