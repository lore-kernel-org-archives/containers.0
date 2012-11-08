From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 6/9] cgroup_freezer: make freezer->state mask of flags
Date: Thu, 08 Nov 2012 13:37:50 +0900
Message-ID: <509B371E.9050005__40655.8674447753$1352349512$gmane$org@jp.fujitsu.com>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351931915-1701-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/11/03 17:38), Tejun Heo wrote:
> freezer->state was an enum value - one of THAWED, FREEZING and FROZEN.
> As the scheduled full hierarchy support requires more than one
> freezing condition, switch it to mask of flags.  If FREEZING is not
> set, it's thawed.  FREEZING is set if freezing or frozen.  If frozen,
> both FREEZING and FROZEN are set.  Now that tasks can be attached to
> an already frozen cgroup, this also makes freezing condition checks
> more natural.
>
> This patch doesn't introduce any behavior change.
>
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>   kernel/cgroup_freezer.c | 60 ++++++++++++++++++++++---------------------------
>   1 file changed, 27 insertions(+), 33 deletions(-)
>
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index 2690830..e76aa9f 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -22,15 +22,14 @@
>   #include <linux/freezer.h>
>   #include <linux/seq_file.h>
>
> -enum freezer_state {
> -	CGROUP_THAWED = 0,
> -	CGROUP_FREEZING,
> -	CGROUP_FROZEN,
> +enum freezer_state_flags {
> +	CGROUP_FREEZING		= (1 << 1), /* this freezer is freezing */
> +	CGROUP_FROZEN		= (1 << 3), /* this and its descendants frozen */
>   };
>
>   struct freezer {
>   	struct cgroup_subsys_state	css;
> -	enum freezer_state		state;
> +	unsigned int			state;
>   	spinlock_t			lock;
>   };
>
> @@ -48,12 +47,10 @@ static inline struct freezer *task_freezer(struct task_struct *task)
>
>   bool cgroup_freezing(struct task_struct *task)
>   {
> -	enum freezer_state state;
>   	bool ret;
>
>   	rcu_read_lock();
> -	state = task_freezer(task)->state;
> -	ret = state == CGROUP_FREEZING || state == CGROUP_FROZEN;
> +	ret = task_freezer(task)->state & CGROUP_FREEZING;
>   	rcu_read_unlock();
>
>   	return ret;
> @@ -63,10 +60,13 @@ bool cgroup_freezing(struct task_struct *task)
>    * cgroups_write_string() limits the size of freezer state strings to
>    * CGROUP_LOCAL_BUFFER_SIZE
>    */
> -static const char *freezer_state_strs[] = {
> -	"THAWED",
> -	"FREEZING",
> -	"FROZEN",
> +static const char *freezer_state_strs(unsigned int state)
> +{
> +	if (state & CGROUP_FROZEN)
> +		return "FROZEN";
> +	if (state & CGROUP_FREEZING)
> +		return "FREEZING";
> +	return "THAWED";
>   };
>
>   /*
> @@ -91,7 +91,6 @@ static struct cgroup_subsys_state *freezer_create(struct cgroup *cgroup)
>   		return ERR_PTR(-ENOMEM);
>
>   	spin_lock_init(&freezer->lock);
> -	freezer->state = CGROUP_THAWED;
>   	return &freezer->css;
>   }
>
> @@ -99,7 +98,7 @@ static void freezer_destroy(struct cgroup *cgroup)
>   {
>   	struct freezer *freezer = cgroup_freezer(cgroup);
>
> -	if (freezer->state != CGROUP_THAWED)
> +	if (freezer->state & CGROUP_FREEZING)
>   		atomic_dec(&system_freezing_cnt);
>   	kfree(freezer);
>   }
> @@ -129,15 +128,13 @@ static void freezer_attach(struct cgroup *new_cgrp, struct cgroup_taskset *tset)
>   	 * Tasks in @tset are on @new_cgrp but may not conform to its
>   	 * current state before executing the following - !frozen tasks may
>   	 * be visible in a FROZEN cgroup and frozen tasks in a THAWED one.
> -	 * This means that, to determine whether to freeze, one should test
> -	 * whether the state equals THAWED.
>   	 */
>   	cgroup_taskset_for_each(task, new_cgrp, tset) {
> -		if (freezer->state == CGROUP_THAWED) {
> +		if (!(freezer->state & CGROUP_FREEZING)) {
>   			__thaw_task(task);
>   		} else {
>   			freeze_task(task);
> -			freezer->state = CGROUP_FREEZING;
> +			freezer->state &= ~CGROUP_FROZEN;
>   		}
>   	}
>
> @@ -159,11 +156,7 @@ static void freezer_fork(struct task_struct *task)
>   		goto out;
>
>   	spin_lock_irq(&freezer->lock);
> -	/*
> -	 * @task might have been just migrated into a FROZEN cgroup.  Test
> -	 * equality with THAWED.  Read the comment in freezer_attach().
> -	 */
> -	if (freezer->state != CGROUP_THAWED)
> +	if (freezer->state & CGROUP_FREEZING)
>   		freeze_task(task);
>   	spin_unlock_irq(&freezer->lock);
>   out:
> @@ -184,7 +177,8 @@ static void update_if_frozen(struct freezer *freezer)
>   	struct cgroup_iter it;
>   	struct task_struct *task;
>
> -	if (freezer->state != CGROUP_FREEZING)
> +	if (!(freezer->state & CGROUP_FREEZING) ||
> +	    (freezer->state & CGROUP_FROZEN))
>   		return;

Hmm....

How about
enum {
    __CGROUP_FREEZING,
    __CGROUP_FROZEN,
};

#define CGROUP_FREEZER_STATE_MASK  0x3
#define CGROUP_FREEZER_STATE(state)	((state) & CGROUP_FREEZER_STATE_MASK)
#define CGROUP_THAW(state)	(CGROUP_FREEZER_STATE(state) == 0)
#define CGROUP_FREEZING(state)	(CGROUP_FREEZER_STATE(state) == __CGROUP_FREEZING)
#define CGROUP_FROZEN(state)\
	(CGROUP_FREEZER_STATE(state) == (__CGROUP_FREEZING | __CGROUP_FROZEN))
>
>   	cgroup_iter_start(cgroup, &it);
> @@ -202,7 +196,7 @@ static void update_if_frozen(struct freezer *freezer)
>   		}
>   	}
>
> -	freezer->state = CGROUP_FROZEN;
> +	freezer->state |= CGROUP_FROZEN;
>   notyet:
>   	cgroup_iter_end(cgroup, &it);
>   }
> @@ -211,14 +205,14 @@ static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
>   			struct seq_file *m)
>   {
>   	struct freezer *freezer = cgroup_freezer(cgroup);
> -	enum freezer_state state;
> +	unsigned int state;
>
>   	spin_lock_irq(&freezer->lock);
>   	update_if_frozen(freezer);
>   	state = freezer->state;
>   	spin_unlock_irq(&freezer->lock);
>
> -	seq_puts(m, freezer_state_strs[state]);
> +	seq_puts(m, freezer_state_strs(state));
>   	seq_putc(m, '\n');
>   	return 0;
>   }
> @@ -258,14 +252,14 @@ static void freezer_apply_state(struct freezer *freezer, bool freeze)
>   	lockdep_assert_held(&freezer->lock);
>
>   	if (freeze) {
> -		if (freezer->state == CGROUP_THAWED)
> +		if (!(freezer->state & CGROUP_FREEZING))
>   			atomic_inc(&system_freezing_cnt);
> -		freezer->state = CGROUP_FREEZING;
> +		freezer->state |= CGROUP_FREEZING;
>   		freeze_cgroup(freezer);
>   	} else {
> -		if (freezer->state != CGROUP_THAWED)
> +		if (freezer->state & CGROUP_FREEZING)
>   			atomic_dec(&system_freezing_cnt);
> -		freezer->state = CGROUP_THAWED;
> +		freezer->state &= ~(CGROUP_FREEZING | CGROUP_FROZEN);
>   		unfreeze_cgroup(freezer);
>   	}
>   }
> @@ -290,9 +284,9 @@ static int freezer_write(struct cgroup *cgroup, struct cftype *cft,
>   {
>   	bool freeze;
>
> -	if (strcmp(buffer, freezer_state_strs[CGROUP_THAWED]) == 0)
> +	if (strcmp(buffer, freezer_state_strs(0)) == 0)

Can't we have a name for "0" ?

>   		freeze = false;
> -	else if (strcmp(buffer, freezer_state_strs[CGROUP_FROZEN]) == 0)
> +	else if (strcmp(buffer, freezer_state_strs(CGROUP_FROZEN)) == 0)
>   		freeze = true;
>   	else
>   		return -EINVAL;
>


Thanks,
-Kame
