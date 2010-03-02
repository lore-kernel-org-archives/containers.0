From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Date: Tue, 2 Mar 2010 17:23:16 +0900
Message-ID: <20100302172316.b959b04c.kamezawa.hiroyu__31469.4684152075$1267518458$gmane$org@jp.fujitsu.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100302092309.bff454d7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302080056.GA1548@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100302080056.GA1548@linux>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2 Mar 2010 09:01:58 +0100
Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:

> On Tue, Mar 02, 2010 at 09:23:09AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon,  1 Mar 2010 22:23:40 +0100
> > Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> > 
> > > Apply the cgroup dirty pages accounting and limiting infrastructure to
> > > the opportune kernel functions.
> > > 
> > > Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
> > 
> > Seems nice.
> > 
> > Hmm. the last problem is moving account between memcg.
> > 
> > Right ?
> 
> Correct. This was actually the last item of the TODO list. Anyway, I'm
> still considering if it's correct to move dirty pages when a task is
> migrated from a cgroup to another. Currently, dirty pages just remain in
> the original cgroup and are flushed depending on the original cgroup
> settings. That is not totally wrong... at least moving the dirty pages
> between memcgs should be optional (move_charge_at_immigrate?).
> 

My concern is 
 - migration between memcg is already suppoted
    - at task move
    - at rmdir

Then, if you leave DIRTY_PAGE accounting to original cgroup,
the new cgroup (migration target)'s Dirty page accounting may
goes to be negative, or incorrect value. Please check FILE_MAPPED
implementation in __mem_cgroup_move_account()

As
       if (page_mapped(page) && !PageAnon(page)) {
                /* Update mapped_file data for mem_cgroup */
                preempt_disable();
                __this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
                __this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
                preempt_enable();
        }
then, FILE_MAPPED never goes negative.


Thanks,
-Kame

> Thanks for your ack and the detailed review!
> 
> -Andrea
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
> 
