From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Thu, 19 Mar 2009 18:26:14 -0400
Message-ID: <49C2C686.2060806@cs.columbia.edu>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237402291-28812-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org


So what happens in the following scenario:

* task A is the container init(1)
* A calls fork() to create task B
* B calls unshare(CLONE_NEWUTS)
* B calls clone(CLONE_PARENT) to create task C

Now C and B have the same UTS namespace, which differs from A's, but
they will each have a different UTS namespace when restarted with this
patch.

This is part of a larger complexity related to how CLONE_PARENT works.
Also related to how session IDs are inherited.

Two approaches to solve this are:

a) Identify, in mktree, that this was the case, and impose an order on
the forks/clones to recreate the same dependency (an algorithm for this
is described in [1])

b) Do it in the kernel: for each nsproxy (identified by an objref) the
first task that has it will create it during restart, in or out of the
kernel, and the next task will simply attach to the existing one that
will be deposited in the objhash.

Oren.

[1] "Transparent Checkpoint/Restart of Multiple Processes on Commodity
Operating Systems",
http://www1.cs.columbia.edu/~orenl/papers/usenix07-checkpoint.pdf

Dan Smith wrote:
> This patch adds a "phase" of checkpoint that saves out information about any
> namespaces the task(s) may have.  Do this by tracking the namespace objects
> of the tasks and making sure that tasks with the same namespace that follow
> get properly referenced in the checkpoint stream.  Note that for now, we
> refuse to checkpoint if all tasks in the set don't share the same set of
> *all* namespaces.
> 
> Restart is handled in userspace by reading the UTS record(s), calling
> unshare() and setting the hostname accordingly.  See my changes to
> mktree.c for details.
> 
> I tested this with single and multiple task restore, on top of Oren's
> v13 tree.

[...]
