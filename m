From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Wed, 22 Apr 2009 09:00:32 +0530
Message-ID: <20090422033032.GR19637__45677.8581873097$1240371338$gmane$org@balbir.in.ibm.com>
References: <20090417143903.GA30365@linux> <20090421001822.GB19186@mit.edu>
	<20090421083001.GA8441@linux> <20090421140631.GF19186@mit.edu>
	<20090421143130.GA22626@linux> <20090421163537.GI19186@mit.edu>
	<20090421172317.GM19637@balbir.in.ibm.com>
	<20090421174620.GD15541@mit.edu>
	<20090421181429.GO19637@balbir.in.ibm.com>
	<20090421191401.GF15541@mit.edu>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090421191401.GF15541-3s7WtUTddSA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Gui Jianfeng <guijianfeng-LZPS87bAVCA@public.gmane.org>
List-Id: containers.vger.kernel.org

* Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org> [2009-04-21 15:14:01]:

> On Tue, Apr 21, 2009 at 11:44:29PM +0530, Balbir Singh wrote:
> > 
> > That would be true in general, but only the process writing to the
> > file will dirty it. So dirty already accounts for the read/write
> > split. I'd assume that the cost is only for the dirty page, since we
> > do IO only on write in this case, unless I am missing something very
> > obvious.
> 
> Maybe I'm missing something, but the (in development) patches I saw
> seemed to use the existing infrastructure designed for RSS cost
> tracking (which is also not yet in mainline, unless I'm mistaken ---
> but I didn't see page_get_page_cgroup() in the mainline tree yet).
> 
> Right?  So if process A in cgroup A reads touches the file first by
> reading from it, then the pages read by process A will be assigned as
> being "owned" by cgroup A.   Then when the patch described at
> 
>       http://lkml.org/lkml/2008/9/9/245

That is correct, but on reclaim (hitting the limit) a page that is frequently
used by B and not A, can get reclaimed from A and move to B if B is
heavily using it.

> 
> ... tries to charge a write done by process B in cgroup B, the code
> will call page_get_page_cgroup(), see that it is "owned" by cgroup A,
> and charge the dirty page to cgroup A.  If process A and all of the
> other processes in cgroup A only access this file read-only, and
> process B is updating this file very heavily --- and it is a large
> file --- then cgroup B will get a completely free pass as far as
> dirtying pages to this file, since it will be all charged 100% to
> cgroup A, incorrectly.
> 
> So what am I missing?

You are right. As long as A is not exceeding its limit, B will get a
free pass at the page. The page will be inactive on A's LRU and active
on the global LRU though from the memory controller perspective. We'll
need to find a way to fix this, if this is a very common scenario for
the IO controller.

-- 
	Balbir
