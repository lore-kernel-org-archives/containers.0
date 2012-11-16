From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 08/11] pidns: Deny strange cases when creating pid namespaces.
Date: Fri, 16 Nov 2012 08:35:47 -0800
Message-ID: <1353083750-3621-8-git-send-email-ebiederm@xmission.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353083750-3621-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

task_active_pid_ns(current) != current->ns_proxy->pid_ns will
soon be allowed to support unshare and setns.

The definition of creating a child pid namespace when
task_active_pid_ns(current) != current->ns_proxy->pid_ns could be that
we create a child pid namespace of current->ns_proxy->pid_ns.  However
that leads to strange cases like trying to have a single process be
init in multiple pid namespaces, which is racy and hard to think
about.

The definition of creating a child pid namespace when
task_active_pid_ns(current) != current->ns_proxy->pid_ns could be that
we create a child pid namespace of task_active_pid_ns(current).  While
that seems less racy it does not provide any utility.

Therefore define the semantics of creating a child pid namespace when
task_active_pid_ns(current) != current->ns_proxy->pid_ns to be that the
pid namespace creation fails.  That is easy to implement and easy
to think about.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/pid_namespace.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index e106b18..066c058 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -145,6 +145,8 @@ struct pid_namespace *copy_pid_ns(unsigned long flags,
 		return get_pid_ns(old_ns);
 	if (flags & (CLONE_THREAD|CLONE_PARENT))
 		return ERR_PTR(-EINVAL);
+	if (task_active_pid_ns(current) != old_ns)
+		return ERR_PTR(-EINVAL);
 	return create_pid_namespace(user_ns, old_ns);
 }
 
-- 
1.7.5.4
