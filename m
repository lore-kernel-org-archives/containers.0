From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH 0/2] memcg: per cgroup dirty limit
Date: Mon, 22 Feb 2010 09:27:45 -0500
Message-ID: <20100222142744.GB13823__6512.098076246$1266849084$gmane$org@redhat.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1266765525-30890-1-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Feb 21, 2010 at 04:18:43PM +0100, Andrea Righi wrote:
> Control the maximum amount of dirty pages a cgroup can have at any given time.
> 
> Per cgroup dirty limit is like fixing the max amount of dirty (hard to reclaim)
> page cache used by any cgroup. So, in case of multiple cgroup writers, they
> will not be able to consume more than their designated share of dirty pages and
> will be forced to perform write-out if they cross that limit.
> 
> The overall design is the following:
> 
>  - account dirty pages per cgroup
>  - limit the number of dirty pages via memory.dirty_bytes in cgroupfs
>  - start to write-out in balance_dirty_pages() when the cgroup or global limit
>    is exceeded
> 
> This feature is supposed to be strictly connected to any underlying IO
> controller implementation, so we can stop increasing dirty pages in VM layer
> and enforce a write-out before any cgroup will consume the global amount of
> dirty pages defined by the /proc/sys/vm/dirty_ratio|dirty_bytes limit.
> 

Thanks Andrea. I had been thinking about looking into it from IO
controller perspective so that we can control async IO (buffered writes
also).

Before I dive into patches, two quick things.

- IIRC, last time you had implemented per memory cgroup "dirty_ratio" and
  not "dirty_bytes". Why this change? To begin with either per memcg
  configurable dirty ratio also makes sense? By default it can be the
  global dirty ratio for each cgroup.

- Looks like we will start writeout from memory cgroup once we cross the
  dirty ratio, but still there is no gurantee that we be writting pages
  belonging to cgroup which crossed the dirty ratio and triggered the
  writeout.

  This behavior is not very good at least from IO controller perspective
  where if two dd threads are dirtying memory in two cgroups, then if
  one crosses it dirty ratio, it should perform writeouts of its own pages
  and not other cgroups pages. Otherwise we probably will again introduce
  serialization among two writers and will not see service differentation.

  May be we can modify writeback_inodes_wbc() to check first dirty page
  of the inode. And if it does not belong to same memcg as the task who
  is performing balance_dirty_pages(), then skip that inode.

  This does not handle the problem of shared files where processes from
  two different cgroups are dirtying same file but it will atleast cover
  other cases without introducing too much of complexity?

Thanks
Vivek

> TODO:
>  - handle the migration of tasks across different cgroups (a page may be set
>    dirty when a task runs in a cgroup and cleared after the task is moved to
>    another cgroup).
>  - provide an appropriate documentation (in Documentation/cgroups/memory.txt)
> 
> -Andrea
