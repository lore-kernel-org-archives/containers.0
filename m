From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] io-controller: Add io group reference handling for request
Date: Wed, 27 May 2009 10:17:50 +0200
Message-ID: <20090527081749.GA7237__13806.7304077142$1243412380$gmane$org@linux>
References: <20090518140114.GB27080@redhat.com> <20090518143921.GE3113@linux>
	<20090526.203424.39179999.ryov@valinux.co.jp>
	<20090527.155631.226800550.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090527.155631.226800550.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 27, 2009 at 03:56:31PM +0900, Ryo Tsuruta wrote:
> > I think that only putting the hook in try_to_unmap() doesn't work
> > correctly, because IOs will be charged to reclaiming processes or
> > kswapd. These IOs should be charged to processes which cause memory
> > pressure.
> 
> Consider the following case:
> 
>   (1) There are two processes Proc-A and Proc-B.
>   (2) Proc-A maps a large file into many pages by mmap() and writes
>       many data to the file.
>   (3) After (2), Proc-B try to get a page, but there are no available
>       pages because Proc-A has used them.
>   (4) kernel starts to reclaim pages, call try_to_unmap() to unmap
>       a page which is owned by Proc-A, then blkio_cgroup_set_owner()
>       sets Proc-B's ID on the page because the task's context is Proc-B.
>   (5) After (4), kernel writes the page out to a disk. This IO is
>       charged to Proc-B.
> 
> In the above case, I think that the IO should be charged to a Proc-A,
> because the IO is caused by Proc-A's memory pressure. 
> I think we should consider in the case without memory and swap
> isolation.

mmmh.. even if they're strictly related I think we're mixing two
different problems in this way: memory pressure control and IO control.

It seems you're proposing something like the badness() for OOM
conditions to charge swap IO depending on how bad is a cgroup in terms
of memory consumption. I don't think this is the right way to proceed,
also because we already have the memory and swap control.

-Andrea
