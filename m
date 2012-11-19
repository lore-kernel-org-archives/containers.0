From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 05/16] userns: Allow unprivileged users to create new
	namespaces
Date: Mon, 19 Nov 2012 07:12:30 -0800
Message-ID: <1353337961-12962-5-git-send-email-ebiederm@xmission.com>
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

If an unprivileged user has the appropriate capabilities in their
current user namespace allow the creation of new namespaces.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/nsproxy.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 7f8b051..a214e0e 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -122,6 +122,7 @@ out_ns:
 int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 {
 	struct nsproxy *old_ns = tsk->nsproxy;
+	struct user_namespace *user_ns = task_cred_xxx(tsk, user_ns);
 	struct nsproxy *new_ns;
 	int err = 0;
 
@@ -134,7 +135,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 				CLONE_NEWPID | CLONE_NEWNET)))
 		return 0;
 
-	if (!capable(CAP_SYS_ADMIN)) {
+	if (!ns_capable(user_ns, CAP_SYS_ADMIN)) {
 		err = -EPERM;
 		goto out;
 	}
@@ -191,7 +192,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 			       CLONE_NEWNET | CLONE_NEWPID)))
 		return 0;
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!nsown_capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
 	*new_nsp = create_new_namespaces(unshare_flags, current,
-- 
1.7.5.4
