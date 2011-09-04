From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/6] cgroup_freezer: fix freezer->state setting bug in
	freezer_change_state()
Date: Sun, 4 Sep 2011 20:02:06 +0200
Message-ID: <20110904180206.GA28520@redhat.com>
References: <1314988070-12244-1-git-send-email-tj@kernel.org>
	<1314988070-12244-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1314988070-12244-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

On 09/03, Tejun Heo wrote:
>
> @@ -308,24 +308,24 @@ static int freezer_change_state(struct cgroup *cgroup,
>  	spin_lock_irq(&freezer->lock);
>  
>  	update_if_frozen(cgroup, freezer);
> -	if (goal_state == freezer->state)
> -		goto out;
> -
> -	freezer->state = goal_state;
>  
>  	switch (goal_state) {
>  	case CGROUP_THAWED:
> -		atomic_dec(&system_freezing_cnt);
> +		if (freezer->state != CGROUP_THAWED)
> +			atomic_dec(&system_freezing_cnt);
> +		freezer->state = CGROUP_THAWED;
>  		unfreeze_cgroup(cgroup, freezer);
>  		break;
>  	case CGROUP_FROZEN:
> -		atomic_inc(&system_freezing_cnt);
> +		if (freezer->state == CGROUP_THAWED)
> +			atomic_inc(&system_freezing_cnt);
> +		freezer->state = CGROUP_FREEZING;
>  		retval = try_to_freeze_cgroup(cgroup, freezer);

Cough. Now it doesn't look right to me ;)

If the user write "FROZEN" into the control file, we should not
turn the CGROUP_FROZEN state into CGROUP_FREEZING. Probably this
is harmless, but this looks wrong and this doesn't match the
current behaviour, user-visible change.

Oleg.
