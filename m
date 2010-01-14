From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH 2/2] cgroups: blkio subsystem as module
Date: Thu, 14 Jan 2010 06:42:43 -0500
Message-ID: <20100114114243.GC15559__2688.17061228237$1263469446$gmane$org@redhat.com>
References: <20091231051050.GA714@andrew.cmu.edu>
	<20100106160414.bd555474.akpm@linux-foundation.org>
	<20100107012606.GA25577@andrew.cmu.edu>
	<20100107120732.97d502bd.kamezawa.hiroyu@jp.fujitsu.com>
	<4B45824B.9030108@cn.fujitsu.com>
	<20100108052734.GA13168@andrew.cmu.edu>
	<20100108053021.GC13168@andrew.cmu.edu>
	<20100108151038.GA22219@redhat.com>
	<20100112092106.9ac4e535.kamezawa.hiroyu@jp.fujitsu.com>
	<661de9471001140132o23f44a4fjb1849d865f96d19a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <661de9471001140132o23f44a4fjb1849d865f96d19a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jan 14, 2010 at 03:02:09PM +0530, Balbir Singh wrote:
> On Tue, Jan 12, 2010 at 5:51 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > On Fri, 8 Jan 2010 10:10:38 -0500
> > Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >
> >> On Fri, Jan 08, 2010 at 12:30:21AM -0500, Ben Blum wrote:
> >> > Convert blk-cgroup to be buildable as a module
> >> >
> >> > From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
> >> >
> >> > This patch modifies the Block I/O cgroup subsystem to be able to be built as a
> >> > module. As the CFQ disk scheduler optionally depends on blk-cgroup, config
> >> > options in block/Kconfig, block/Kconfig.iosched, and block/blk-cgroup.h are
> >> > enhanced to support the new module dependency.
> >> >
> >>
> >> Hi Ben,
> >>
> >> I will give this patch a try.
> >>
> >> So from blk-cgroup perspective, the advantage of allowing it as module
> >> will be that we can save some memory if we are not using the controller?
> >>
> > Is "moduled" blkio cgroup safe after page-tracking by page_cgroup is
> > introduced ?
> >
> 
> My guess is it won't be, unless we start exposing page_cgroup API and
> then make the module depend on memcg.

I think I agree. When we introduce page_cgroup based page tracking, either
we need to export page_cgroup API or we can force blkio controller to
compile as in-kernel if user selects the CONFIG_PAGE_TRACKING option.

So as of now, I can't think why we should not we allow compiling blkio as
module as long as core cgroup functionality supports it safely.

Thanks
Vivek
