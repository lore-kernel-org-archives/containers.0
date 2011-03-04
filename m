From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: cgroup memory, blkio and the lovely swapping
Date: Fri, 4 Mar 2011 16:54:55 +0900
Message-ID: <20110304165455.d438342a.kamezawa.hiroyu__7326.23606822944$1299225713$gmane$org@jp.fujitsu.com>
References: <20110304083944.22fb612f@sol>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110304083944.22fb612f@sol>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daniel Poelzleithner <poelzi-j3Gp85GwYS0dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 4 Mar 2011 08:39:44 +0100
Daniel Poelzleithner <poelzi-j3Gp85GwYS0dnm+yROfE0A@public.gmane.org> wrote:

> Hi,
> 
> currently when one process causes heavy swapping, the responsiveness of
> the hole system suffers greatly. With the small memleak [1] test tool I
> wrote, the effect can be experienced very easily, depending on the
> delay the lag can become quite large. If I ensure that 10% of the RAM
> stay free for free memory and cache, the system never swaps to death.
> That works very well, but if accesses to the swap are very heavy, the
> system still lags on all other processes, not only the swapping one.
> Putting the swapping process into a blkio cgroup with little weight does
> not affect the io or swap io from other processes with larger weight in
> their group.
> 
> Maybe I'm mistaken, but wouldn't it be the easiest way to get fair
> swapping and control to let the pagein respect the blkio.weight value
> or even better add a second weight value for swapping io ?
> 

Now, blkio cgroup does work only with synchronous I/O(direct I/O)
and never work with swap I/O. And I don't think swap-i/o limit
is a blkio matter.

Memory cgroup is now developping dirty_ratio for memory cgroup.
By that, you can control the number of pages in writeback, in memory cgroup.
I think it will work for you.

Thanks,
-Kame
