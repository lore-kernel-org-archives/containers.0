From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH mmotm 2.5/4] memcg: disable irq at page cgroup lock (Re:
	[PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
	infrastructure)
Date: Tue, 9 Mar 2010 10:20:58 +0530
Message-ID: <20100309045058.GX3073__395.106155383651$1268139204$gmane$org@balbir.in.ibm.com>
References: <1267995474-9117-4-git-send-email-arighi@develer.com>
	<20100308104447.c124c1ff.nishimura@mxp.nes.nec.co.jp>
	<20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
	<20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
	<20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309001252.GB13490@linux>
	<20100309091914.4b5f6661.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100309102928.9f36d2bb.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
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

* nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> [2010-03-09 10:29:28]:

> On Tue, 9 Mar 2010 09:19:14 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > On Tue, 9 Mar 2010 01:12:52 +0100
> > Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> > 
> > > On Mon, Mar 08, 2010 at 05:31:00PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > On Mon, 8 Mar 2010 17:07:11 +0900
> > > > Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> > > > 
> > > > > On Mon, 8 Mar 2010 11:37:11 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > > > > > On Mon, 8 Mar 2010 11:17:24 +0900
> > > > > > Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> > > > > > 
> > > > > > > > But IIRC, clear_writeback is done under treelock.... No ?
> > > > > > > > 
> > > > > > > The place where NR_WRITEBACK is updated is out of tree_lock.
> > > > > > > 
> > > > > > >    1311 int test_clear_page_writeback(struct page *page)
> > > > > > >    1312 {
> > > > > > >    1313         struct address_space *mapping = page_mapping(page);
> > > > > > >    1314         int ret;
> > > > > > >    1315
> > > > > > >    1316         if (mapping) {
> > > > > > >    1317                 struct backing_dev_info *bdi = mapping->backing_dev_info;
> > > > > > >    1318                 unsigned long flags;
> > > > > > >    1319
> > > > > > >    1320                 spin_lock_irqsave(&mapping->tree_lock, flags);
> > > > > > >    1321                 ret = TestClearPageWriteback(page);
> > > > > > >    1322                 if (ret) {
> > > > > > >    1323                         radix_tree_tag_clear(&mapping->page_tree,
> > > > > > >    1324                                                 page_index(page),
> > > > > > >    1325                                                 PAGECACHE_TAG_WRITEBACK);
> > > > > > >    1326                         if (bdi_cap_account_writeback(bdi)) {
> > > > > > >    1327                                 __dec_bdi_stat(bdi, BDI_WRITEBACK);
> > > > > > >    1328                                 __bdi_writeout_inc(bdi);
> > > > > > >    1329                         }
> > > > > > >    1330                 }
> > > > > > >    1331                 spin_unlock_irqrestore(&mapping->tree_lock, flags);
> > > > > > >    1332         } else {
> > > > > > >    1333                 ret = TestClearPageWriteback(page);
> > > > > > >    1334         }
> > > > > > >    1335         if (ret)
> > > > > > >    1336                 dec_zone_page_state(page, NR_WRITEBACK);
> > > > > > >    1337         return ret;
> > > > > > >    1338 }
> > > > > > 
> > > > > > We can move this up to under tree_lock. Considering memcg, all our target has "mapping".
> > > > > > 
> > > > > > If we newly account bounce-buffers (for NILFS, FUSE, etc..), which has no ->mapping,
> > > > > > we need much more complex new charge/uncharge theory.
> > > > > > 
> > > > > > But yes, adding new lock scheme seems complicated. (Sorry Andrea.)
> > > > > > My concerns is performance. We may need somehing new re-implementation of
> > > > > > locks/migrate/charge/uncharge.
> > > > > > 
> > > > > I agree. Performance is my concern too.
> > > > > 
> > > > > I made a patch below and measured the time(average of 10 times) of kernel build
> > > > > on tmpfs(make -j8 on 8 CPU machine with 2.6.33 defconfig).
> > > > > 
> > > > > <before>
> > > > > - root cgroup: 190.47 sec
> > > > > - child cgroup: 192.81 sec
> > > > > 
> > > > > <after>
> > > > > - root cgroup: 191.06 sec
> > > > > - child cgroup: 193.06 sec
> > > > > 
> > > > > Hmm... about 0.3% slower for root, 0.1% slower for child.
> > > > > 
> > > > 
> > > > Hmm...accepatable ? (sounds it's in error-range)
> > > > 
> > > > BTW, why local_irq_disable() ? 
> > > > local_irq_save()/restore() isn't better ?
> > > 
> > > Probably there's not the overhead of saving flags? 
> > maybe.
> > 
> > > Anyway, it would make the code much more readable...
> > > 
> > ok.
> > 
> > please go ahead in this direction. Nishimura-san, would you post an
> > independent patch ? If no, Andrea-san, please.
> > 
> This is the updated version.
> 
> Andrea-san, can you merge this into your patch set ?
> 

Please please measure the performance overhead of this change.

-- 
	Three Cheers,
	Balbir
