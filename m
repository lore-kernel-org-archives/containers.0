From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 2/3] fork: Allow CLONE_PARENT after setns(CLONE_NEWPID)
Date: Tue, 26 Nov 2013 16:16:57 -0800
Message-ID: <87vbzezojq.fsf_-_@xmission.com>
References: <20131115164123.GN28794@redhat.com>
	<20131116164840.GA4441@mail.hallyn.com>
	<20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com> <87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87siui1z1g.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Tue, 26 Nov 2013 16:14:19 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
> Hi Oleg,
>
> commit 40a0d32d1eaffe6aac7324ca92604b6b3977eb0e :
> "fork: unify and tighten up CLONE_NEWUSER/CLONE_NEWPID checks"
> breaks lxc-attach in 3.12.  That code forks a child which does
> setns() and then does a clone(CLONE_PARENT).  That way the
> grandchild can be in the right namespaces (which the child was
> not) and be a child of the original task, which is the monitor.
>
> lxc-attach in 3.11 was working fine with no side effects that I
> could see.  Is there a real danger in allowing CLONE_PARENT
> when current->nsproxy->pidns_for_children is not our pidns,
> or was this done out of an "over-abundance of caution"?  Can we
> safely revert that new extra check?

The two fundamental things I know we can not allow are:
- A shared signal queue aka CLONE_THREAD.  Because we compute the pid
  and uid of the signal when we place it in the queue.

- Changing the pid and by extention pid_namespace of an existing
  process.

From a parents perspective there is nothing special about the pid
namespace, to deny CLONE_PARENT, because the parent simply won't know or
care.

From the childs perspective all that is special really are shared signal
queues.

User mode threading with CLONE_PARENT|CLONE_VM|CLONE_SIGHAND and tasks
in different pid namespaces is almost certainly going to break because
it is complicated.  But shared signal handlers can look at per thread
information to know which pid namespace a process is in, so I don't know
of any reason not to support CLONE_PARENT|CLONE_VM|CLONE_SIGHAND threads
at the kernel level.  It would be absolutely stupid to implement but
that is a different thing.

So hmm.

Because it can do no harm, and because it is a regression let's remove
the CLONE_PARENT check and send it stable.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Acked-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/fork.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 728d5be9548c..f82fa2ee7581 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1171,7 +1171,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	 * do not allow it to share a thread group or signal handlers or
 	 * parent with the forking task.
 	 */
-	if (clone_flags & (CLONE_SIGHAND | CLONE_PARENT)) {
+	if (clone_flags & CLONE_SIGHAND) {
 		if ((clone_flags & (CLONE_NEWUSER | CLONE_NEWPID)) ||
 		    (task_active_pid_ns(current) !=
 				current->nsproxy->pid_ns_for_children))
-- 
1.7.5.4
