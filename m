From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/7] cgroup: io-throttle controller (v14)
Date: Tue, 21 Apr 2009 11:58:49 +0200
Message-ID: <20090421095848.GB13699__7418.94829920984$1240308201$gmane$org@linux>
References: <1240090636-898-1-git-send-email-righi.andrea@gmail.com>
	<49EC34C1.6010709@cn.fujitsu.com> <20090420144816.GA13307@linux>
	<49ED1E66.6030604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49ED1E66.6030604-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 21, 2009 at 09:16:22AM +0800, Gui Jianfeng wrote:
> Andrea Righi wrote:
> > On Mon, Apr 20, 2009 at 04:39:29PM +0800, Gui Jianfeng wrote:
> >> Andrea Righi wrote:
> >> ...
> >>> Implementation
> >>> ~~~~~~~~~~~~~~
> >>> Patchset against latest Linus' git:
> >>>
> >>>   [PATCH 0/7] cgroup: block device IO controller (v14)
> >>>   [PATCH 1/7] io-throttle documentation
> >>>   [PATCH 2/7] res_counter: introduce ratelimiting attributes
> >>>   [PATCH 3/7] page_cgroup: provide a generic page tracking infrastructure
> >>>   [PATCH 4/7] io-throttle controller infrastructure
> >>>   [PATCH 5/7] kiothrottled: throttle buffered (writeback) IO
> >>>   [PATCH 6/7] io-throttle instrumentation
> >>>   [PATCH 7/7] export per-task io-throttle statistics to userspace
> >>   Hi Andrea,
> >>
> >>   I'd like to have a try this patchset, would you tell what's the kernel version
> >>   and bio-cgroup version based on?
> >>
> > 
> > Latest Linus' git is the kernel and bio-cgroup v7 (from
> > http://people.valinux.co.jp/~ryov/bio-cgroup/).
> 
>   Sorry, I still can't apply it...
> 
> [root@localhost linux-2.6.30-rc1]# patch -p1 --dry-run < ../cgroup-io-throttle-v14.patch                                                                                         patching file Documentation/cgroups/io-throttle.txt
> patching file block/Makefile
> patching file block/blk-core.c
> patching file block/blk-io-throttle.c
> patching file block/kiothrottled.c
> patching file fs/aio.c
> patching file fs/buffer.c
> Hunk #1 FAILED at 36.
> Hunk #2 FAILED at 669.
> 2 out of 2 hunks FAILED -- saving rejects to file fs/buffer.c.rej
> patching file fs/proc/base.c
> patching file include/linux/blk-io-throttle.h
> patching file include/linux/cgroup_subsys.h
> Hunk #1 succeeded at 49 (offset 6 lines).
> patching file include/linux/memcontrol.h
> Reversed (or previously applied) patch detected!  Assume -R? [n] n
> Apply anyway? [n] n
> Skipping patch.
> 2 out of 2 hunks ignored -- saving rejects to file include/linux/memcontrol.h.rej
> patching file include/linux/mmzone.h
> Hunk #1 FAILED at 607.
> Hunk #2 FAILED at 958.
> ...

Could you checkout the latest Linus' git?

$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git linux-2.6

Or at least try with 2.6.30-rc2. It should apply cleanly also to this
version.

-Andrea
