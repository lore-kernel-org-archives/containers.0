From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: Supporting overcommit with the memory controller
Date: Wed, 5 Mar 2008 18:54:52 -0800
Message-ID: <6599ad830803051854x5ee204bej7212d9c1e444e4d0@mail.gmail.com>
References: <6599ad830803051617w7835d9b2l69bbc1a0423eac41@mail.gmail.com>
	<20080306100158.a521af1b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080306100158.a521af1b.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Content-Disposition: inline
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Memory Management List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Mar 5, 2008 at 5:01 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>  > But to make this more interesting, there are plenty of jobs that will
>  > happily fill as much pagecache as they have available. Even a job
>  > that's just writing out logs will continually expand its pagecache
>  > usage without anything to stop it, and so just keeping the reserved
>  > pool at a fixed amount of free memory will result in the job expanding
>  > even if it doesn't need to.
>  It's current memory management style. "reclaim only when necessary".
>

Exactly - if the high-priority latency-sensitive job really needs that
extra memory, we want it to be able to automatically squash/kill the
low-priority job when memory runs low, and not suffer any latency
spikes. But if it doesn't actually need the memory, we'd rather use it
for low-priority batch stuff. The "no latency spikes" bit is important
- we don't want the high-priority job to get bogged down in
try_to_free_pages() and out_of_memory() loops when it needs to
allocate memory.

>  >
>  Can Balbir's soft-limit patches help ?
>
>  It reclamims each cgroup's pages to soft-limit if the system needs.
>
>  Make limitation  like this
>
>  Assume 4G server.
>                            Limit      soft-limit
>  Not important Apss:         2G          100M
>  Important Apps    :         3G          2.7G
>
>  When the system memory reachs to the limit, each cgroup's memory usages will
>  goes down to soft-limit. (And there will 1.3G of free pages in above example)
>

Yes, that could be a useful part of the solution - I suspect we'd need
to have kswapd do the soft-limit push back as well as in
try_to_free_pages(), to avoid the high-priority jobs getting stuck in
the reclaim code. It would also be nice if we had:

- a way to have the soft-limit pushing kick in substantially *before*
the machine ran out of memory, to provide a buffer for the
high-priority jobs.

- a way to measure the actual working set of a cgroup (which may be
smaller than its allocated memory if it has plenty of stale pagecache
pages allocated). Maybe refaults, or maybe usage-based information.

Paul
