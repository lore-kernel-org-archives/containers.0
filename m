From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [RFC/PATCH] cgroup swap subsystem
Date: Thu, 06 Mar 2008 21:20:58 +0900
Message-ID: <47CFE1AA.6040002@mxp.nes.nec.co.jp>
References: <47CE36A9.3060204@mxp.nes.nec.co.jp>
	<6599ad830803042236x3e5fdf0dmaf4119997025ba40@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830803042236x3e5fdf0dmaf4119997025ba40-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Hi.

Paul Menage wrote:
>>  +       pc = page_get_page_cgroup(page);
>>  +       if (WARN_ON(!pc))
>>  +               mm = &init_mm;
>>  +       else
>>  +               mm = pc->pc_mm;
>>  +       BUG_ON(!mm);
> 
> Is this safe against races with the mem.force_empty operation?
> 
I've not considered yet about force_empty operation
of memory subsystem.
Thank you for pointing it out.

>>  +
>>  +       rcu_read_lock();
>>  +       swap = rcu_dereference(mm->swap_cgroup);
>>  +       rcu_read_unlock();
>>  +       BUG_ON(!swap);
> 
> Is it safe to do rcu_read_unlock() while you are still planning to
> operate on the value of "swap"?
> 
You are right.
I think I should css_get() before rcu_read_unlock() as
memory subsystem does.

>>  +
>>  +#ifdef CONFIG_CGROUP_SWAP_LIMIT
>>  +               p->swap_cgroup = vmalloc(maxpages * sizeof(*swap_cgroup));
>>  +               if (!(p->swap_cgroup)) {
>>  +                       error = -ENOMEM;
>>  +                       goto bad_swap;
>>  +               }
>>  +               memset(p->swap_cgroup, 0, maxpages * sizeof(*swap_cgroup));
>>  +#endif
> 
> It would be nice to only allocate these the first time the swap cgroup
> subsystem becomes active, to avoid the overhead for people not using
> it; even better if you can free it again if the swap subsystem becomes
> inactive again.
> 
Hmm.. good idea.
I think this is possible by adding a flag file, like "swap.enable_limit",
to the top of cgroup directory, and charging all the swap entries
which are used when the flag is enabled to the top cgroup.



Thanks,
Daisuke Nishimura.
