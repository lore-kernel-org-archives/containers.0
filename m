From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 3/4] io controller: Core IO controller implementation logic
Date: Fri, 7 Nov 2008 09:50:36 -0500
Message-ID: <20081107145036.GF21884__8706.59415745667$1226069779$gmane$org@redhat.com>
References: <20081106153022.215696930@redhat.com>
	<20081106153135.869625751@redhat.com>
	<20081107122145.69500cd3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081107122145.69500cd3.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Nov 07, 2008 at 12:21:45PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 06 Nov 2008 10:30:25 -0500
> vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org wrote:
> 
> > 
> > o Core IO controller implementation
> > 
> > Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > 
> 
> 2 comments after a quick look.
> 
>  - I don't recommend generic work queue. More stacked dependency between "work"
>    is not good. (I think disk-driver uses "work" for their jobs.)

Sorry, I did not get this. Are you recommending that don't create a new
work queue, instead use existing work queue (say kblockd) to submit the bios
here?

I will look into it. I was little worried about a kblockd being overworked
in case of too many logical devices enabling IO controller.

> 
>  - It seems this bio-cgroup can queue the bio to infinite. Then, a process can submit
>    io unitl cause OOM.
>    (IIUC, Dirty bit of the page is cleared at submitting I/O. 
>     Then dirty_ratio can't help us.)
>    please add "wait for congestion by sleeping" code in bio-cgroup.

Yes, you are right. I need to put some kind of control on max number of
bios I can queue on a cgroup and after crossing the limit, I should put
the submitting task to sleep. (Something like request descriptor kind of
flow control implememented by elevators).

Thanks
Vivek
