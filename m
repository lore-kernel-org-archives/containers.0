From: serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 4/7] cgroup: cgroup namespace setns support
Date: Fri, 27 Nov 2015 14:52:22 -0600
Message-ID: <1448657545-531-5-git-send-email-serge.hallyn__9043.04242362759$1448657582$gmane$org@ubuntu.com>
References: <1448657545-531-1-git-send-email-serge.hallyn@ubuntu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1448657545-531-1-git-send-email-serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

From: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

setns on a cgroup namespace is allowed only if
task has CAP_SYS_ADMIN in its current user-namespace and
over the user-namespace associated with target cgroupns.
No implicit cgroup changes happen with attaching to another
cgroupns. It is expected that the somone moves the attaching
process under the target cgroupns-root.

Signed-off-by: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c |   24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index c570957..0afed6b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5892,10 +5892,28 @@ err_out:
 	return ERR_PTR(err);
 }
 
-static int cgroupns_install(struct nsproxy *nsproxy, void *ns)
+static inline struct cgroup_namespace *to_cg_ns(struct ns_common *ns)
 {
-	pr_info("setns not supported for cgroup namespace");
-	return -EINVAL;
+	return container_of(ns, struct cgroup_namespace, ns);
+}
+
+static int cgroupns_install(struct nsproxy *nsproxy, struct ns_common *ns)
+{
+	struct cgroup_namespace *cgroup_ns = to_cg_ns(ns);
+
+	if (!ns_capable(current_user_ns(), CAP_SYS_ADMIN) ||
+	    !ns_capable(cgroup_ns->user_ns, CAP_SYS_ADMIN))
+		return -EPERM;
+
+	/* Don't need to do anything if we are attaching to our own cgroupns. */
+	if (cgroup_ns == nsproxy->cgroup_ns)
+		return 0;
+
+	get_cgroup_ns(cgroup_ns);
+	put_cgroup_ns(nsproxy->cgroup_ns);
+	nsproxy->cgroup_ns = cgroup_ns;
+
+	return 0;
 }
 
 static struct ns_common *cgroupns_get(struct task_struct *task)
-- 
1.7.9.5
