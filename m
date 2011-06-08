From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node
	to world
Date: Thu, 9 Jun 2011 08:44:22 +0900
Message-ID: <20110609084422.1b285cf3.kamezawa.hiroyu__390.842583920126$1307577148$gmane$org@jp.fujitsu.com>
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com>
	<20110601123913.GC4266@tiehlicka.suse.cz>
	<4DE6399C.8070802@redhat.com>
	<20110601134149.GD4266@tiehlicka.suse.cz>
	<4DE64F0C.3050203@redhat.com>
	<20110601152039.GG4266@tiehlicka.suse.cz>
	<4DE66BEB.7040502@redhat.com>
	<BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
	<4DE8D50F.1090406@redhat.com>
	<BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com>
	<4DEE26E7.2060201@redhat.com>
	<20110608123527.479e6991.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608140951.115ab1dd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110608140951.115ab1dd.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Igor Mammedov <imammedo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 8 Jun 2011 14:09:51 -0700
Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> 
> The original patch:
> 
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4707,7 +4707,6 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>  	if (!pn)
>  		return 1;
>  
> -	mem->info.nodeinfo[node] = pn;
>  	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
>  		mz = &pn->zoneinfo[zone];
>  		for_each_lru(l)
> @@ -4716,6 +4715,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>  		mz->on_tree = false;
>  		mz->mem = mem;
>  	}
> +	mem->info.nodeinfo[node] = pn;
>  	return 0;
>  }
> 
> looks like a really good idea.  But it needs a new changelog and I'd be
> a bit reluctant to merge it as it appears that the aptch removes our
> only known way of reproducing a bug.
> 
> So for now I think I'll queue the patch up unchangelogged so the issue
> doesn't get forgotten about.
> 

Hmm, queued as clean up ? If so, I'll Ack.

Thanks,
-Kame
