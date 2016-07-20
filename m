From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 06/10] utsns: Add a limit on the number of uts namespaces
Date: Tue, 19 Jul 2016 20:21:34 -0500
Message-ID: <20160720012138.7894-6-ebiederm@xmission.com>
References: <8737n5dscy.fsf@x220.int.ebiederm.org>
	<20160720012138.7894-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160720012138.7894-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/user_namespace.h |  1 +
 kernel/user_namespace.c        |  1 +
 kernel/utsname.c               | 31 ++++++++++++++++++++++++++-----
 3 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 80e7e5084f7d..10bb012a71d7 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -25,6 +25,7 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 enum ucounts {
 	UCOUNT_USER_NAMESPACES,
 	UCOUNT_PID_NAMESPACES,
+	UCOUNT_UTS_NAMESPACES,
 	UCOUNT_MAX,
 };
 
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index d9c3275278f5..4e019620f297 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -78,6 +78,7 @@ static int max = INT_MAX - 1;
 static struct ctl_table userns_table[] = {
 	UCOUNT_ENTRY("max_user_namespaces"),
 	UCOUNT_ENTRY("max_pid_namespaces"),
+	UCOUNT_ENTRY("max_uts_namespaces"),
 	{ }
 };
 #endif /* CONFIG_SYSCTL */
diff --git a/kernel/utsname.c b/kernel/utsname.c
index 831ea7108232..4f13c0419d64 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -17,6 +17,16 @@
 #include <linux/user_namespace.h>
 #include <linux/proc_ns.h>
 
+static bool inc_uts_namespaces(struct user_namespace *ns)
+{
+	return inc_ucount(ns, UCOUNT_UTS_NAMESPACES);
+}
+
+static void dec_uts_namespaces(struct user_namespace *ns)
+{
+	dec_ucount(ns, UCOUNT_UTS_NAMESPACES);
+}
+
 static struct uts_namespace *create_uts_ns(void)
 {
 	struct uts_namespace *uts_ns;
@@ -38,15 +48,18 @@ static struct uts_namespace *clone_uts_ns(struct user_namespace *user_ns,
 	struct uts_namespace *ns;
 	int err;
 
+	err = -ENFILE;
+	if (!inc_uts_namespaces(user_ns))
+		goto fail;
+
+	err = -ENOMEM;
 	ns = create_uts_ns();
 	if (!ns)
-		return ERR_PTR(-ENOMEM);
+		goto fail_dec;
 
 	err = ns_alloc_inum(&ns->ns);
-	if (err) {
-		kfree(ns);
-		return ERR_PTR(err);
-	}
+	if (err)
+		goto fail_free;
 
 	ns->ns.ops = &utsns_operations;
 
@@ -55,6 +68,13 @@ static struct uts_namespace *clone_uts_ns(struct user_namespace *user_ns,
 	ns->user_ns = get_user_ns(user_ns);
 	up_read(&uts_sem);
 	return ns;
+
+fail_free:
+	kfree(ns);
+fail_dec:
+	dec_uts_namespaces(user_ns);
+fail:
+	return ERR_PTR(err);
 }
 
 /*
@@ -85,6 +105,7 @@ void free_uts_ns(struct kref *kref)
 	struct uts_namespace *ns;
 
 	ns = container_of(kref, struct uts_namespace, kref);
+	dec_uts_namespaces(ns->user_ns);
 	put_user_ns(ns->user_ns);
 	ns_free_inum(&ns->ns);
 	kfree(ns);
-- 
2.8.3
