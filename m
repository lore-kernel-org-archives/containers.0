From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH] Define/use siginfo_from_ancestor_ns
Date: Tue, 11 Nov 2008 23:05:35 -0800
Message-ID: <20081112070535.GA28136@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quick patch implementing Oleg's suggestion. Touch tested and seems
to work fine in preventing container-init from being terminated from within
namespace.

---
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Mon, 10 Nov 2008 17:16:02 -0800
Subject: [PATCH] Define/use siginfo_from_ancestor_ns()

Container-init must appear like 'global-init' to processes within the
container and hence it must be immune to fatal signals from within the
container.  But container-init should appear like a normal process  to
processes in ancestor namespaces and so if same fatal signal is sent
by a process in parent namespace, the container-init must terminate.

There have been several attempts to meet these conflicting requirements
This patch (tries to) implement the approach suggested recently by Oleg
Nesterov.

Touch tested, but this is just a quick patch with couple of known issues.

TODO:
	- We need additional checks for stopped/traced processes.
	- If fatal signal is simultaneously received from descendant and
	  ancestor namespaces (in that order), the signal from ancestor
	  maybe ignored
	- sys_rt_sigqueueinfo() will fail if user-space sets si_pid to 0.

Signed-off-by <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 kernel/fork.c   |    1 +
 kernel/signal.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 28be39a..b0af4fb 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1117,6 +1117,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 
 		if (clone_flags & CLONE_NEWPID) {
 			retval = pid_ns_prepare_proc(p->nsproxy->pid_ns);
+			p->signal->flags |= SIGNAL_UNKILLABLE;
 			if (retval < 0)
 				goto bad_fork_free_pid;
 		}
diff --git a/kernel/signal.c b/kernel/signal.c
index 28a48ee..f635200 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1742,6 +1742,10 @@ static int ptrace_signal(int signr, siginfo_t *info,
 	return signr;
 }
 
+static inline int siginfo_from_ancestor_ns(siginfo_t *info)
+{
+	return SI_FROMUSER(info) && (info->si_pid == 0);
+}
 int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka,
 			  struct pt_regs *regs, void *cookie)
 {
@@ -1835,7 +1839,8 @@ relock:
 		 * Global init gets no signals it doesn't want.
 		 */
 		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
-		    !signal_group_exit(signal))
+				!siginfo_from_ancestor_ns(info) &&
+		    		!signal_group_exit(signal))
 			continue;
 
 		if (sig_kernel_stop(signr)) {
-- 
1.5.2.5
