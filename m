From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 1/2] memcg: dirty pages accounting and limiting
	infrastructure
Date: Mon, 1 Mar 2010 11:30:01 +0100
Message-ID: <20100301103001.GB2087__13723.1920300566$1267439522$gmane$org@linux>
References: <1267224751-6382-1-git-send-email-arighi@develer.com>
	<1267224751-6382-2-git-send-email-arighi@develer.com>
	<20100301170535.2f1db0ed.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100301170535.2f1db0ed.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 01, 2010 at 05:05:35PM +0900, Daisuke Nishimura wrote:
> On Fri, 26 Feb 2010 23:52:30 +0100, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> > Infrastructure to account dirty pages per cgroup and add dirty limit
> > interfaces in the cgroupfs:
> > 
> >  - Active write-out: memory.dirty_ratio, memory.dirty_bytes
> >  - Background write-out: memory.dirty_background_ratio, memory.dirty_background_bytes
> > 
> It looks good for me in general.
> 
> > Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
> > ---
> >  include/linux/memcontrol.h |   74 +++++++++-
> >  mm/memcontrol.c            |  354 ++++++++++++++++++++++++++++++++++++++++----
> >  2 files changed, 399 insertions(+), 29 deletions(-)
> > 
> 
> (snip)
> 
> > +s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> > +{
> > +	struct mem_cgroup_page_stat stat = {};
> > +	struct mem_cgroup *memcg;
> > +
> I think it would be better to add "if (mem_cgroup_disabled())".

Agreed.

> 
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> > +	if (memcg) {
> > +		/*
> > +		 * Recursively evaulate page statistics against all cgroup
> > +		 * under hierarchy tree
> > +		 */
> > +		stat.item = item;
> > +		mem_cgroup_walk_tree(memcg, &stat, mem_cgroup_page_stat_cb);
> > +	} else
> > +		stat.value = -ENOMEM;
> > +	rcu_read_unlock();
> > +
> > +	return stat.value;
> > +}
> > +
> >  static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
> >  {
> >  	int *val = data;
> > @@ -1263,10 +1419,10 @@ static void record_last_oom(struct mem_cgroup *mem)
> >  }
> >  
> >  /*
> > - * Currently used to update mapped file statistics, but the routine can be
> > - * generalized to update other statistics as well.
> > + * Generalized routine to update memory cgroup statistics.
> >   */
> > -void mem_cgroup_update_file_mapped(struct page *page, int val)
> > +void mem_cgroup_update_stat(struct page *page,
> > +			enum mem_cgroup_stat_index idx, int val)
> >  {
> >  	struct mem_cgroup *mem;
> >  	struct page_cgroup *pc;
> ditto.

Agreed.

Thanks,
-Andrea
