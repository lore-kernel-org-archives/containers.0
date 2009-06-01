From: Amerigo Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][v3][PATCH 4/7] Add target_pids parameter to alloc_pid()
Date: Mon, 1 Jun 2009 16:34:19 +0800
Message-ID: <20090601083419.GE4381@cr0.nay.redhat.com>
References: <20090530235714.GA4083@us.ibm.com>
	<20090531000220.GC4191@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090531000220.GC4191-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, May 30, 2009 at 05:02:20PM -0700, Sukadev Bhattiprolu wrote:
>
>From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>Date: Mon, 4 May 2009 01:17:42 -0700
>Subject: [RFC][v3][PATCH 4/7] Add target_pids parameter to alloc_pid()
>
>This parameter is currently NULL, but will be used in a follow-on patch.

<snip>

>diff --git a/kernel/pid.c b/kernel/pid.c
>index b44dd21..090b221 100644
>--- a/kernel/pid.c
>+++ b/kernel/pid.c
>@@ -280,13 +280,14 @@ void free_pid(struct pid *pid)
> 	call_rcu(&pid->rcu, delayed_put_pid);
> }
> 
>-struct pid *alloc_pid(struct pid_namespace *ns)
>+struct pid *alloc_pid(struct pid_namespace *ns, pid_t *target_pids)
> {
> 	struct pid *pid;
> 	enum pid_type type;
> 	int i, nr;
> 	struct pid_namespace *tmp;
> 	struct upid *upid;
>+	int tpid;
> 
> 	pid = kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL);
> 	if (!pid)
>@@ -294,7 +295,11 @@ struct pid *alloc_pid(struct pid_namespace *ns)
> 
> 	tmp = ns;
> 	for (i = ns->level; i >= 0; i--) {
>-		nr = alloc_pidmap(tmp, 0);
>+		tpid = 0;

How about initializing 'tpid' to 0 when define it?

Otherwise,

Reviewed-by: WANG Cong <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
