From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Date: Thu, 18 Mar 2010 10:42:32 +0530
Message-ID: <20100318051232.GB18054__25332.4107885875$1268889301$gmane$org@balbir.in.ibm.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100317115855.GS18054@balbir.in.ibm.com>
	<20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318094519.cd1eed72.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318111653.92f899e6.nishimura@mxp.nes.nec.co.jp>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100318111653.92f899e6.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
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
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

* nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> [2010-03-18 11:16:53]:

> On Thu, 18 Mar 2010 09:45:19 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > On Thu, 18 Mar 2010 08:54:11 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > 
> > > On Wed, 17 Mar 2010 17:28:55 +0530
> > > Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > > 
> > > > * Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> [2010-03-15 00:26:38]:
> > > > 
> > > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> > > > > 
> > > > > Now, file-mapped is maintaiend. But more generic update function
> > > > > will be needed for dirty page accounting.
> > > > > 
> > > > > For accountig page status, we have to guarantee lock_page_cgroup()
> > > > > will be never called under tree_lock held.
> > > > > To guarantee that, we use trylock at updating status.
> > > > > By this, we do fuzzy accounting, but in almost all case, it's correct.
> > > > >
> > > > 
> > > > I don't like this at all, but in almost all cases is not acceptable
> > > > for statistics, since decisions will be made on them and having them
> > > > incorrect is really bad. Could we do a form of deferred statistics and
> > > > fix this.
> > > > 
> > > 
> > > plz show your implementation which has no performance regresssion.
> > > For me, I don't neee file_mapped accounting, at all. If we can remove that,
> > > we can add simple migration lock.
> > > file_mapped is a feattue you added. please improve it.
> > > 
> > 
> > BTW, I should explain how acculate this accounting is in this patch itself.
> > 
> > Now, lock_page_cgroup/unlock_page_cgroup happens when
> > 	- charge/uncharge/migrate/move accounting
> > 
> > Then, the lock contention (trylock failure) seems to occur in conflict
> > with
> > 	- charge, uncharge, migarate. move accounting
> > 
> > About dirty accounting, charge/uncharge/migarate are operation in synchronous
> > manner with radix-tree (holding treelock etc). Then no account leak.
> > move accounting is only source for inacculacy...but I don't think this move-task
> > is ciritial....moreover, we don't move any file pages at task-move, now.
> > (But Nishimura-san has a plan to do so.)
> > So, contention will happen only at confliction with force_empty.
> > 
> > About FILE_MAPPED accounting, it's not synchronous with radix-tree operaton.
> > Then, accounting-miss seems to happen when charge/uncharge/migrate/account move.
> > But
> > 	charge .... we don't account a page as FILE_MAPPED before it's charged.
> > 	uncharge .. usual operation in turncation is unmap->remove-from-radix-tree.
> > 		    Then, it's sequential in almost all case. The race exists when...
> > 		    Assume there are 2 threads A and B. A truncate a file, B map/unmap that.
> > 		    This is very unusal confliction.
> > 	migrate.... we do try_to_unmap before migrating pages. Then, FILE_MAPPED
> > 		    is properly handled.
> > 	move account .... we don't have move-account-mapped-file, yet.
> > 
> FILE_MAPPED is updated under pte lock. OTOH, move account is also done under
> pte lock. page cgroup lock is held under pte lock in both cases, so move account
> is not so problem as for FILE_MAPPED.
>
True
 
> 
> > Then, this trylock contention happens at contention with force_empty and truncate.
> > 
> > 
> > Then, main issue for contention is force_empty. But it's called for removing memcg,
> > accounting for such memcg is not important.
> > Then, I say "this accounting is Okay."
> > 
> > To do more accurate, we may need another "migration lock". But to get better
> > performance for root cgroup, we have to call mem_cgroup_is_root() before
> > taking lock and there will be another complicated race.

Agreed, we need to find a simpler way of doing this without affecting
the accuracy of accounting - may be two accounting routines for two
code paths. I have not thought through this yet.

-- 
	Three Cheers,
	Balbir
