From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH pm-freezer 1/4] cgroup_freezer: fix freezer->state
	setting bug in freezer_change_state()
Date: Mon, 29 Aug 2011 18:00:31 +0200
Message-ID: <20110829160031.GB8392__25581.4935117543$1314634005$gmane$org@redhat.com>
References: <20110829140418.GB18871@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110829140418.GB18871-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/29, Tejun Heo wrote:
>
> --- work.orig/kernel/cgroup_freezer.c
> +++ work/kernel/cgroup_freezer.c
> @@ -311,14 +311,14 @@ static int freezer_change_state(struct c
>  	if (goal_state == freezer->state)
>  		goto out;
>  
> -	freezer->state = goal_state;
> -
>  	switch (goal_state) {
>  	case CGROUP_THAWED:
> +		freezer->state = CGROUP_THAWED;
>  		atomic_dec(&system_freezing_cnt);
>  		unfreeze_cgroup(cgroup, freezer);
>  		break;
>  	case CGROUP_FROZEN:
> +		freezer->state = CGROUP_FREEZING;

At first glance, this is correct. I'll try to recheck.

But,

>  		atomic_inc(&system_freezing_cnt);

iiuc this becomes wrong... Suppose a user writes "FROZEN" twice,
before freezer->state becomes CGROUP_FROZEN.

I think we should actually fix the "goal_state == freezer->state"
check above.

Oleg.
