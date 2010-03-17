From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 4/5] memcg: dirty pages accounting and limiting
	infrastructure
Date: Wed, 17 Mar 2010 23:52:03 +0100
Message-ID: <20100317225203.GD8467__31006.2008248226$1268866446$gmane$org@linux.develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-5-git-send-email-arighi@develer.com>
	<20100316113238.f7d74848.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100316113238.f7d74848.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 16, 2010 at 11:32:38AM +0900, Daisuke Nishimura wrote:
[snip]
> > @@ -3190,10 +3512,14 @@ struct {
> >  } memcg_stat_strings[NR_MCS_STAT] = {
> >  	{"cache", "total_cache"},
> >  	{"rss", "total_rss"},
> > -	{"mapped_file", "total_mapped_file"},
> >  	{"pgpgin", "total_pgpgin"},
> >  	{"pgpgout", "total_pgpgout"},
> >  	{"swap", "total_swap"},
> > +	{"mapped_file", "total_mapped_file"},
> > +	{"filedirty", "dirty_pages"},
> > +	{"writeback", "writeback_pages"},
> > +	{"writeback_tmp", "writeback_temp_pages"},
> > +	{"nfs", "nfs_unstable"},
> >  	{"inactive_anon", "total_inactive_anon"},
> >  	{"active_anon", "total_active_anon"},
> >  	{"inactive_file", "total_inactive_file"},
> Why not using "total_xxx" for total_name ?

Agreed. I would be definitely more clear. Balbir, KAME-san, what do you
think?

> 
> > @@ -3212,8 +3538,6 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
> >  	s->stat[MCS_CACHE] += val * PAGE_SIZE;
> >  	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
> >  	s->stat[MCS_RSS] += val * PAGE_SIZE;
> > -	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_MAPPED);
> > -	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
> >  	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGPGIN_COUNT);
> >  	s->stat[MCS_PGPGIN] += val;
> >  	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGPGOUT_COUNT);
> > @@ -3222,6 +3546,16 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
> >  		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
> >  		s->stat[MCS_SWAP] += val * PAGE_SIZE;
> >  	}
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_MAPPED);
> > +	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_DIRTY);
> > +	s->stat[MCS_FILE_DIRTY] += val;
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WRITEBACK);
> > +	s->stat[MCS_WRITEBACK] += val;
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WRITEBACK_TEMP);
> > +	s->stat[MCS_WRITEBACK_TEMP] += val;
> > +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_UNSTABLE_NFS);
> > +	s->stat[MCS_UNSTABLE_NFS] += val;
> >  
> I don't have a strong objection, but I prefer showing them in bytes.
> And can you add to mem_cgroup_stat_show() something like:
> 
> 	for (i = 0; i < NR_MCS_STAT; i++) {
> 		if (i == MCS_SWAP && !do_swap_account)
> 			continue;
> +		if (i >= MCS_FILE_STAT_STAR && i <= MCS_FILE_STAT_END &&
> +		   mem_cgroup_is_root(mem_cont))
> +			continue;
> 		cb->fill(cb, memcg_stat_strings[i].local_name, mystat.stat[i]);
> 	}

I like this. And I also prefer to show these values in bytes.

> 
> not to show file stat in root cgroup ? It's meaningless value anyway.
> Of course, you'd better mention it in [2/5] too.

OK.

Thanks,
-Andrea
