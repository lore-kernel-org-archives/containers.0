From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH user-cr 2/2] add nsexeccwp to test clone-with-pids
Date: Mon, 16 Nov 2009 08:45:33 -0600
Message-ID: <20091116144532.GA20097@us.ibm.com>
References: <1258089886-10034-1-git-send-email-serue@us.ibm.com>
	<1258089886-10034-3-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1258089886-10034-3-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan T Lynch <natlynch-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Subject: [PATCH 1/1] nsexeccwp bugfixes

1. As Nathan pointed out, I was passing in stack bottom, not
stack top.  Our clone_with_pids() helper in user-cr/clone_${ARCH}.c
just accepts stack top.

2. The clone_with_pids() helper returns -errno on error, it
doesn't set errno.  Hande that right.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 nsexeccwp.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/nsexeccwp.c b/nsexeccwp.c
index 453fb8c..d4bf00c 100644
--- a/nsexeccwp.c
+++ b/nsexeccwp.c
@@ -304,6 +304,7 @@ int main(int argc, char *argv[])
 			perror("malloc");
 			return -1;
 		}
+		stack += stacksize - 1;
 
 		printf("about to clone with %lx\n", flags);
 		if (chosen_pid)
@@ -311,7 +312,8 @@ int main(int argc, char *argv[])
 		flags |= SIGCHLD;
 		pid = clone_with_pids(do_child, stack, flags, &pid_set,
 					(void *)argv);
-		if (pid == -1) {
+		if (pid < 0) {
+			errno = -pid;
 			perror("clone");
 			return -1;
 		}
-- 
1.6.1.1
