From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 06/16] userns: Allow unprivileged use of setns.
Date: Mon, 19 Nov 2012 07:12:31 -0800
Message-ID: <1353337961-12962-6-git-send-email-ebiederm@xmission.com>
References: <87lidx8wbo.fsf@xmission.com>
	<1353337961-12962-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353337961-12962-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- Push the permission check from the core setns syscall into
  the setns install methods where the user namespace of the
  target namespace can be determined, and used in a ns_capable
  call.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 ipc/namespace.c          |    6 +++++-
 kernel/nsproxy.c         |    3 ---
 kernel/utsname.c         |    7 ++++++-
 net/core/net_namespace.c |    7 ++++++-
 4 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/ipc/namespace.c b/ipc/namespace.c
index f362298c..6ed33c0 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -161,8 +161,12 @@ static void ipcns_put(void *ns)
 	return put_ipc_ns(ns);
 }
 
-static int ipcns_install(struct nsproxy *nsproxy, void *ns)
+static int ipcns_install(struct nsproxy *nsproxy, void *new)
 {
+	struct ipc_namespace *ns = new;
+	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN))
+		return -EPERM;
+
 	/* Ditch state from the old ipc namespace */
 	exit_sem(current);
 	put_ipc_ns(nsproxy->ipc_ns);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index a214e0e..4357a0a 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -242,9 +242,6 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
 	struct file *file;
 	int err;
 
-	if (!capable(CAP_SYS_ADMIN))
-		return -EPERM;
-
 	file = proc_ns_fget(fd);
 	if (IS_ERR(file))
 		return PTR_ERR(file);
diff --git a/kernel/utsname.c b/kernel/utsname.c
index 679d97a..4a9362f 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -102,8 +102,13 @@ static void utsns_put(void *ns)
 	put_uts_ns(ns);
 }
 
-static int utsns_install(struct nsproxy *nsproxy, void *ns)
+static int utsns_install(struct nsproxy *nsproxy, void *new)
 {
+	struct uts_namespace *ns = new;
+
+	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN))
+		return -EPERM;
+
 	get_uts_ns(ns);
 	put_uts_ns(nsproxy->uts_ns);
 	nsproxy->uts_ns = ns;
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 6456439..ec2870b 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -630,8 +630,13 @@ static void netns_put(void *ns)
 
 static int netns_install(struct nsproxy *nsproxy, void *ns)
 {
+	struct net *net = ns;
+
+	if (!ns_capable(net->user_ns, CAP_SYS_ADMIN))
+		return -EPERM;
+
 	put_net(nsproxy->net_ns);
-	nsproxy->net_ns = get_net(ns);
+	nsproxy->net_ns = get_net(net);
 	return 0;
 }
 
-- 
1.7.5.4
