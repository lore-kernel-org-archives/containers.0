From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Date: Thu, 4 Mar 2010 12:45:05 +0900
Message-ID: <20100304124505.394a058e.kamezawa.hiroyu__47152.3385997445$1267674569$gmane$org@jp.fujitsu.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100303111238.7133f8af.nishimura@mxp.nes.nec.co.jp>
	<20100303122906.9c613ab2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303150137.f56d7084.nishimura@mxp.nes.nec.co.jp>
	<20100303151549.5d3d686a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303172132.fc6d9387.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303220319.GA2706@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100303220319.GA2706@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: Balbir-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Greg-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 3 Mar 2010 23:03:19 +0100
Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:

> On Wed, Mar 03, 2010 at 05:21:32PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 3 Mar 2010 15:15:49 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
 
> > +	preempt_disable();
> > +	lock_page_cgroup_migrate(pc);
> >  	page = pc->page;
> >  	if (page_mapped(page) && !PageAnon(page)) {
> >  		/* Update mapped_file data for mem_cgroup */
> > -		preempt_disable();
> >  		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> >  		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > -		preempt_enable();
> >  	}
> >  	mem_cgroup_charge_statistics(from, pc, false);
> > +	move_acct_information(from, to, pc);
> 
> Kame-san, a question. According to is_target_pte_for_mc() it seems we
> don't move file pages across cgroups for now. 

yes. It's just in plan.

> If !PageAnon(page) we just return 0 and the page won't be selected for migration in
> mem_cgroup_move_charge_pte_range().
> 
> So, if I've understood well the code is correct in perspective, but
> right now it's unnecessary. File pages are not moved on task migration
> across cgroups and, at the moment, there's no way for file page
> accounted statistics to go negative.
> 
> Or am I missing something?
> 

At rmdir(), remainging file caches in a cgroup is moved to
its parent. Then, all file caches are moved to its parent at rmdir().

This behavior is for avoiding to lose too much file caches at removing cgroup.

Thanks,
-Kame
