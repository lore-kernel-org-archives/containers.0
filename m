From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Date: Thu, 11 Mar 2010 23:23:48 +0100
Message-ID: <20100311222348.GB2427__22500.4454645843$1268346365$gmane$org@linux>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100311093913.07c9ca8a.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 11, 2010 at 09:39:13AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 10 Mar 2010 00:00:31 +0100
> Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> 
> > Control the maximum amount of dirty pages a cgroup can have at any given time.
> > 
> > Per cgroup dirty limit is like fixing the max amount of dirty (hard to reclaim)
> > page cache used by any cgroup. So, in case of multiple cgroup writers, they
> > will not be able to consume more than their designated share of dirty pages and
> > will be forced to perform write-out if they cross that limit.
> > 
> > The overall design is the following:
> > 
> >  - account dirty pages per cgroup
> >  - limit the number of dirty pages via memory.dirty_ratio / memory.dirty_bytes
> >    and memory.dirty_background_ratio / memory.dirty_background_bytes in
> >    cgroupfs
> >  - start to write-out (background or actively) when the cgroup limits are
> >    exceeded
> > 
> > This feature is supposed to be strictly connected to any underlying IO
> > controller implementation, so we can stop increasing dirty pages in VM layer
> > and enforce a write-out before any cgroup will consume the global amount of
> > dirty pages defined by the /proc/sys/vm/dirty_ratio|dirty_bytes and
> > /proc/sys/vm/dirty_background_ratio|dirty_background_bytes limits.
> > 
> > Changelog (v5 -> v6)
> > ~~~~~~~~~~~~~~~~~~~~~~
> >  * always disable/enable IRQs at lock/unlock_page_cgroup(): this allows to drop
> >    the previous complicated locking scheme in favor of a simpler locking, even
> >    if this obviously adds some overhead (see results below)
> >  * drop FUSE and NILFS2 dirty pages accounting for now (this depends on
> >    charging bounce pages per cgroup)
> > 
> > Results
> > ~~~~~~~
> > I ran some tests using a kernel build (2.6.33 x86_64_defconfig) on a
> > Intel Core 2 @ 1.2GHz as testcase using different kernels:
> >  - mmotm "vanilla"
> >  - mmotm with cgroup-dirty-memory using the previous "complex" locking scheme
> >    (my previous patchset + the fixes reported by Kame-san and Daisuke-san)
> >  - mmotm with cgroup-dirty-memory using the simple locking scheme
> >    (lock_page_cgroup() with IRQs disabled)
> > 
> > Following the results:
> > <before>
> >  - mmotm "vanilla", root  cgroup:			11m51.983s
> >  - mmotm "vanilla", child cgroup:			11m56.596s
> > 
> > <after>
> >  - mmotm, "complex" locking scheme, root  cgroup:	11m53.037s
> >  - mmotm, "complex" locking scheme, child cgroup:	11m57.896s
> > 
> >  - mmotm, lock_page_cgroup+irq_disabled, root  cgroup:	12m5.499s
> >  - mmotm, lock_page_cgroup+irq_disabled, child cgroup:	12m9.920s
> > 
> > With the "complex" locking solution, the overhead introduced by the
> > cgroup dirty memory accounting is minimal (0.14%), compared with the overhead
> > introduced by the lock_page_cgroup+irq_disabled solution (1.90%).
> > 
> Hmm....isn't this bigger than expected ?

Consider that I'm not running the kernel build on tmpfs, but on a fs
defined on /dev/sda. So the additional overhead should be normal
compared to the mmotm vanilla, where there's only FILE_MAPPED
accounting.

-Andrea
