From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH] pid_ns: Sleep in TASK_INTERRUPTIBLE in
	zap_pid_ns_processes
Date: Fri, 12 May 2017 12:55:22 -0500
Message-ID: <87d1bex8mt.fsf_-_@xmission.com>
References: <20170511171108.GB15063@roeck-us.net>
	<87shkbfggm.fsf@xmission.com> <20170511202104.GA14720@roeck-us.net>
	<87y3u3axx8.fsf@xmission.com> <20170511224724.GB15676@roeck-us.net>
	<8760h79e22.fsf@xmission.com>
	<CAASEscF4eajN_-F-VMq_4C+Hf9j3eXj1V5iESvyjT0B+911Q9A@mail.gmail.com>
	<8760h66wak.fsf@xmission.com> <20170512165214.GA12960@roeck-us.net>
	<874lwqyo8i.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874lwqyo8i.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Fri, 12 May 2017 12:33:01 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Vovo Yang <vovoy-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Date: Thu, 11 May 2017 18:21:01 -0500

The code can potentially sleep for an indefinite amount of time in
zap_pid_ns_processes triggering the hung task timeout, and increasing
the system average.  This is undesirable.  Sleep with a task state of
TASK_INTERRUPTIBLE instead of TASK_UNINTERRUPTIBLE to remove these
undesirable side effects.

Apparently under heavy load this has been allowing Chrome to trigger
the hung time task timeout error and cause ChromeOS to reboot.

Reported-by: Vovo Yang <vovoy-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Reported-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Fixes: 6347e9009104 ("pidns: guarantee that the pidns init will be the last pidns process reaped")
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---

This is what I have queued up posting so it is public knowledge and so
that if anyone can see a flaw it can get fixed.

 kernel/pid_namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index de461aa0bf9a..6e51b8820495 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -277,7 +277,7 @@ void zap_pid_ns_processes(struct pid_namespace *pid_ns)
 	 * if reparented.
 	 */
 	for (;;) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
+		set_current_state(TASK_INTERRUPTIBLE);
 		if (pid_ns->nr_hashed == init_pids)
 			break;
 		schedule();
-- 
2.10.1
