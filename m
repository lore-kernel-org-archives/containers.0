From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: Question : memrlimit cgroup's task_move (2.6.26-rc5-mm3)
Date: Fri, 20 Jun 2008 09:13:16 +0900
Message-ID: <20080620091316.80771d14.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080619121435.f868c110.kamezawa.hiroyu@jp.fujitsu.com>
	<20080619182556.GA10461@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080619182556.GA10461-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 19 Jun 2008 23:55:56 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2008-06-19 12:14:35]:
> 
> > I used memrlimit cgroup at the first time.
> > 
> > May I ask a question about memrlimit cgroup ?
> >
> 
> Hi, Kamezawa-San,
> 
> Could you please review/test the patch below to see if it solves your
> problem? If it does, I'll push it up to Andrew
> 

At quick glance,
> +	/*
> +	 * NOTE: Even though we do the necessary checks in can_attach(),
> +	 * by the time we come here, there is a chance that we still
> +	 * fail (the memrlimit cgroup has grown its usage, and the
> +	 * addition of total_vm will no longer fit into its limit)
> +	 */
I don't like this kind of holes. Considering tests which are usually done
by developpers, the problem seems not to be mentioned as "rare"..
It seems we can easily cause Warning. right ?

Even if you don't want to handle this case now, please mention as "TBD" 
rather than as "NOTE".


> +
> +/*
> + * Add the value val to the resource counter and check if we are
> + * still under the limit.
> + */
> +static inline bool res_counter_add_check(struct res_counter *cnt,
> +						unsigned long val)
> +{
> +	bool ret = false;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	if (cnt->usage + val < cnt->limit)
> +		ret = true;
cnt->usage + val <= cnt->limit.

Thanks,
-Kame
