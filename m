From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Fri, 24 Apr 2009 20:40:51 +0530
Message-ID: <20090424151051.GF3944__25894.1054381014$1240586165$gmane$org@balbir.in.ibm.com>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-10-git-send-email-righi.andrea@gmail.com>
	<20090417123805.GC7117@mit.edu> <20090417125004.GY4593@kernel.dk>
	<20090417143903.GA30365@linux> <20090421001822.GB19186@mit.edu>
	<20090421083001.GA8441@linux> <20090421140631.GF19186@mit.edu>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090421140631.GF19186-3s7WtUTddSA@public.gmane.org>
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

* Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org> [2009-04-21 10:06:31]:

> On Tue, Apr 21, 2009 at 10:30:02AM +0200, Andrea Righi wrote:
> > 
> > We're trying to address also this issue, setting max dirty pages limit
> > per cgroup, and force a direct writeback when these limits are exceeded.
> > 
> > In this case dirty ratio throttling should happen automatically because
> > the process will be throttled by the IO controller when it tries to
> > writeback the dirty pages and submit IO requests.
> 
> The challenge here will be the accounting; consider that you may have
> a file that had some of its pages in its page cache dirtied by a
> process in cgroup A.  Now another process in cgroup B dirties some
> more pages.  This could happen either via a mmap'ed file or via the
> standard read/write system calls.  How do you track which dirty pages
> should be charged against which cgroup?

We have ways to track the cgroup from either "mm_struct" or the
"page". Given the context, vma or mm, we should be able to charge the
page to the cgroup, undoing the charge might be challenge since we'll
need to figure out whom to uncharge from the write context. This needs
some investigation. We could even decay the charge or use similar
techniques, don't know yet.

-- 
	Balbir
