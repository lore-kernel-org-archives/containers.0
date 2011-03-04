From: Daniel Poelzleithner <poelzi-j3Gp85GwYS0dnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup memory, blkio and the lovely swapping
Date: Fri, 4 Mar 2011 09:11:32 +0100
Message-ID: <20110304091132.6de2ed94__32066.3688741208$1299226385$gmane$org@sol>
References: <20110304083944.22fb612f@sol>
	<20110304165455.d438342a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110304165455.d438342a.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 4 Mar 2011 16:54:55 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:

> Now, blkio cgroup does work only with synchronous I/O(direct I/O)
> and never work with swap I/O. And I don't think swap-i/o limit
> is a blkio matter.

I'm totally unsure about what subsystem it really belongs to. It is
memory for sure, but disk access, which it actually affects, belongs to
the blkio subsystem. Is there a technical reason why swap I/O is not run
through the blkio system ?


> Memory cgroup is now developping dirty_ratio for memory cgroup.
> By that, you can control the number of pages in writeback, in memory
> cgroup. I think it will work for you.

I'm not sure that fixes the fairness problem on swapio. Just having a
larger buffer before a writeback happens will reduce seeks, but not
give fair share of io in swap in. It's good to control over it on
cgroup level, but i doubt it will fix the problem.



kind regards
 Daniel
