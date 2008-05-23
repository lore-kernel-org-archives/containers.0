From: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
Date: Thu, 22 May 2008 23:32:07 -0400
Message-ID: <20080522233207.6ddfa884@bree.surriel.com>
References: <48350F15.9070007@mxp.nes.nec.co.jp>
	<20080522222655.166657da@bree.surriel.com>
	<20080523121027.b0eecfa0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080523121027.b0eecfa0.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, YAMAMOTO-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 23 May 2008 12:10:27 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> On Thu, 22 May 2008 22:26:55 -0400
> Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > Even worse is that a cgroup has NO CONTROL over how much
> > of its memory is kept in RAM and how much is swapped out.
> Could you explain "NO CONTROL" ? cgroup has LRU....
> 'how mucch memory should be swapped out from memory' is well controlled
> in the VM besides LRU logic ?

The kernel controls what is swapped out.  The userland
processes in the cgroup can do nothing to reduce their
swap usage.

> Consider following system. (and there is no swap controller.) 
> Memory 4G. Swap 1G. with 2 cgroups A, B.
> 
> state 1) swap is not used.
>   A....memory limit to be 1G  no swap usage memory_usage=0M
>   B....memory limit to be 1G  no swap usage memory_usage=0M
> 
> state 2) Run a big program on A.
>   A....memory limit to be 1G and try to use 1.7G. uses 700MBytes of swap.
>        memory_usage=1G swap_usage=700M
>   B....memory_usage=0M
> 
> state 3) A some of programs ends in 'A'
>   A....memory_usage=500M swap_usage=700M
>   B....memory_usage=0M.
> 
> state 4) Run a big program on B.
>   A...memory_usage=500M swap_usage=700M.
>   B...memory_usage=1G   swap_usage=300M
> 
> Group B can only use 1.3G because of unfair swap use of group A.
> But users think why A uses 700M of swap with 500M of free memory....
> 
> If we don't have limitation to swap, we'll have to innovate a way to move swap
> to memory in some reasonable logic.

OK, I see the use case.

In the above example, it would be possible for cgroup A
to have only 800MB of anonymous memory total, in addition
to 400MB of page cache.  The page cache could push the
anonymous memory into swap, indirectly penalizing how much
memory cgroup B can use.

Of course, it could be argued that the system should just
be run with enough swap space, but that is another story :)

-- 
All rights reversed.
