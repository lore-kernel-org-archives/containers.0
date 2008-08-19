From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/6] Container Freezer: Document the cgroup freezer subsystem.
Date: Tue, 19 Aug 2008 16:22:38 -0700
Message-ID: <20080819232235.369649653__131.480457685207$1219191499$gmane$org@us.ibm.com>
References: <20080819232232.432973784@us.ibm.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Describe why we need the freezer subsystem and how to use it in a documentation
file. Since the cgroups.txt file is focused on the subsystem-agnostic portions
of cgroups make a directory and move the old cgroups.txt file at the same time.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 Documentation/cgroups.txt                   |  548 ----------------------------
 Documentation/cgroups/cgroups.txt           |  548 ++++++++++++++++++++++++++++
 Documentation/cgroups/freezer-subsystem.txt |   99 +++++
 Documentation/cpusets.txt                   |    2 
 4 files changed, 648 insertions(+), 549 deletions(-)

Index: linux-2.6.27-rc1-mm1/Documentation/cgroups.txt
===================================================================
--- linux-2.6.27-rc1-mm1.orig/Documentation/cgroups.txt
+++ /dev/null
@@ -1,548 +0,0 @@
-				CGROUPS
-				-------
-
-Written by Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> based on Documentation/cpusets.txt
-
-Original copyright statements from cpusets.txt:
-Portions Copyright (C) 2004 BULL SA.
-Portions Copyright (c) 2004-2006 Silicon Graphics, Inc.
-Modified by Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
-Modified by Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
-
-CONTENTS:
-=========
-
-1. Control Groups
-  1.1 What are cgroups ?
-  1.2 Why are cgroups needed ?
-  1.3 How are cgroups implemented ?
-  1.4 What does notify_on_release do ?
-  1.5 How do I use cgroups ?
-2. Usage Examples and Syntax
-  2.1 Basic Usage
-  2.2 Attaching processes
-3. Kernel API
-  3.1 Overview
-  3.2 Synchronization
-  3.3 Subsystem API
-4. Questions
-
-1. Control Groups
-=================
-
-1.1 What are cgroups ?
-----------------------
-
-Control Groups provide a mechanism for aggregating/partitioning sets of
-tasks, and all their future children, into hierarchical groups with
-specialized behaviour.
-
-Definitions:
-
-A *cgroup* associates a set of tasks with a set of parameters for one
-or more subsystems.
-
-A *subsystem* is a module that makes use of the task grouping
-facilities provided by cgroups to treat groups of tasks in
-particular ways. A subsystem is typically a "resource controller" that
-schedules a resource or applies per-cgroup limits, but it may be
-anything that wants to act on a group of processes, e.g. a
-virtualization subsystem.
-
-A *hierarchy* is a set of cgroups arranged in a tree, such that
-every task in the system is in exactly one of the cgroups in the
-hierarchy, and a set of subsystems; each subsystem has system-specific
-state attached to each cgroup in the hierarchy.  Each hierarchy has
-an instance of the cgroup virtual filesystem associated with it.
-
-At any one time there may be multiple active hierachies of task
-cgroups. Each hierarchy is a partition of all tasks in the system.
-
-User level code may create and destroy cgroups by name in an
-instance of the cgroup virtual file system, specify and query to
-which cgroup a task is assigned, and list the task pids assigned to
-a cgroup. Those creations and assignments only affect the hierarchy
-associated with that instance of the cgroup file system.
-
-On their own, the only use for cgroups is for simple job
-tracking. The intention is that other subsystems hook into the generic
-cgroup support to provide new attributes for cgroups, such as
-accounting/limiting the resources which processes in a cgroup can
-access. For example, cpusets (see Documentation/cpusets.txt) allows
-you to associate a set of CPUs and a set of memory nodes with the
-tasks in each cgroup.
-
-1.2 Why are cgroups needed ?
-----------------------------
-
-There are multiple efforts to provide process aggregations in the
-Linux kernel, mainly for resource tracking purposes. Such efforts
-include cpusets, CKRM/ResGroups, UserBeanCounters, and virtual server
-namespaces. These all require the basic notion of a
-grouping/partitioning of processes, with newly forked processes ending
-in the same group (cgroup) as their parent process.
-
-The kernel cgroup patch provides the minimum essential kernel
-mechanisms required to efficiently implement such groups. It has
-minimal impact on the system fast paths, and provides hooks for
-specific subsystems such as cpusets to provide additional behaviour as
-desired.
-
-Multiple hierarchy support is provided to allow for situations where
-the division of tasks into cgroups is distinctly different for
-different subsystems - having parallel hierarchies allows each
-hierarchy to be a natural division of tasks, without having to handle
-complex combinations of tasks that would be present if several
-unrelated subsystems needed to be forced into the same tree of
-cgroups.
-
-At one extreme, each resource controller or subsystem could be in a
-separate hierarchy; at the other extreme, all subsystems
-would be attached to the same hierarchy.
-
-As an example of a scenario (originally proposed by vatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org)
-that can benefit from multiple hierarchies, consider a large
-university server with various users - students, professors, system
-tasks etc. The resource planning for this server could be along the
-following lines:
-
-       CPU :           Top cpuset
-                       /       \
-               CPUSet1         CPUSet2
-                  |              |
-               (Profs)         (Students)
-
-               In addition (system tasks) are attached to topcpuset (so
-               that they can run anywhere) with a limit of 20%
-
-       Memory : Professors (50%), students (30%), system (20%)
-
-       Disk : Prof (50%), students (30%), system (20%)
-
-       Network : WWW browsing (20%), Network File System (60%), others (20%)
-                               / \
-                       Prof (15%) students (5%)
-
-Browsers like firefox/lynx go into the WWW network class, while (k)nfsd go
-into NFS network class.
-
-At the same time firefox/lynx will share an appropriate CPU/Memory class
-depending on who launched it (prof/student).
-
-With the ability to classify tasks differently for different resources
-(by putting those resource subsystems in different hierarchies) then
-the admin can easily set up a script which receives exec notifications
-and depending on who is launching the browser he can
-
-       # echo browser_pid > /mnt/<restype>/<userclass>/tasks
-
-With only a single hierarchy, he now would potentially have to create
-a separate cgroup for every browser launched and associate it with
-approp network and other resource class.  This may lead to
-proliferation of such cgroups.
-
-Also lets say that the administrator would like to give enhanced network
-access temporarily to a student's browser (since it is night and the user
-wants to do online gaming :))  OR give one of the students simulation
-apps enhanced CPU power,
-
-With ability to write pids directly to resource classes, it's just a
-matter of :
-
-       # echo pid > /mnt/network/<new_class>/tasks
-       (after some time)
-       # echo pid > /mnt/network/<orig_class>/tasks
-
-Without this ability, he would have to split the cgroup into
-multiple separate ones and then associate the new cgroups with the
-new resource classes.
-
-
-
-1.3 How are cgroups implemented ?
----------------------------------
-
-Control Groups extends the kernel as follows:
-
- - Each task in the system has a reference-counted pointer to a
-   css_set.
-
- - A css_set contains a set of reference-counted pointers to
-   cgroup_subsys_state objects, one for each cgroup subsystem
-   registered in the system. There is no direct link from a task to
-   the cgroup of which it's a member in each hierarchy, but this
-   can be determined by following pointers through the
-   cgroup_subsys_state objects. This is because accessing the
-   subsystem state is something that's expected to happen frequently
-   and in performance-critical code, whereas operations that require a
-   task's actual cgroup assignments (in particular, moving between
-   cgroups) are less common. A linked list runs through the cg_list
-   field of each task_struct using the css_set, anchored at
-   css_set->tasks.
-
- - A cgroup hierarchy filesystem can be mounted  for browsing and
-   manipulation from user space.
-
- - You can list all the tasks (by pid) attached to any cgroup.
-
-The implementation of cgroups requires a few, simple hooks
-into the rest of the kernel, none in performance critical paths:
-
- - in init/main.c, to initialize the root cgroups and initial
-   css_set at system boot.
-
- - in fork and exit, to attach and detach a task from its css_set.
-
-In addition a new file system, of type "cgroup" may be mounted, to
-enable browsing and modifying the cgroups presently known to the
-kernel.  When mounting a cgroup hierarchy, you may specify a
-comma-separated list of subsystems to mount as the filesystem mount
-options.  By default, mounting the cgroup filesystem attempts to
-mount a hierarchy containing all registered subsystems.
-
-If an active hierarchy with exactly the same set of subsystems already
-exists, it will be reused for the new mount. If no existing hierarchy
-matches, and any of the requested subsystems are in use in an existing
-hierarchy, the mount will fail with -EBUSY. Otherwise, a new hierarchy
-is activated, associated with the requested subsystems.
-
-It's not currently possible to bind a new subsystem to an active
-cgroup hierarchy, or to unbind a subsystem from an active cgroup
-hierarchy. This may be possible in future, but is fraught with nasty
-error-recovery issues.
-
-When a cgroup filesystem is unmounted, if there are any
-child cgroups created below the top-level cgroup, that hierarchy
-will remain active even though unmounted; if there are no
-child cgroups then the hierarchy will be deactivated.
-
-No new system calls are added for cgroups - all support for
-querying and modifying cgroups is via this cgroup file system.
-
-Each task under /proc has an added file named 'cgroup' displaying,
-for each active hierarchy, the subsystem names and the cgroup name
-as the path relative to the root of the cgroup file system.
-
-Each cgroup is represented by a directory in the cgroup file system
-containing the following files describing that cgroup:
-
- - tasks: list of tasks (by pid) attached to that cgroup
- - releasable flag: cgroup currently removeable?
- - notify_on_release flag: run the release agent on exit?
- - release_agent: the path to use for release notifications (this file
-   exists in the top cgroup only)
-
-Other subsystems such as cpusets may add additional files in each
-cgroup dir.
-
-New cgroups are created using the mkdir system call or shell
-command.  The properties of a cgroup, such as its flags, are
-modified by writing to the appropriate file in that cgroups
-directory, as listed above.
-
-The named hierarchical structure of nested cgroups allows partitioning
-a large system into nested, dynamically changeable, "soft-partitions".
-
-The attachment of each task, automatically inherited at fork by any
-children of that task, to a cgroup allows organizing the work load
-on a system into related sets of tasks.  A task may be re-attached to
-any other cgroup, if allowed by the permissions on the necessary
-cgroup file system directories.
-
-When a task is moved from one cgroup to another, it gets a new
-css_set pointer - if there's an already existing css_set with the
-desired collection of cgroups then that group is reused, else a new
-css_set is allocated. Note that the current implementation uses a
-linear search to locate an appropriate existing css_set, so isn't
-very efficient. A future version will use a hash table for better
-performance.
-
-To allow access from a cgroup to the css_sets (and hence tasks)
-that comprise it, a set of cg_cgroup_link objects form a lattice;
-each cg_cgroup_link is linked into a list of cg_cgroup_links for
-a single cgroup on its cgrp_link_list field, and a list of
-cg_cgroup_links for a single css_set on its cg_link_list.
-
-Thus the set of tasks in a cgroup can be listed by iterating over
-each css_set that references the cgroup, and sub-iterating over
-each css_set's task set.
-
-The use of a Linux virtual file system (vfs) to represent the
-cgroup hierarchy provides for a familiar permission and name space
-for cgroups, with a minimum of additional kernel code.
-
-1.4 What does notify_on_release do ?
-------------------------------------
-
-If the notify_on_release flag is enabled (1) in a cgroup, then
-whenever the last task in the cgroup leaves (exits or attaches to
-some other cgroup) and the last child cgroup of that cgroup
-is removed, then the kernel runs the command specified by the contents
-of the "release_agent" file in that hierarchy's root directory,
-supplying the pathname (relative to the mount point of the cgroup
-file system) of the abandoned cgroup.  This enables automatic
-removal of abandoned cgroups.  The default value of
-notify_on_release in the root cgroup at system boot is disabled
-(0).  The default value of other cgroups at creation is the current
-value of their parents notify_on_release setting. The default value of
-a cgroup hierarchy's release_agent path is empty.
-
-1.5 How do I use cgroups ?
---------------------------
-
-To start a new job that is to be contained within a cgroup, using
-the "cpuset" cgroup subsystem, the steps are something like:
-
- 1) mkdir /dev/cgroup
- 2) mount -t cgroup -ocpuset cpuset /dev/cgroup
- 3) Create the new cgroup by doing mkdir's and write's (or echo's) in
-    the /dev/cgroup virtual file system.
- 4) Start a task that will be the "founding father" of the new job.
- 5) Attach that task to the new cgroup by writing its pid to the
-    /dev/cgroup tasks file for that cgroup.
- 6) fork, exec or clone the job tasks from this founding father task.
-
-For example, the following sequence of commands will setup a cgroup
-named "Charlie", containing just CPUs 2 and 3, and Memory Node 1,
-and then start a subshell 'sh' in that cgroup:
-
-  mount -t cgroup cpuset -ocpuset /dev/cgroup
-  cd /dev/cgroup
-  mkdir Charlie
-  cd Charlie
-  /bin/echo 2-3 > cpuset.cpus
-  /bin/echo 1 > cpuset.mems
-  /bin/echo $$ > tasks
-  sh
-  # The subshell 'sh' is now running in cgroup Charlie
-  # The next line should display '/Charlie'
-  cat /proc/self/cgroup
-
-2. Usage Examples and Syntax
-============================
-
-2.1 Basic Usage
----------------
-
-Creating, modifying, using the cgroups can be done through the cgroup
-virtual filesystem.
-
-To mount a cgroup hierarchy will all available subsystems, type:
-# mount -t cgroup xxx /dev/cgroup
-
-The "xxx" is not interpreted by the cgroup code, but will appear in
-/proc/mounts so may be any useful identifying string that you like.
-
-To mount a cgroup hierarchy with just the cpuset and numtasks
-subsystems, type:
-# mount -t cgroup -o cpuset,numtasks hier1 /dev/cgroup
-
-To change the set of subsystems bound to a mounted hierarchy, just
-remount with different options:
-
-# mount -o remount,cpuset,ns  /dev/cgroup
-
-Note that changing the set of subsystems is currently only supported
-when the hierarchy consists of a single (root) cgroup. Supporting
-the ability to arbitrarily bind/unbind subsystems from an existing
-cgroup hierarchy is intended to be implemented in the future.
-
-Then under /dev/cgroup you can find a tree that corresponds to the
-tree of the cgroups in the system. For instance, /dev/cgroup
-is the cgroup that holds the whole system.
-
-If you want to create a new cgroup under /dev/cgroup:
-# cd /dev/cgroup
-# mkdir my_cgroup
-
-Now you want to do something with this cgroup.
-# cd my_cgroup
-
-In this directory you can find several files:
-# ls
-notify_on_release releasable tasks
-(plus whatever files added by the attached subsystems)
-
-Now attach your shell to this cgroup:
-# /bin/echo $$ > tasks
-
-You can also create cgroups inside your cgroup by using mkdir in this
-directory.
-# mkdir my_sub_cs
-
-To remove a cgroup, just use rmdir:
-# rmdir my_sub_cs
-
-This will fail if the cgroup is in use (has cgroups inside, or
-has processes attached, or is held alive by other subsystem-specific
-reference).
-
-2.2 Attaching processes
------------------------
-
-# /bin/echo PID > tasks
-
-Note that it is PID, not PIDs. You can only attach ONE task at a time.
-If you have several tasks to attach, you have to do it one after another:
-
-# /bin/echo PID1 > tasks
-# /bin/echo PID2 > tasks
-	...
-# /bin/echo PIDn > tasks
-
-You can attach the current shell task by echoing 0:
-
-# echo 0 > tasks
-
-3. Kernel API
-=============
-
-3.1 Overview
-------------
-
-Each kernel subsystem that wants to hook into the generic cgroup
-system needs to create a cgroup_subsys object. This contains
-various methods, which are callbacks from the cgroup system, along
-with a subsystem id which will be assigned by the cgroup system.
-
-Other fields in the cgroup_subsys object include:
-
-- subsys_id: a unique array index for the subsystem, indicating which
-  entry in cgroup->subsys[] this subsystem should be managing.
-
-- name: should be initialized to a unique subsystem name. Should be
-  no longer than MAX_CGROUP_TYPE_NAMELEN.
-
-- early_init: indicate if the subsystem needs early initialization
-  at system boot.
-
-Each cgroup object created by the system has an array of pointers,
-indexed by subsystem id; this pointer is entirely managed by the
-subsystem; the generic cgroup code will never touch this pointer.
-
-3.2 Synchronization
--------------------
-
-There is a global mutex, cgroup_mutex, used by the cgroup
-system. This should be taken by anything that wants to modify a
-cgroup. It may also be taken to prevent cgroups from being
-modified, but more specific locks may be more appropriate in that
-situation.
-
-See kernel/cgroup.c for more details.
-
-Subsystems can take/release the cgroup_mutex via the functions
-cgroup_lock()/cgroup_unlock().
-
-Accessing a task's cgroup pointer may be done in the following ways:
-- while holding cgroup_mutex
-- while holding the task's alloc_lock (via task_lock())
-- inside an rcu_read_lock() section via rcu_dereference()
-
-3.3 Subsystem API
------------------
-
-Each subsystem should:
-
-- add an entry in linux/cgroup_subsys.h
-- define a cgroup_subsys object called <name>_subsys
-
-Each subsystem may export the following methods. The only mandatory
-methods are create/destroy. Any others that are null are presumed to
-be successful no-ops.
-
-struct cgroup_subsys_state *create(struct cgroup_subsys *ss,
-				   struct cgroup *cgrp)
-(cgroup_mutex held by caller)
-
-Called to create a subsystem state object for a cgroup. The
-subsystem should allocate its subsystem state object for the passed
-cgroup, returning a pointer to the new object on success or a
-negative error code. On success, the subsystem pointer should point to
-a structure of type cgroup_subsys_state (typically embedded in a
-larger subsystem-specific object), which will be initialized by the
-cgroup system. Note that this will be called at initialization to
-create the root subsystem state for this subsystem; this case can be
-identified by the passed cgroup object having a NULL parent (since
-it's the root of the hierarchy) and may be an appropriate place for
-initialization code.
-
-void destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
-(cgroup_mutex held by caller)
-
-The cgroup system is about to destroy the passed cgroup; the subsystem
-should do any necessary cleanup and free its subsystem state
-object. By the time this method is called, the cgroup has already been
-unlinked from the file system and from the child list of its parent;
-cgroup->parent is still valid. (Note - can also be called for a
-newly-created cgroup if an error occurs after this subsystem's
-create() method has been called for the new cgroup).
-
-void pre_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
-(cgroup_mutex held by caller)
-
-Called before checking the reference count on each subsystem. This may
-be useful for subsystems which have some extra references even if
-there are not tasks in the cgroup.
-
-int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-	       struct task_struct *task)
-(cgroup_mutex held by caller)
-
-Called prior to moving a task into a cgroup; if the subsystem
-returns an error, this will abort the attach operation.  If a NULL
-task is passed, then a successful result indicates that *any*
-unspecified task can be moved into the cgroup. Note that this isn't
-called on a fork. If this method returns 0 (success) then this should
-remain valid while the caller holds cgroup_mutex.
-
-void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-	    struct cgroup *old_cgrp, struct task_struct *task)
-
-Called after the task has been attached to the cgroup, to allow any
-post-attachment activity that requires memory allocations or blocking.
-
-void fork(struct cgroup_subsy *ss, struct task_struct *task)
-
-Called when a task is forked into a cgroup.
-
-void exit(struct cgroup_subsys *ss, struct task_struct *task)
-
-Called during task exit.
-
-int populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
-
-Called after creation of a cgroup to allow a subsystem to populate
-the cgroup directory with file entries.  The subsystem should make
-calls to cgroup_add_file() with objects of type cftype (see
-include/linux/cgroup.h for details).  Note that although this
-method can return an error code, the error code is currently not
-always handled well.
-
-void post_clone(struct cgroup_subsys *ss, struct cgroup *cgrp)
-
-Called at the end of cgroup_clone() to do any paramater
-initialization which might be required before a task could attach.  For
-example in cpusets, no task may attach before 'cpus' and 'mems' are set
-up.
-
-void bind(struct cgroup_subsys *ss, struct cgroup *root)
-(cgroup_mutex held by caller)
-
-Called when a cgroup subsystem is rebound to a different hierarchy
-and root cgroup. Currently this will only involve movement between
-the default hierarchy (which never has sub-cgroups) and a hierarchy
-that is being created/destroyed (and hence has no sub-cgroups).
-
-4. Questions
-============
-
-Q: what's up with this '/bin/echo' ?
-A: bash's builtin 'echo' command does not check calls to write() against
-   errors. If you use it in the cgroup file system, you won't be
-   able to tell whether a command succeeded or failed.
-
-Q: When I attach processes, only the first of the line gets really attached !
-A: We can only return one error code per call to write(). So you should also
-   put only ONE pid.
-
Index: linux-2.6.27-rc1-mm1/Documentation/cgroups/cgroups.txt
===================================================================
--- /dev/null
+++ linux-2.6.27-rc1-mm1/Documentation/cgroups/cgroups.txt
@@ -0,0 +1,548 @@
+				CGROUPS
+				-------
+
+Written by Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> based on Documentation/cpusets.txt
+
+Original copyright statements from cpusets.txt:
+Portions Copyright (C) 2004 BULL SA.
+Portions Copyright (c) 2004-2006 Silicon Graphics, Inc.
+Modified by Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
+Modified by Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
+
+CONTENTS:
+=========
+
+1. Control Groups
+  1.1 What are cgroups ?
+  1.2 Why are cgroups needed ?
+  1.3 How are cgroups implemented ?
+  1.4 What does notify_on_release do ?
+  1.5 How do I use cgroups ?
+2. Usage Examples and Syntax
+  2.1 Basic Usage
+  2.2 Attaching processes
+3. Kernel API
+  3.1 Overview
+  3.2 Synchronization
+  3.3 Subsystem API
+4. Questions
+
+1. Control Groups
+=================
+
+1.1 What are cgroups ?
+----------------------
+
+Control Groups provide a mechanism for aggregating/partitioning sets of
+tasks, and all their future children, into hierarchical groups with
+specialized behaviour.
+
+Definitions:
+
+A *cgroup* associates a set of tasks with a set of parameters for one
+or more subsystems.
+
+A *subsystem* is a module that makes use of the task grouping
+facilities provided by cgroups to treat groups of tasks in
+particular ways. A subsystem is typically a "resource controller" that
+schedules a resource or applies per-cgroup limits, but it may be
+anything that wants to act on a group of processes, e.g. a
+virtualization subsystem.
+
+A *hierarchy* is a set of cgroups arranged in a tree, such that
+every task in the system is in exactly one of the cgroups in the
+hierarchy, and a set of subsystems; each subsystem has system-specific
+state attached to each cgroup in the hierarchy.  Each hierarchy has
+an instance of the cgroup virtual filesystem associated with it.
+
+At any one time there may be multiple active hierachies of task
+cgroups. Each hierarchy is a partition of all tasks in the system.
+
+User level code may create and destroy cgroups by name in an
+instance of the cgroup virtual file system, specify and query to
+which cgroup a task is assigned, and list the task pids assigned to
+a cgroup. Those creations and assignments only affect the hierarchy
+associated with that instance of the cgroup file system.
+
+On their own, the only use for cgroups is for simple job
+tracking. The intention is that other subsystems hook into the generic
+cgroup support to provide new attributes for cgroups, such as
+accounting/limiting the resources which processes in a cgroup can
+access. For example, cpusets (see Documentation/cpusets.txt) allows
+you to associate a set of CPUs and a set of memory nodes with the
+tasks in each cgroup.
+
+1.2 Why are cgroups needed ?
+----------------------------
+
+There are multiple efforts to provide process aggregations in the
+Linux kernel, mainly for resource tracking purposes. Such efforts
+include cpusets, CKRM/ResGroups, UserBeanCounters, and virtual server
+namespaces. These all require the basic notion of a
+grouping/partitioning of processes, with newly forked processes ending
+in the same group (cgroup) as their parent process.
+
+The kernel cgroup patch provides the minimum essential kernel
+mechanisms required to efficiently implement such groups. It has
+minimal impact on the system fast paths, and provides hooks for
+specific subsystems such as cpusets to provide additional behaviour as
+desired.
+
+Multiple hierarchy support is provided to allow for situations where
+the division of tasks into cgroups is distinctly different for
+different subsystems - having parallel hierarchies allows each
+hierarchy to be a natural division of tasks, without having to handle
+complex combinations of tasks that would be present if several
+unrelated subsystems needed to be forced into the same tree of
+cgroups.
+
+At one extreme, each resource controller or subsystem could be in a
+separate hierarchy; at the other extreme, all subsystems
+would be attached to the same hierarchy.
+
+As an example of a scenario (originally proposed by vatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org)
+that can benefit from multiple hierarchies, consider a large
+university server with various users - students, professors, system
+tasks etc. The resource planning for this server could be along the
+following lines:
+
+       CPU :           Top cpuset
+                       /       \
+               CPUSet1         CPUSet2
+                  |              |
+               (Profs)         (Students)
+
+               In addition (system tasks) are attached to topcpuset (so
+               that they can run anywhere) with a limit of 20%
+
+       Memory : Professors (50%), students (30%), system (20%)
+
+       Disk : Prof (50%), students (30%), system (20%)
+
+       Network : WWW browsing (20%), Network File System (60%), others (20%)
+                               / \
+                       Prof (15%) students (5%)
+
+Browsers like firefox/lynx go into the WWW network class, while (k)nfsd go
+into NFS network class.
+
+At the same time firefox/lynx will share an appropriate CPU/Memory class
+depending on who launched it (prof/student).
+
+With the ability to classify tasks differently for different resources
+(by putting those resource subsystems in different hierarchies) then
+the admin can easily set up a script which receives exec notifications
+and depending on who is launching the browser he can
+
+       # echo browser_pid > /mnt/<restype>/<userclass>/tasks
+
+With only a single hierarchy, he now would potentially have to create
+a separate cgroup for every browser launched and associate it with
+approp network and other resource class.  This may lead to
+proliferation of such cgroups.
+
+Also lets say that the administrator would like to give enhanced network
+access temporarily to a student's browser (since it is night and the user
+wants to do online gaming :))  OR give one of the students simulation
+apps enhanced CPU power,
+
+With ability to write pids directly to resource classes, it's just a
+matter of :
+
+       # echo pid > /mnt/network/<new_class>/tasks
+       (after some time)
+       # echo pid > /mnt/network/<orig_class>/tasks
+
+Without this ability, he would have to split the cgroup into
+multiple separate ones and then associate the new cgroups with the
+new resource classes.
+
+
+
+1.3 How are cgroups implemented ?
+---------------------------------
+
+Control Groups extends the kernel as follows:
+
+ - Each task in the system has a reference-counted pointer to a
+   css_set.
+
+ - A css_set contains a set of reference-counted pointers to
+   cgroup_subsys_state objects, one for each cgroup subsystem
+   registered in the system. There is no direct link from a task to
+   the cgroup of which it's a member in each hierarchy, but this
+   can be determined by following pointers through the
+   cgroup_subsys_state objects. This is because accessing the
+   subsystem state is something that's expected to happen frequently
+   and in performance-critical code, whereas operations that require a
+   task's actual cgroup assignments (in particular, moving between
+   cgroups) are less common. A linked list runs through the cg_list
+   field of each task_struct using the css_set, anchored at
+   css_set->tasks.
+
+ - A cgroup hierarchy filesystem can be mounted  for browsing and
+   manipulation from user space.
+
+ - You can list all the tasks (by pid) attached to any cgroup.
+
+The implementation of cgroups requires a few, simple hooks
+into the rest of the kernel, none in performance critical paths:
+
+ - in init/main.c, to initialize the root cgroups and initial
+   css_set at system boot.
+
+ - in fork and exit, to attach and detach a task from its css_set.
+
+In addition a new file system, of type "cgroup" may be mounted, to
+enable browsing and modifying the cgroups presently known to the
+kernel.  When mounting a cgroup hierarchy, you may specify a
+comma-separated list of subsystems to mount as the filesystem mount
+options.  By default, mounting the cgroup filesystem attempts to
+mount a hierarchy containing all registered subsystems.
+
+If an active hierarchy with exactly the same set of subsystems already
+exists, it will be reused for the new mount. If no existing hierarchy
+matches, and any of the requested subsystems are in use in an existing
+hierarchy, the mount will fail with -EBUSY. Otherwise, a new hierarchy
+is activated, associated with the requested subsystems.
+
+It's not currently possible to bind a new subsystem to an active
+cgroup hierarchy, or to unbind a subsystem from an active cgroup
+hierarchy. This may be possible in future, but is fraught with nasty
+error-recovery issues.
+
+When a cgroup filesystem is unmounted, if there are any
+child cgroups created below the top-level cgroup, that hierarchy
+will remain active even though unmounted; if there are no
+child cgroups then the hierarchy will be deactivated.
+
+No new system calls are added for cgroups - all support for
+querying and modifying cgroups is via this cgroup file system.
+
+Each task under /proc has an added file named 'cgroup' displaying,
+for each active hierarchy, the subsystem names and the cgroup name
+as the path relative to the root of the cgroup file system.
+
+Each cgroup is represented by a directory in the cgroup file system
+containing the following files describing that cgroup:
+
+ - tasks: list of tasks (by pid) attached to that cgroup
+ - releasable flag: cgroup currently removeable?
+ - notify_on_release flag: run the release agent on exit?
+ - release_agent: the path to use for release notifications (this file
+   exists in the top cgroup only)
+
+Other subsystems such as cpusets may add additional files in each
+cgroup dir.
+
+New cgroups are created using the mkdir system call or shell
+command.  The properties of a cgroup, such as its flags, are
+modified by writing to the appropriate file in that cgroups
+directory, as listed above.
+
+The named hierarchical structure of nested cgroups allows partitioning
+a large system into nested, dynamically changeable, "soft-partitions".
+
+The attachment of each task, automatically inherited at fork by any
+children of that task, to a cgroup allows organizing the work load
+on a system into related sets of tasks.  A task may be re-attached to
+any other cgroup, if allowed by the permissions on the necessary
+cgroup file system directories.
+
+When a task is moved from one cgroup to another, it gets a new
+css_set pointer - if there's an already existing css_set with the
+desired collection of cgroups then that group is reused, else a new
+css_set is allocated. Note that the current implementation uses a
+linear search to locate an appropriate existing css_set, so isn't
+very efficient. A future version will use a hash table for better
+performance.
+
+To allow access from a cgroup to the css_sets (and hence tasks)
+that comprise it, a set of cg_cgroup_link objects form a lattice;
+each cg_cgroup_link is linked into a list of cg_cgroup_links for
+a single cgroup on its cgrp_link_list field, and a list of
+cg_cgroup_links for a single css_set on its cg_link_list.
+
+Thus the set of tasks in a cgroup can be listed by iterating over
+each css_set that references the cgroup, and sub-iterating over
+each css_set's task set.
+
+The use of a Linux virtual file system (vfs) to represent the
+cgroup hierarchy provides for a familiar permission and name space
+for cgroups, with a minimum of additional kernel code.
+
+1.4 What does notify_on_release do ?
+------------------------------------
+
+If the notify_on_release flag is enabled (1) in a cgroup, then
+whenever the last task in the cgroup leaves (exits or attaches to
+some other cgroup) and the last child cgroup of that cgroup
+is removed, then the kernel runs the command specified by the contents
+of the "release_agent" file in that hierarchy's root directory,
+supplying the pathname (relative to the mount point of the cgroup
+file system) of the abandoned cgroup.  This enables automatic
+removal of abandoned cgroups.  The default value of
+notify_on_release in the root cgroup at system boot is disabled
+(0).  The default value of other cgroups at creation is the current
+value of their parents notify_on_release setting. The default value of
+a cgroup hierarchy's release_agent path is empty.
+
+1.5 How do I use cgroups ?
+--------------------------
+
+To start a new job that is to be contained within a cgroup, using
+the "cpuset" cgroup subsystem, the steps are something like:
+
+ 1) mkdir /dev/cgroup
+ 2) mount -t cgroup -ocpuset cpuset /dev/cgroup
+ 3) Create the new cgroup by doing mkdir's and write's (or echo's) in
+    the /dev/cgroup virtual file system.
+ 4) Start a task that will be the "founding father" of the new job.
+ 5) Attach that task to the new cgroup by writing its pid to the
+    /dev/cgroup tasks file for that cgroup.
+ 6) fork, exec or clone the job tasks from this founding father task.
+
+For example, the following sequence of commands will setup a cgroup
+named "Charlie", containing just CPUs 2 and 3, and Memory Node 1,
+and then start a subshell 'sh' in that cgroup:
+
+  mount -t cgroup cpuset -ocpuset /dev/cgroup
+  cd /dev/cgroup
+  mkdir Charlie
+  cd Charlie
+  /bin/echo 2-3 > cpuset.cpus
+  /bin/echo 1 > cpuset.mems
+  /bin/echo $$ > tasks
+  sh
+  # The subshell 'sh' is now running in cgroup Charlie
+  # The next line should display '/Charlie'
+  cat /proc/self/cgroup
+
+2. Usage Examples and Syntax
+============================
+
+2.1 Basic Usage
+---------------
+
+Creating, modifying, using the cgroups can be done through the cgroup
+virtual filesystem.
+
+To mount a cgroup hierarchy will all available subsystems, type:
+# mount -t cgroup xxx /dev/cgroup
+
+The "xxx" is not interpreted by the cgroup code, but will appear in
+/proc/mounts so may be any useful identifying string that you like.
+
+To mount a cgroup hierarchy with just the cpuset and numtasks
+subsystems, type:
+# mount -t cgroup -o cpuset,numtasks hier1 /dev/cgroup
+
+To change the set of subsystems bound to a mounted hierarchy, just
+remount with different options:
+
+# mount -o remount,cpuset,ns  /dev/cgroup
+
+Note that changing the set of subsystems is currently only supported
+when the hierarchy consists of a single (root) cgroup. Supporting
+the ability to arbitrarily bind/unbind subsystems from an existing
+cgroup hierarchy is intended to be implemented in the future.
+
+Then under /dev/cgroup you can find a tree that corresponds to the
+tree of the cgroups in the system. For instance, /dev/cgroup
+is the cgroup that holds the whole system.
+
+If you want to create a new cgroup under /dev/cgroup:
+# cd /dev/cgroup
+# mkdir my_cgroup
+
+Now you want to do something with this cgroup.
+# cd my_cgroup
+
+In this directory you can find several files:
+# ls
+notify_on_release releasable tasks
+(plus whatever files added by the attached subsystems)
+
+Now attach your shell to this cgroup:
+# /bin/echo $$ > tasks
+
+You can also create cgroups inside your cgroup by using mkdir in this
+directory.
+# mkdir my_sub_cs
+
+To remove a cgroup, just use rmdir:
+# rmdir my_sub_cs
+
+This will fail if the cgroup is in use (has cgroups inside, or
+has processes attached, or is held alive by other subsystem-specific
+reference).
+
+2.2 Attaching processes
+-----------------------
+
+# /bin/echo PID > tasks
+
+Note that it is PID, not PIDs. You can only attach ONE task at a time.
+If you have several tasks to attach, you have to do it one after another:
+
+# /bin/echo PID1 > tasks
+# /bin/echo PID2 > tasks
+	...
+# /bin/echo PIDn > tasks
+
+You can attach the current shell task by echoing 0:
+
+# echo 0 > tasks
+
+3. Kernel API
+=============
+
+3.1 Overview
+------------
+
+Each kernel subsystem that wants to hook into the generic cgroup
+system needs to create a cgroup_subsys object. This contains
+various methods, which are callbacks from the cgroup system, along
+with a subsystem id which will be assigned by the cgroup system.
+
+Other fields in the cgroup_subsys object include:
+
+- subsys_id: a unique array index for the subsystem, indicating which
+  entry in cgroup->subsys[] this subsystem should be managing.
+
+- name: should be initialized to a unique subsystem name. Should be
+  no longer than MAX_CGROUP_TYPE_NAMELEN.
+
+- early_init: indicate if the subsystem needs early initialization
+  at system boot.
+
+Each cgroup object created by the system has an array of pointers,
+indexed by subsystem id; this pointer is entirely managed by the
+subsystem; the generic cgroup code will never touch this pointer.
+
+3.2 Synchronization
+-------------------
+
+There is a global mutex, cgroup_mutex, used by the cgroup
+system. This should be taken by anything that wants to modify a
+cgroup. It may also be taken to prevent cgroups from being
+modified, but more specific locks may be more appropriate in that
+situation.
+
+See kernel/cgroup.c for more details.
+
+Subsystems can take/release the cgroup_mutex via the functions
+cgroup_lock()/cgroup_unlock().
+
+Accessing a task's cgroup pointer may be done in the following ways:
+- while holding cgroup_mutex
+- while holding the task's alloc_lock (via task_lock())
+- inside an rcu_read_lock() section via rcu_dereference()
+
+3.3 Subsystem API
+-----------------
+
+Each subsystem should:
+
+- add an entry in linux/cgroup_subsys.h
+- define a cgroup_subsys object called <name>_subsys
+
+Each subsystem may export the following methods. The only mandatory
+methods are create/destroy. Any others that are null are presumed to
+be successful no-ops.
+
+struct cgroup_subsys_state *create(struct cgroup_subsys *ss,
+				   struct cgroup *cgrp)
+(cgroup_mutex held by caller)
+
+Called to create a subsystem state object for a cgroup. The
+subsystem should allocate its subsystem state object for the passed
+cgroup, returning a pointer to the new object on success or a
+negative error code. On success, the subsystem pointer should point to
+a structure of type cgroup_subsys_state (typically embedded in a
+larger subsystem-specific object), which will be initialized by the
+cgroup system. Note that this will be called at initialization to
+create the root subsystem state for this subsystem; this case can be
+identified by the passed cgroup object having a NULL parent (since
+it's the root of the hierarchy) and may be an appropriate place for
+initialization code.
+
+void destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+(cgroup_mutex held by caller)
+
+The cgroup system is about to destroy the passed cgroup; the subsystem
+should do any necessary cleanup and free its subsystem state
+object. By the time this method is called, the cgroup has already been
+unlinked from the file system and from the child list of its parent;
+cgroup->parent is still valid. (Note - can also be called for a
+newly-created cgroup if an error occurs after this subsystem's
+create() method has been called for the new cgroup).
+
+void pre_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
+(cgroup_mutex held by caller)
+
+Called before checking the reference count on each subsystem. This may
+be useful for subsystems which have some extra references even if
+there are not tasks in the cgroup.
+
+int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+	       struct task_struct *task)
+(cgroup_mutex held by caller)
+
+Called prior to moving a task into a cgroup; if the subsystem
+returns an error, this will abort the attach operation.  If a NULL
+task is passed, then a successful result indicates that *any*
+unspecified task can be moved into the cgroup. Note that this isn't
+called on a fork. If this method returns 0 (success) then this should
+remain valid while the caller holds cgroup_mutex.
+
+void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+	    struct cgroup *old_cgrp, struct task_struct *task)
+
+Called after the task has been attached to the cgroup, to allow any
+post-attachment activity that requires memory allocations or blocking.
+
+void fork(struct cgroup_subsy *ss, struct task_struct *task)
+
+Called when a task is forked into a cgroup.
+
+void exit(struct cgroup_subsys *ss, struct task_struct *task)
+
+Called during task exit.
+
+int populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+
+Called after creation of a cgroup to allow a subsystem to populate
+the cgroup directory with file entries.  The subsystem should make
+calls to cgroup_add_file() with objects of type cftype (see
+include/linux/cgroup.h for details).  Note that although this
+method can return an error code, the error code is currently not
+always handled well.
+
+void post_clone(struct cgroup_subsys *ss, struct cgroup *cgrp)
+
+Called at the end of cgroup_clone() to do any paramater
+initialization which might be required before a task could attach.  For
+example in cpusets, no task may attach before 'cpus' and 'mems' are set
+up.
+
+void bind(struct cgroup_subsys *ss, struct cgroup *root)
+(cgroup_mutex held by caller)
+
+Called when a cgroup subsystem is rebound to a different hierarchy
+and root cgroup. Currently this will only involve movement between
+the default hierarchy (which never has sub-cgroups) and a hierarchy
+that is being created/destroyed (and hence has no sub-cgroups).
+
+4. Questions
+============
+
+Q: what's up with this '/bin/echo' ?
+A: bash's builtin 'echo' command does not check calls to write() against
+   errors. If you use it in the cgroup file system, you won't be
+   able to tell whether a command succeeded or failed.
+
+Q: When I attach processes, only the first of the line gets really attached !
+A: We can only return one error code per call to write(). So you should also
+   put only ONE pid.
+
Index: linux-2.6.27-rc1-mm1/Documentation/cgroups/freezer-subsystem.txt
===================================================================
--- /dev/null
+++ linux-2.6.27-rc1-mm1/Documentation/cgroups/freezer-subsystem.txt
@@ -0,0 +1,99 @@
+	The cgroup freezer is useful to batch job management system which start
+and stop sets of tasks in order to schedule the resources of a machine
+according to the desires of a system administrator. This sort of program
+is often used on HPC clusters to schedule access to the cluster as a
+whole. The cgroup freezer uses cgroups to describe the set of tasks to
+be started/stopped by the batch job management system. It also provides
+a means to start and stop the tasks composing the job.
+
+	The cgroup freezer will also be useful for checkpointing running groups
+of tasks. The freezer allows the checkpoint code to obtain a consistent
+image of the tasks by attempting to force the tasks in a cgroup into a
+quiescent state. Once the tasks are quiescent another task can
+walk /proc or invoke a kernel interface to gather information about the
+quiesced tasks. Checkpointed tasks can be restarted later should a
+recoverable error occur. This also allows the checkpointed tasks to be
+migrated between nodes in a cluster by copying the gathered information
+to another node and restarting the tasks there.
+
+	Sequences of SIGSTOP and SIGCONT are not always sufficient for stopping
+and resuming tasks in userspace. Both of these signals are observable
+from within the tasks we wish to freeze. While SIGSTOP cannot be caught,
+blocked, or ignored it can be seen by waiting or ptracing parent tasks.
+SIGCONT is especially unsuitable since it can be caught by the task. Any
+programs designed to watch for SIGSTOP and SIGCONT could be broken by
+attempting to use SIGSTOP and SIGCONT to stop and resume tasks. We can
+demonstrate this problem using nested bash shells:
+
+	$ echo $$
+	16644
+	$ bash
+	$ echo $$
+	16690
+
+	From a second, unrelated bash shell:
+	$ kill -SIGSTOP 16690
+	$ kill -SIGCONT 16990
+
+	<at this point 16990 exits and causes 16644 to exit too>
+
+	This happens because bash can observe both signals and choose how it
+responds to them.
+
+	Another example of a program which catches and responds to these
+signals is gdb. In fact any program designed to use ptrace is likely to
+have a problem with this method of stopping and resuming tasks.
+
+	 In contrast, the cgroup freezer uses the kernel freezer code to
+prevent the freeze/unfreeze cycle from becoming visible to the tasks
+being frozen. This allows the bash example above and gdb to run as
+expected.
+
+	The freezer subsystem in the container filesystem defines a file named
+freezer.state. Writing "FROZEN" to the state file will freeze all tasks in the
+cgroup. Subsequently writing "THAWED" will unfreeze the tasks in the cgroup.
+Reading will return the current state.
+
+* Examples of usage :
+
+   # mkdir /containers/freezer
+   # mount -t cgroup -ofreezer freezer  /containers
+   # mkdir /containers/0
+   # echo $some_pid > /containers/0/tasks
+
+to get status of the freezer subsystem :
+
+   # cat /containers/0/freezer.state
+   THAWED
+
+to freeze all tasks in the container :
+
+   # echo FROZEN > /containers/0/freezer.state
+   # cat /containers/0/freezer.state
+   FREEZING
+   # cat /containers/0/freezer.state
+   FROZEN
+
+to unfreeze all tasks in the container :
+
+   # echo THAWED > /containers/0/freezer.state
+   # cat /containers/0/freezer.state
+   THAWED
+
+This is the basic mechanism which should do the right thing for user space task
+in a simple scenario.
+
+It's important to note that freezing can be incomplete. In that case we return
+EBUSY. This means that some tasks in the cgroup are busy doing something that
+prevents us from completely freezing the cgroup at this time. After EBUSY,
+the cgroup will remain partially frozen -- reflected by freezer.state reporting
+"FREEZING" when read. The state will remain "FREEZING" until one of these
+things happens:
+
+	1) Userspace cancels the freezing operation by writing "THAWED" to
+		the freezer.state file
+	2) Userspace retries the freezing operation by writing "FROZEN" to
+		the freezer.state file (writing "FREEZING" is not legal
+		and returns EIO)
+	3) The tasks that blocked the cgroup from entering the "FROZEN"
+		state disappear from the cgroup's set of tasks.
Index: linux-2.6.27-rc1-mm1/Documentation/cpusets.txt
===================================================================
--- linux-2.6.27-rc1-mm1.orig/Documentation/cpusets.txt
+++ linux-2.6.27-rc1-mm1/Documentation/cpusets.txt
@@ -48,7 +48,7 @@ hooks, beyond what is already present, r
 job placement on large systems.
 
 Cpusets use the generic cgroup subsystem described in
-Documentation/cgroup.txt.
+Documentation/cgroups/cgroups.txt.
 
 Requests by a task, using the sched_setaffinity(2) system call to
 include CPUs in its CPU affinity mask, and using the mbind(2) and

-- 
