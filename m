From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Date: Tue, 2 Mar 2010 23:18:23 +0100
Message-ID: <20100302221823.GC2369__49246.7176322409$1267568774$gmane$org@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100302092309.bff454d7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302080056.GA1548@linux>
	<20100302172316.b959b04c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302135026.GH3212@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100302135026.GH3212-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 02, 2010 at 07:20:26PM +0530, Balbir Singh wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2010-03-02 17:23:16]:
> 
> > On Tue, 2 Mar 2010 09:01:58 +0100
> > Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> > 
> > > On Tue, Mar 02, 2010 at 09:23:09AM +0900, KAMEZAWA Hiroyuki wrote:
> > > > On Mon,  1 Mar 2010 22:23:40 +0100
> > > > Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> > > > 
> > > > > Apply the cgroup dirty pages accounting and limiting infrastructure to
> > > > > the opportune kernel functions.
> > > > > 
> > > > > Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
> > > > 
> > > > Seems nice.
> > > > 
> > > > Hmm. the last problem is moving account between memcg.
> > > > 
> > > > Right ?
> > > 
> > > Correct. This was actually the last item of the TODO list. Anyway, I'm
> > > still considering if it's correct to move dirty pages when a task is
> > > migrated from a cgroup to another. Currently, dirty pages just remain in
> > > the original cgroup and are flushed depending on the original cgroup
> > > settings. That is not totally wrong... at least moving the dirty pages
> > > between memcgs should be optional (move_charge_at_immigrate?).
> > > 
> > 
> > My concern is 
> >  - migration between memcg is already suppoted
> >     - at task move
> >     - at rmdir
> > 
> > Then, if you leave DIRTY_PAGE accounting to original cgroup,
> > the new cgroup (migration target)'s Dirty page accounting may
> > goes to be negative, or incorrect value. Please check FILE_MAPPED
> > implementation in __mem_cgroup_move_account()
> > 
> > As
> >        if (page_mapped(page) && !PageAnon(page)) {
> >                 /* Update mapped_file data for mem_cgroup */
> >                 preempt_disable();
> >                 __this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> >                 __this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> >                 preempt_enable();
> >         }
> > then, FILE_MAPPED never goes negative.
> >
> 
> Absolutely! I am not sure how complex dirty memory migration will be,
> but one way of working around it would be to disable migration of
> charges when the feature is enabled (dirty* is set in the memory
> cgroup). We might need additional logic to allow that to happen. 

I've started to look at dirty memory migration. First attempt is to add
DIRTY, WRITEBACK, etc. to page_cgroup flags and handle them in
__mem_cgroup_move_account(). Probably I'll have something ready for the
next version of the patch. I still need to figure if this can work as
expected...

-Andrea
