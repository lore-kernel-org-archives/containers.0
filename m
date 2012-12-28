From: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH/RFC] user_ns: fix missing limiting of user_ns counts
Date: Fri, 28 Dec 2012 21:56:27 +0400
Message-ID: <20121228175627.GA7683@cachalot>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Currently there is completely no limiting in number of user namespaces
created by unprivileged users.  One can freely create thousands of
user_ns'es and exhaust kernel memory without even bumping in
RLIMIT_NPROC or similar.

Even more -- it allows user to overflow kernel stack theoretically
allowing user to overwrite some important kernel data.  The problem is
that free_user_ns() may also free its parent user_namespace recursively
calling free_user_ns().  As kernel stack is very limited, it leads to
kernel stack overflow.

The code needs several checks.  First, noone should be able to create
user_ns of arbitrary depth.  Besides kernel stack overflow one could
create too big depth to DoS processes belonging to other users by
forcing them to loop a long time in cap_capable called from some
ns_capable() (e.g. in case one does smth like "ls -R /proc").  Second,
non-privileged users must not be able to overlimit some count of
namespaces to not be able to exhaust kernel memory.

The included patch is a basic fix for both or them.  Both values are
hardcoded here to 100 max depth and 1000 max in total.  I'm not sure how
better to make them configurable.  Looks like it needs some sysctl value
like kernel.max_user_ns_per_user, but also something more configurable
like new rlimit'ish limit may be created for user_ns needs.  E.g. in
case root wants one user to contain hundreds of private containers
(container owner user), but he doesn't want anybody to fill the kernel
with hundreds of containers multiplied by number of system users (equals
to thousands).

I'm not sure how it is an approved way for user_ns.  Eric?

A related issue which is NOT FIXED HERE is limits for all resources
available for containerized pseudo roots.  E.g. I succeeded creating
thousands of veth network devices without problems by a non-root user,
there seems no limit in number of network devices.  I suspect it is
possible to setup routing and net_ns'es the way it will be very
time-consuming for kernel to handle IP packets inside of ksoftirq, which
is not counted as this user scheduler time.   I suppose the issue is not
veth-specific, almost all newly available for unprivileged users code
pathes are vulnerable to DoS attacks.

Signed-off-by: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
-- 
 include/linux/sched.h   |    3 +++
 kernel/user_namespace.c |   26 ++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 206bb08..479940e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -706,6 +706,9 @@ struct user_struct {
 #ifdef CONFIG_EPOLL
 	atomic_long_t epoll_watches; /* The number of file descriptors currently watched */
 #endif
+#ifdef CONFIG_USER_NS
+	atomic_t user_namespaces; /* How many user_ns does this user created? */
+#endif
 #ifdef CONFIG_POSIX_MQUEUE
 	/* protected by mq_lock	*/
 	unsigned long mq_bytes;	/* How many bytes can be allocated to mqueue? */
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 2b042c4..a52c4e8 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -45,6 +45,16 @@ static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
 	cred->user_ns = user_ns;
 }
 
+static long get_user_ns_depth(struct user_namespace *ns)
+{
+	long depth;
+
+	for (depth = 1; ns != &init_user_ns; ns = ns->parent)
+		depth++;
+
+	return depth;
+}
+
 /*
  * Create a new user namespace, deriving the creator from the user in the
  * passed credentials, and replacing that user with the new root user for the
@@ -56,6 +66,7 @@ static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
 int create_user_ns(struct cred *new)
 {
 	struct user_namespace *ns, *parent_ns = new->user_ns;
+	struct user_struct *user = current->cred->user;
 	kuid_t owner = new->euid;
 	kgid_t group = new->egid;
 	int ret;
@@ -68,6 +79,18 @@ int create_user_ns(struct cred *new)
 	    !kgid_has_mapping(parent_ns, group))
 		return -EPERM;
 
+	/* Too long user_ns chains, might overflow kernel stack on kref_put() */
+	if (get_user_ns_depth(parent_ns) > 100)
+		return -ENOMEM;
+
+	atomic_inc(&user->user_namespaces);
+	/* FIXME: probably it's better to configure the number
+	 *        instead of hardcoding 1000 */
+	if (atomic_read(&user->user_namespaces) > 1000) {
+		atomic_dec(&user->user_namespaces);
+		return -ENOMEM;
+	}
+
 	ns = kmem_cache_zalloc(user_ns_cachep, GFP_KERNEL);
 	if (!ns)
 		return -ENOMEM;
@@ -108,10 +131,13 @@ void free_user_ns(struct kref *kref)
 {
 	struct user_namespace *parent, *ns =
 		container_of(kref, struct user_namespace, kref);
+	struct user_struct *user = find_user(ns->owner);
 
 	parent = ns->parent;
 	proc_free_inum(ns->proc_inum);
 	kmem_cache_free(user_ns_cachep, ns);
+	if (user)
+		atomic_dec(&user->user_namespaces);
 	put_user_ns(parent);
 }
 EXPORT_SYMBOL(free_user_ns);

-- 
Vasily Kulikov
http://www.openwall.com - bringing security into open computing environments
