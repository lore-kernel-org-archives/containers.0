From: Takuya Yoshikawa <yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 6/7] bio-cgroup: Implement the bio-cgroup
Date: Fri, 08 Aug 2008 16:10:05 +0900
Message-ID: <489BF14D.6050009@oss.ntt.co.jp>
References: <20080804.175707.104036289.ryov@valinux.co.jp>	<20080804.175748.189722512.ryov@valinux.co.jp>	<20080804.175934.112619046.ryov@valinux.co.jp>
	<20080804.180022.183027902.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080804.180022.183027902.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

Ryo Tsuruta wrote:
> +static void bio_cgroup_move_task(struct cgroup_subsys *ss,
> +				struct cgroup *cont,
> +				struct cgroup *old_cont,
> +				struct task_struct *p)
> +{
> +	struct mm_struct *mm;
> +	struct bio_cgroup *biog, *old_biog;
> +
> +	if (bio_cgroup_disabled())
> +		return;
> +
> +	mm = get_task_mm(p);
> +	if (mm == NULL)
> +		return;
> +
> +	biog = cgroup_bio(cont);
> +	old_biog = cgroup_bio(old_cont);
> +
> +	mmput(mm);
> +	return;
> +}

Is this function fully implemented?
I tried to put a process into a group by writing to 
"/cgroup/bio/BGROUP/tasks" but failed.

I think this function is not enough to be used as "attach."

> +
> +
> +struct cgroup_subsys bio_cgroup_subsys = {
> +	.name           = "bio",
> +	.subsys_id      = bio_cgroup_subsys_id,
> +	.create         = bio_cgroup_create,
> +	.destroy        = bio_cgroup_destroy,
> +	.pre_destroy	= bio_cgroup_pre_destroy,
> +	.populate       = bio_cgroup_populate,
> +	.attach		= bio_cgroup_move_task,
> +	.early_init	= 0,
> +};

Without "attach" function, it is difficult to check
the effectiveness of block I/O tracking.

Thanks,
- Takuya Yoshikawa
