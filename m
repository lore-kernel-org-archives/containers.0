From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 02/16] userns: Allow unprivileged users to create user
	namespaces.
Date: Mon, 19 Nov 2012 07:12:27 -0800
Message-ID: <1353337961-12962-2-git-send-email-ebiederm@xmission.com>
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

Now that we have been through every permission check in the kernel
having uid == 0 and gid == 0 in your local user namespace no
longer adds any special privileges.  Even having a full set
of caps in your local user namespace is safe because capabilies
are relative to your local user namespace, and do not confer
unexpected privileges.

Over the long term this should allow much more of the kernels
functionality to be safely used by non-root users.  Functionality
like unsharing the mount namespace that is only unsafe because
it can fool applications whose privileges are raised when they
are executed.  Since those applications have no privileges in
a user namespaces it becomes safe to spoof and confuse those
applications all you want.

Those capabilities will still need to be enabled carefully because
we may still need things like rlimits on the number of unprivileged
mounts but that is to avoid DOS attacks not to avoid fooling root
owned processes.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/fork.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 811ffba..8c29abb 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1569,14 +1569,6 @@ long do_fork(unsigned long clone_flags,
 		if (clone_flags & (CLONE_THREAD|CLONE_PARENT))
 			return -EINVAL;
 	}
-	if (clone_flags & CLONE_NEWUSER) {
-		/* hopefully this check will go away when userns support is
-		 * complete
-		 */
-		if (!capable(CAP_SYS_ADMIN) || !capable(CAP_SETUID) ||
-				!capable(CAP_SETGID))
-			return -EPERM;
-	}
 
 	/*
 	 * Determine whether and which event to report to ptracer.  When
-- 
1.7.5.4
