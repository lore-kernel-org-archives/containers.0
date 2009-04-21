From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Tue, 21 Apr 2009 23:44:29 +0530
Message-ID: <20090421181429.GO19637__31051.2998061769$1240338029$gmane$org@balbir.in.ibm.com>
References: <20090417123805.GC7117@mit.edu> <20090417125004.GY4593@kernel.dk>
	<20090417143903.GA30365@linux> <20090421001822.GB19186@mit.edu>
	<20090421083001.GA8441@linux> <20090421140631.GF19186@mit.edu>
	<20090421143130.GA22626@linux> <20090421163537.GI19186@mit.edu>
	<20090421172317.GM19637@balbir.in.ibm.com>
	<20090421174620.GD15541@mit.edu>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090421174620.GD15541-3s7WtUTddSA@public.gmane.org>
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

* Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org> [2009-04-21 13:46:20]:

> On Tue, Apr 21, 2009 at 10:53:17PM +0530, Balbir Singh wrote:
> > Coming to the dirty page tracking issue, the issue that is being
> > brought about is the same issue that we have shared page accounting. I
> > am working on estimates for shared page accounting and it should be
> > possible to extend it to dirty shared page accounting. Using the
> > shared ratios for decisions might be a better strategy.
> 
> It's the same issue, but again, consider the use case where the
> readers and the writers are in different cgroups.  This can happen
> quite often in database workloads, where you might have many readers,
> and a single process doing the database update.  Or the case where you
> have one process in one cgroup doing a tail -f of some log file, and
> another process doing writing to the log file.
> 

That would be true in general, but only the process writing to the
file will dirty it. So dirty already accounts for the read/write
split. I'd assume that the cost is only for the dirty page, since we
do IO only on write in this case, unless I am missing something very
obvious.

> Using a shared ratio is certainly better than charging 100% of the
> write to whichever unfortunate process happened to first read the
> page, but it will still not be terribly accurate.  A lot really
> depends on how you expect these cgroup limits will be used, and what
> the requirements actually will be with respect to accuracy.  If the
> requirements for accuracy are different for RSS tracking and dirty
> page tracking --- which could easily be the case, since memory is
> usually much cheaper than I/O bandwidth, and there is generally far
> more clean memory pages than there are dirty memory pages, so a small
> numberical error in dirty page accounting translates to a much larger
> percentage error than read-only RSS page accounting --- it may make
> sense to use different mechanisms for tracking the two, given the
> different requirements and differring overhead implications.
>
> Anyway, something for you to think about.

Yep, but I would recommend using the controller we have, if the
overheads span out to be too large for IO, we think about
alternatives.

-- 
	Balbir
