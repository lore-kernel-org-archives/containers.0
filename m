From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [Xen-devel] Re: [PATCH 7/9] blkio-cgroup-v9: Page tracking hooks
Date: Fri, 24 Jul 2009 15:19:23 +0900
Message-ID: <20090724151923.986dd932.kamezawa.hiroyu__43481.7811860286$1248416561$gmane$org@jp.fujitsu.com>
References: <20090723164935.e97a3ccf.kamezawa.hiroyu@jp.fujitsu.com>
	<20090723.190253.226783703.ryov@valinux.co.jp>
	<5971c26b399a97f51dd10ea497617733.squirrel@webmail-b.css.fujitsu.com>
	<20090724.144416.71112906.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724.144416.71112906.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 24 Jul 2009 14:44:16 +0900 (JST)
Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
 good solution to resolve such problem.
> 
> > My point is "don't allow anyone to use bandwidth of others."
> > Considering job isolation, a thread who requests swap-out should be charg=
> > ed
> > against bandwidth.
> 
> From another perspective, the swap-out is caused since the buggy
> process uses a large amount of memory, so it can be considered as 
> the bandwidth of logging process is used due to the buggy process.
> 
> Please consider the following case. If a thread who requests swap-out
> is charged, the thread is charged other threads' I/O.
> 
>    (1)                          --------      (2)
>    Process A                   |        |     Process B
>    mmaps a large area in   --> | memory | <-- tries to allocate a page.
>    the memory and writes       |        |
>    data to there.               --------     (3)
>                                    |         To get a free page,
>                                    |         the data written by Proc.A
>                                    |         is written out to the disk.
>                                    V         The I/O is done by using
>                                 ---------    Proc.B's bandwidth.
>                                |  disk   |   
>                                 ---------
> 
> Thus I think that page owners should be charged against bandwidth.
> 
Ok, no good way. yours is wrong, mine is wrong, too.
plz find 3rd way, reasonable.

Below is brief thinking.

"Why process A should be charged to I/O when it just maps anon memory ?"
I can't answer this.

Even in yorr case, Process B requests memory and get penalty. It's
very natural, I think.

In usual case, 
 - if process A maps ANON, there will be no I/O.
 - if process A maps FILE, it will be charged to process A.
ok ?

Under memory pressure,
 - if process A maps ANON, swap I/O should be charged to process B.
 - if process A maps FILE, I/O should be charged to process A.
maybe. 


Anyway, there will be ineraction with dirty_ratio of memcg (not implemeted yet)
and _Owner should be charged_ issue will be handled in this dirty_ratio layer.
More consideration is necessary, I think.


Bye,
-Kame
