From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 0/4] memcg: per cgroup dirty limit (v4)
Date: Thu, 4 Mar 2010 22:37:34 +0100
Message-ID: <20100304213734.GA4787__2146.01785778559$1267751407$gmane$org@linux>
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
	<20100304171143.GG3073@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100304171143.GG3073-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 04, 2010 at 10:41:43PM +0530, Balbir Singh wrote:
> * Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> [2010-03-04 11:40:11]:
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
> > Changelog (v3 -> v4)
> > ~~~~~~~~~~~~~~~~~~~~~~
> >  * handle the migration of tasks across different cgroups
> >    NOTE: at the moment we don't move charges of file cache pages, so this
> >    functionality is not immediately necessary. However, since the migration of
> >    file cache pages is in plan, it is better to start handling file pages
> >    anyway.
> >  * properly account dirty pages in nilfs2
> >    (thanks to Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>)
> >  * lockless access to dirty memory parameters
> >  * fix: page_cgroup lock must not be acquired under mapping->tree_lock
> >    (thanks to Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> and
> >     KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>)
> >  * code restyling
> >
> 
> This seems to be converging, what sort of tests are you running on
> this patchset? 

A very simple test at the moment, just some parallel dd's running in
different cgroups. For example:

 - cgroup A: low dirty limits (writes are almost sync)
   echo 1000 > /cgroups/A/memory.dirty_bytes
   echo 1000 > /cgroups/A/memory.dirty_background_bytes

 - cgroup B: high dirty limits (writes are all buffered in page cache)
   echo 100 > /cgroups/B/memory.dirty_ratio
   echo 50  > /cgroups/B/memory.dirty_background_ratio

Then run the dd's and look at memory.stat:
  - cgroup A: # dd if=/dev/zero of=A bs=1M count=1000
  - cgroup B: # dd if=/dev/zero of=B bs=1M count=1000

A random snapshot during the writes:

# grep "dirty\|writeback" /cgroups/[AB]/memory.stat
/cgroups/A/memory.stat:filedirty 0
/cgroups/A/memory.stat:writeback 0
/cgroups/A/memory.stat:writeback_tmp 0
/cgroups/A/memory.stat:dirty_pages 0
/cgroups/A/memory.stat:writeback_pages 0
/cgroups/A/memory.stat:writeback_temp_pages 0
/cgroups/B/memory.stat:filedirty 67226
/cgroups/B/memory.stat:writeback 136
/cgroups/B/memory.stat:writeback_tmp 0
/cgroups/B/memory.stat:dirty_pages 67226
/cgroups/B/memory.stat:writeback_pages 136
/cgroups/B/memory.stat:writeback_temp_pages 0

I plan to run more detailed IO benchmark soon.

-Andrea
