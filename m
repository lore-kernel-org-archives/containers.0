From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/2] memcg: dirty pages instrumentation
Date: Mon, 1 Mar 2010 09:47:02 +0900
Message-ID: <20100301094702.ae0fe7fc.kamezawa.hiroyu__31352.0892792896$1267404796$gmane$org@jp.fujitsu.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-3-git-send-email-arighi@develer.com>
	<20100223212943.GF11930@redhat.com> <20100225151211.GC3964@linux>
	<20100226214811.GB7498@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100226214811.GB7498-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 26 Feb 2010 16:48:11 -0500
Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On Thu, Feb 25, 2010 at 04:12:11PM +0100, Andrea Righi wrote:
> > On Tue, Feb 23, 2010 at 04:29:43PM -0500, Vivek Goyal wrote:
> > > On Sun, Feb 21, 2010 at 04:18:45PM +0100, Andrea Righi wrote:

> Because bdi_thres calculation will be based on per cgroup dirty and
> bdi_nr_reclaimable and bdi_nr_writeback will be system wide, we will be
> doing much more aggressive writeouts.
> 
> But we will not achieve parallel writeback paths so probably will not help IO
> controller a lot.
> 
> Kame-san, is it a problem, with current memory cgroups where writeback is
> not happening that actively, and you run into situation where there are too
> many dirty pages in a cgroup and reclaim can take long time?
> 
Hmm, not same situation to the global memory management, but we have similar.

In memcg, we just count user's page, "hard to reclaim" situation doesn't happen.
But "reclaim is slower than expected" is an usual problem.

When you try 
% dd id=/dev/zero of=./tmpfifle .....
under proper limitation of memcg, you'll find dd is very slow.
We know background writeback helps this situation. We need to kick background
write-back.

Thanks,
-Kame
