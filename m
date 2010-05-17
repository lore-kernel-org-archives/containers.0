From: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocationAPIs
Date: Mon, 17 May 2010 10:34:30 +0900 (JST)
Message-ID: <20100517103050.21B6.A69D9226__41094.9255842299$1274060139$gmane$org@jp.fujitsu.com>
References: <1273756816.5605.3547.camel@twins>
	<201005132236.ADJ57893.FLFFMtOVJHOOSQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <201005132236.ADJ57893.FLFFMtOVJHOOSQ-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Cc: adilger-xsfywfwIY+M@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, James.Bottomley-l3A5Bk7waGM@public.gmane.org, hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

> Peter Zijlstra wrote:
> > NAK, I really utterly dislike that inatomic argument. The alloc side
> > doesn't function in atomic context either. Please keep the thing
> > symmetric in that regards.
> 
> Excuse me. kmalloc(GFP_KERNEL) may sleep (and therefore cannot be used in
> atomic context). However, kfree() for memory allocated with kmalloc(GFP_KERNEL)
> never sleep (and therefore can be used in atomic context).
> Why kmalloc() and kfree() are NOT kept symmetric?

In kmalloc case, we need to consider both kmalloc(GFP_KERNEL)/kfree() pair and
kmalloc(GFP_ATOMIC)/kfree() pair. latter is mainly used on atomic context.
To make kfree() atomic help to keep the implementation simple.

But kvmalloc don't have GFP_ATOMIC feautre. that's big difference.
