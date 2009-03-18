From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Wed, 18 Mar 2009 12:50:04 -0700
Message-ID: <49C1506C.1080500@google.com>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>	<20090312162954.4a4b8e00@thinkcentre.lan>	<87fxhipfrh.fsf@caffeine.danplanet.com>	<20090312224820.GA12723@hallyn.com>	<87bps6pcyf.fsf@caffeine.danplanet.com>	<49C0B069.6060300@cs.columbia.edu>	<20090318134932.GC22636@us.ibm.com>	<878wn353mf.fsf@caffeine.danplanet.com>
	<49C1175F.9060600@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010404030001070209050100"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C1175F.9060600-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------010404030001070209050100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Cedric Le Goater wrote:
> Dan Smith wrote:
>> SH> (Note that in Dan's next version, he did move unshare into
>> SH> userspace)
>>
>> The idealist in me still wants it to be in the kernel.  However, after
>> seeing it done I agree that it's the right thing to do, at least in
>> this case.
> 
> I would say in all cases.
> 
> as you can't unshare(CLONE_NEWPID), 

Eric,

Is there a particular reason the above doesn't work?  I made an attempt 
to implement it a while back, but haven't convinced myself that signals 
and re-attaching a new struct pid to a running task is correct.

This should apply on top of Oren's ckpt v13 (based on 2.6.27-rc8). 
Consider this me floating the idea of adding support and I'll clean it 
up/rebase if you think it's useful.

Mike Waychison

--------------010404030001070209050100
Content-Type: text/plain;
 name="add-unshare-support"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="add-unshare-support"

Add unshare CLONE_NEWPID support

From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Add support for doing CLONE_NEWPID to sys_unshare().  Doing so requires that
the calling thread isn't sharing their signal handlers with anyone, or if they
are, they must also unshare their signal handler config at the same time.

Open issues:
   - I'm not 100% convinced I'm doing the right thing with pending signals.
   - I'm rewriting current's struct pid without any kind of synchronization.
   The lifetimes look alright to me, but it seems a little racy.  I can't think
   of any actual cases where we'd cause problems though: paths where we'd race
   would include cases where we go off and look at a struct pid's level, but
   then index in to get the pid_t out.  This is the same before and after we
   attach the pid to the task however, so maybe it's okay?

Signed-off-by: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---

 include/linux/pid.h |    2 ++
 kernel/fork.c       |   47 ++++++++++++++++++++++++++++++++++++++-
 kernel/nsproxy.c    |    2 +-
 kernel/pid.c        |   61 +++++++++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 105 insertions(+), 7 deletions(-)


diff --git a/include/linux/pid.h b/include/linux/pid.h
index d7e98ff..0ff4829 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -120,6 +120,8 @@ extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
 int next_pidmap(struct pid_namespace *pid_ns, int last);
 
 extern struct pid *alloc_pid(struct pid_namespace *ns);
+extern struct pid *alloc_pid_keep(struct pid_namespace *ns,
+				  struct pid *orig_pid);
 extern void free_pid(struct pid *pid);
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index 7ce2ebe..2db6f38 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1575,7 +1575,10 @@ asmlinkage long sys_unshare(unsigned long unshare_flags)
 	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
 				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
 				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWUSER|
-				CLONE_NEWNET))
+				CLONE_NEWNET|CLONE_NEWPID))
+		goto bad_unshare_out;
+	if ((unshare_flags & CLONE_NEWPID) && !(unshare_flags & CLONE_SIGHAND)
+	 && atomic_read(&current->sighand->count) > 1)
 		goto bad_unshare_out;
 
 	/*
@@ -1599,6 +1602,47 @@ asmlinkage long sys_unshare(unsigned long unshare_flags)
 			new_fs)))
 		goto bad_unshare_cleanup_fd;
 
+	if (unshare_flags & CLONE_NEWPID) {
+		struct pid *new_pid, *old_pid;
+		err = pid_ns_prepare_proc(new_nsproxy->pid_ns);
+		if (err)
+			goto bad_unshare_cleanup_nsproxy;
+		/* Give ourselves a pid. */
+		new_pid = alloc_pid_keep(new_nsproxy->pid_ns,
+					 ask_pid(current));
+		if (!new_pid)
+			goto bad_unshare_cleanup_nsproxy;
+
+		old_pid = task_pid(current);
+
+		write_lock_irq(&tasklist_lock);
+		spin_lock(&current->sighand->siglock);
+
+		/* TODO: Do we have to check if there are signals pending at
+		 * this point? */
+
+		current->pid = pid_nr(new_pid);
+		current->tgid = current->pid;
+		current->group_leader = current;
+		list_del_init(&current->thread_group);
+		new_nsproxy->pid_ns->child_reaper = current;
+		/*
+		 * TODO: Is this the right way to handle the signal updates?
+		 *
+		 * The guard that ensures that we specified CLONE_SIGHAND
+		 * currently ensures that we aren't sharing our sighand with
+		 * anyone else.
+		 */
+		current->signal->leader_pid = new_pid;
+
+		set_task_pgrp(current, pid_nr(new_pid));
+		set_task_session(current, pid_nr(new_pid));
+		detach_pid(current, PIDTYPE_PID);
+		attach_pid(current, PIDTYPE_PID, new_pid);
+		spin_unlock(&current->sighand->siglock);
+		write_unlock_irq(&tasklist_lock);
+	}
+
 	if (new_fs ||  new_mm || new_fd || do_sysvsem || new_nsproxy) {
 		if (do_sysvsem) {
 			/*
@@ -1638,6 +1682,7 @@ asmlinkage long sys_unshare(unsigned long unshare_flags)
 		task_unlock(current);
 	}
 
+bad_unshare_cleanup_nsproxy:
 	if (new_nsproxy)
 		put_nsproxy(new_nsproxy);
 
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 1d3ef29..23cafe7 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -189,7 +189,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 	int err = 0;
 
 	if (!(unshare_flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-			       CLONE_NEWUSER | CLONE_NEWNET)))
+			       CLONE_NEWUSER | CLONE_NEWNET | CLONE_NEWPID)))
 		return 0;
 
 	if (!capable(CAP_SYS_ADMIN))
diff --git a/kernel/pid.c b/kernel/pid.c
index 064e76a..3919b0d 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -239,10 +239,64 @@ void free_pid(struct pid *pid)
 	call_rcu(&pid->rcu, delayed_put_pid);
 }
 
+static void init_pid(struct pid_namespace *ns, struct pid *pid)
+{
+	enum pid_type type;
+	pid->level = ns->level;
+	atomic_set(&pid->count, 1);
+	for (type = 0; type < PIDTYPE_MAX; ++type)
+		INIT_HLIST_HEAD(&pid->tasks[type]);
+}
+
+struct pid *alloc_pid_keep(struct pid_namespace *ns, struct pid *orig_pid)
+{
+	struct pid *pid;
+	int i;
+	pid_t nr;
+
+	pid = kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL);
+	if (!pid)
+		goto out;
+
+	nr = alloc_pidmap(ns);
+	if (nr < 0)
+		goto out_free;
+	BUG_ON(nr != 1);
+
+	pid->numbers[ns->level].nr = nr;
+	pid->numbers[ns->level].ns = ns;
+	for (i = ns->level - 1; i >= 0; i--) {
+		/* Transfer the pid references to the new structure. */
+		pid->numbers[i].nr = orig_pid->numbers[i].nr;
+		orig_pid->numbers[i].nr = 0;
+
+		pid->numbers[i].ns = orig_pid->numbers[i].ns;
+	}
+
+	get_pid_ns(ns);
+	init_pid(ns, pid);
+
+	/* Update the hash tables.. */
+	spin_lock_irq(&pidmap_lock);
+	for (i = ns->level; i >= 0; i--) {
+		struct upid *upid;
+		upid = &pid->numbers[i];
+		/* put_pid will unhash the old upids */
+		hlist_add_head_rcu(&upid->pid_chain,
+				&pid_hash[pid_hashfn(upid->nr, upid->ns)]);
+	}
+	spin_unlock_irq(&pidmap_lock);
+
+out:
+	return pid;
+out_free:
+	kmem_cache_free(ns->pid_cachep, pid);
+	return NULL;
+}
+
 struct pid *alloc_pid(struct pid_namespace *ns)
 {
 	struct pid *pid;
-	enum pid_type type;
 	int i, nr;
 	struct pid_namespace *tmp;
 	struct upid *upid;
@@ -263,10 +317,7 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 	}
 
 	get_pid_ns(ns);
-	pid->level = ns->level;
-	atomic_set(&pid->count, 1);
-	for (type = 0; type < PIDTYPE_MAX; ++type)
-		INIT_HLIST_HEAD(&pid->tasks[type]);
+	init_pid(ns, pid);
 
 	spin_lock_irq(&pidmap_lock);
 	for (i = ns->level; i >= 0; i--) {

--------------010404030001070209050100
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------010404030001070209050100--
