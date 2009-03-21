From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Sat, 21 Mar 2009 09:51:00 -0500
Message-ID: <20090321145100.GA23058@hallyn.com>
References: <49C1506C.1080500@google.com> <m1bprye5io.fsf@fess.ebiederm.org>
	<49C195CF.1080506@google.com> <m1ab7icodl.fsf@fess.ebiederm.org>
	<49C1A52D.4000503@google.com> <m1iqm6xkc7.fsf@fess.ebiederm.org>
	<20090320172616.GA7203@us.ibm.com>
	<m1d4cb3he5.fsf@fess.ebiederm.org>
	<20090321023834.GA21064@hallyn.com>
	<m1prgbzgqq.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1prgbzgqq.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> > What is wrong with Alexey's patch, which simply passes in the values
> >> > themselves?  Do you have another use in mind for the min/max pid
> >> > values?
> >> 
> >> At an implementation level (and I need to look at Alexey's specific patch)
> >> every patch I have seen to date creates their own version of alloc_pidmap.
> >
> > You're right, Alexey's patch creates a new one.
> >
> >> alloc_pidmap already implicitly takes min/max and first value to try
> >> as parameters.  RESERVED_PIDS, pid_max, and pid_ns->last_pid.  So
> >> instead of rewriting alloc_pidmap we should just be able to refactor
> >> alloc_pidmap to take the requisite values.  That should be less code
> >> and easier to maintain.
> >
> > Yeah, that sounds good actually.  Thanks.
> >
> >> Looking at the current implementation we also have the issue that
> >> pid_max is not per pid namespace.  Where it seems to belong.
> >
> > Eh.  It does seem to, but otoh why give userspace knobs it has no use
> > for...  Or, can you think of a case where it'd be useful?
> 
> In general the number of usable pid numbers should be larger in the outer
> pid namespace than in the child pid namespace.  Otherwise it is possible
> for the child to eat all of the possible pid numbers.
> 
> So I think it would be advantageous for to make containers designed to migrate
> to have a small pid_max by default so we know we won't overwhelm others.
> 
> Furthermore since pid_max is a limit on the identifiers allocated no on the
> number of processes it is very much a pid namespace property.

Right, I don't argue that it doesn't seem to belong there.  Well if
you think people would use it, it does seem simple enough to do.
Untested (well compile-tested) patch below just for grins.

> >> > I think that's a good guideline, bad rule.  Certainly possible
> >> > that you're right that this is just pointing to in-kernel
> >> > recreation of process tree as the way to go.  I was getting
> >> > that feeling myself, but then there are still very good reasons
> >> > not to do that, as there are things which each task should do
> >> > before completing sys_restart() which are best done in userspace.
> >> > These include for instance creating virtual nics, and calling
> >> > Oren's suggested 'cr_advise()' system calls.
> >> 
> >> You might be right.   I am behind on that part of the conversation.
> >> 
> >> My general concern is that dividing up the responsibilities between user space
> >> and kernel space seems harder to maintain, and refactor if we don't get something
> >> right the first time.
> >
> > So far we're actually still at the point where the code (Oren's set)
> > could go either way.  A small patch from Alexey can make it swing toward
> > kernel, while Oren's mktree.c userspace restart program swings the other
> > way.
> >
> > And since we're punting on any nested namespaces it actually may stay that way
> > for awhile.
> 
> Interesting.  That sounds fairly fundamental.  If I have some free time I will
> have to take a look.  I'm in favor of a kernel/user space cooperation but I don't
> currently see the benefit of fork processes in user space.

All right I'll wait for you to take a look, rather than repeat
myself :)  The biggest concern IMO is how to create complicated
resources (like a veth tunnel pair) in the kernel case.

thanks,
-serge

From 47303d729ec494add03fbddb47fac9a020d65f00 Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Sat, 21 Mar 2009 09:22:26 -0500
Subject: [PATCH 1/1] pid_ns: make pid_max a pid_ns property

Remove the pid_max global, and make it a property of the
pid_namespace.  When a pid_ns is created, it inherits
the parent's pid_ns.

Fixing up sysctl (trivial akin to ipc version, but
potentially tedious to get right for all CONFIG*
combinations) is left for later.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/pid_namespace.h |    1 +
 kernel/pid.c                  |   14 +++++++-------
 kernel/pid_namespace.c        |    6 ++++--
 kernel/sysctl.c               |    4 ++--
 4 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index 38d1032..fd7f497 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -30,6 +30,7 @@ struct pid_namespace {
 #ifdef CONFIG_BSD_PROCESS_ACCT
 	struct bsd_acct_struct *bacct;
 #endif
+	int pid_max;
 };
 
 extern struct pid_namespace init_pid_ns;
diff --git a/kernel/pid.c b/kernel/pid.c
index 1b3586f..898fa8b 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -43,8 +43,6 @@ static struct hlist_head *pid_hash;
 static int pidhash_shift;
 struct pid init_struct_pid = INIT_STRUCT_PID;
 
-int pid_max = PID_MAX_DEFAULT;
-
 #define RESERVED_PIDS		300
 
 int pid_max_min = RESERVED_PIDS + 1;
@@ -78,6 +76,7 @@ struct pid_namespace init_pid_ns = {
 	.last_pid = 0,
 	.level = 0,
 	.child_reaper = &init_task,
+	.pid_max = PID_MAX_DEFAULT,
 };
 EXPORT_SYMBOL_GPL(init_pid_ns);
 
@@ -128,11 +127,12 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 	struct pidmap *map;
 
 	pid = last + 1;
-	if (pid >= pid_max)
+	if (pid >= pid_ns->pid_max)
 		pid = RESERVED_PIDS;
 	offset = pid & BITS_PER_PAGE_MASK;
 	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
-	max_scan = (pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
+	max_scan = (pid_ns->pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE
+			- !offset;
 	for (i = 0; i <= max_scan; ++i) {
 		if (unlikely(!map->page)) {
 			void *page = kzalloc(PAGE_SIZE, GFP_KERNEL);
@@ -164,11 +164,11 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 			 * bitmap block and the final block was the same
 			 * as the starting point, pid is before last_pid.
 			 */
-			} while (offset < BITS_PER_PAGE && pid < pid_max &&
-					(i != max_scan || pid < last ||
+			} while (offset < BITS_PER_PAGE && pid < pid_ns->pid_max
+					&& (i != max_scan || pid < last ||
 					    !((last+1) & BITS_PER_PAGE_MASK)));
 		}
-		if (map < &pid_ns->pidmap[(pid_max-1)/BITS_PER_PAGE]) {
+		if (map < &pid_ns->pidmap[(pid_ns->pid_max-1)/BITS_PER_PAGE]) {
 			++map;
 			offset = 0;
 		} else {
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index fab8ea8..1ba3970 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -67,15 +67,17 @@ err_alloc:
 	return NULL;
 }
 
-static struct pid_namespace *create_pid_namespace(unsigned int level)
+static struct pid_namespace *create_pid_namespace(struct pid_namespace *old)
 {
 	struct pid_namespace *ns;
+	unsigned int level = old->level + 1;
 	int i;
 
 	ns = kmem_cache_zalloc(pid_ns_cachep, GFP_KERNEL);
 	if (ns == NULL)
 		goto out;
 
+	ns->pid_max = old->pid_max;
 	ns->pidmap[0].page = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!ns->pidmap[0].page)
 		goto out_free;
@@ -125,7 +127,7 @@ struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *old
 	if (flags & CLONE_THREAD)
 		goto out_put;
 
-	new_ns = create_pid_namespace(old_ns->level + 1);
+	new_ns = create_pid_namespace(old_ns);
 	if (!IS_ERR(new_ns))
 		new_ns->parent = get_pid_ns(old_ns);
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c5ef44f..8af16bd 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -48,6 +48,7 @@
 #include <linux/acpi.h>
 #include <linux/reboot.h>
 #include <linux/ftrace.h>
+#include <linux/pid_namespace.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -74,7 +75,6 @@ extern int max_threads;
 extern int core_uses_pid;
 extern int suid_dumpable;
 extern char core_pattern[];
-extern int pid_max;
 extern int min_free_kbytes;
 extern int pid_max_min, pid_max_max;
 extern int sysctl_drop_caches;
@@ -643,7 +643,7 @@ static struct ctl_table kern_table[] = {
 	{
 		.ctl_name	= KERN_PIDMAX,
 		.procname	= "pid_max",
-		.data		= &pid_max,
+		.data		= &init_pid_ns.pid_max,
 		.maxlen		= sizeof (int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-- 
1.5.6.3
