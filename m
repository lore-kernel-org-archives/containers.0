From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH 4/8] user namespace: enforce CAP_NS_OVERRIDE for
	cross-namespace kill
Date: Wed, 12 Dec 2007 13:22:49 -0600
Message-ID: <20071212192249.GA24363@sergelap.austin.ibm.com>
References: <20071207191259.GA10293@sergelap.austin.ibm.com>
	<20071207191426.GD10432@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071207191426.GD10432-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> >From 62e6efe435a24f430e28f2398f374cef197b4964 Mon Sep 17 00:00:00 2001
> From: sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org <sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Date: Thu, 29 Nov 2007 08:18:16 -0800
> Subject: [RFC] [PATCH 4/8] user namespace: enforce CAP_NS_OVERRIDE for cross-namespace kill
> 
> Require CAP_NS_OVERRIDE to 'kill' across user namespaces.
> 
> Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/signal.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/signal.c b/kernel/signal.c
> index 787521e..a06dcc2 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -534,6 +534,11 @@ static int check_kill_permission(int sig, struct siginfo *info,
>  		error = audit_signal_info(sig, t); /* Let audit system see the signal */
>  		if (error)
>  			return error;
> +
> +		if (current->nsproxy->user_ns != t->nsproxy->user_ns
> +			&& !(capable(CAP_KILL) && capable(CAP_NS_OVERRIDE)))
> +			return -EPERM;
> +
>  		error = -EPERM;
>  		if (((sig != SIGCONT) ||
>  			(task_session_nr(current) != task_session_nr(t)))
> -- 
> 1.5.1

This patch has a sadly obvious, but (just as sadly) hard for me to
reproduce pair of bugs which Cedric found (thanks).

The following patch *should* be a correct fix, but as it's the fourth
version I'm going to keep testing for awhile.

In the meantime, the last three patches in this set are really
independent of the rest, so I plan to send them individually later today
with cc:s to the appropriate maintainers for their review.

thanks,
-serge

From 558e37c30d2047e040e4e2d40ed87c96cd78183f Mon Sep 17 00:00:00 2001
From: sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org <sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 29 Nov 2007 08:18:16 -0800
Subject: [PATCH 1/1] user namespace: enforce CAP_NS_OVERRIDE for cross-namespace kill (v4)

Require CAP_NS_OVERRIDE to 'kill' across user namespaces.

If the signaling task is exiting, then current->nsproxy is
NULL.  Since we are only notifying a parent of our death,
we permit the signal.

If the target task is exiting, our signal doesn't matter
anyway.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/signal.c                        |   23 +++++++++++++++++++++++

diff --git a/kernel/signal.c b/kernel/signal.c
index 06e663d..75c4d00 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -531,9 +531,32 @@ static int check_kill_permission(int sig, struct siginfo *info,
 		return error;
 
 	if (info == SEND_SIG_NOINFO || (!is_si_special(info) && SI_FROMUSER(info))) {
+		struct nsproxy *nsproxy;
+		struct user_namespace *my_user_ns = NULL, *t_user_ns = NULL;
+
 		error = audit_signal_info(sig, t); /* Let audit system see the signal */
 		if (error)
 			return error;
+
+		/*
+		 * if current->nsproxy is NULL, then we are exiting and
+		 * are just sending an exit signal to our parent.
+		 * Uid may be wrong under certain circumstances, but
+		 * global init shouldn't care, and a container creation
+		 * program should know what it is doing.
+		 * If target is exiting then it doesn't matter anyway.
+		 */
+		rcu_read_lock();
+		nsproxy = task_nsproxy(t);
+		if (nsproxy)
+			t_user_ns = nsproxy->user_ns;
+		rcu_read_unlock();
+		if (current->nsproxy)
+			my_user_ns = current->nsproxy->user_ns;
+		if (my_user_ns && t_user_ns && my_user_ns != t_user_ns
+			&& !(capable(CAP_KILL) && capable(CAP_NS_OVERRIDE)))
+			return -EPERM;
+
 		error = -EPERM;
 		if (((sig != SIGCONT) ||
 			(task_session_nr(current) != task_session_nr(t)))
-- 
1.5.1
