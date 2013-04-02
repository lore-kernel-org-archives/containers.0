From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH v2 00/28] memcg-aware slab shrinking
Date: Tue, 2 Apr 2013 15:58:42 +1100
Message-ID: <20130402045842.GO6369__7595.73351028866$1364878760$gmane$org@dastard>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<20130401123843.GC5217@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130401123843.GC5217@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Apr 01, 2013 at 07:38:43AM -0500, Serge Hallyn wrote:
> Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> > Hi,
> > 
> > Notes:
> > ======
> > 
> > This is v2 of memcg-aware LRU shrinking. I've been testing it extensively
> > and it behaves well, at least from the isolation point of view. However,
> > I feel some more testing is needed before we commit to it. Still, this is
> > doing the job fairly well. Comments welcome.
> 
> Do you have any performance tests (preferably with enough runs with and
> without this patchset to show 95% confidence interval) to show the
> impact this has?  Certainly the feature sounds worthwhile, but I'm
> curious about the cost of maintaining this extra state.

The reason for the node-aware LRUs in the first place is
performance. i.e. to remove the global LRU locks from the shrinkers
and LRU list operations. For XFS (at least) the VFS LRU operations
are significant sources of contention at 16p, and at high CPU counts
they can basically cause spinlock meltdown.

I've done performance testing on them on 16p machines with
fake-numa=4 under such contention generating workloads (e.g. 16-way
concurrent fsmark workloads) and seen that the LRU locks disappear
from the profiles. Performance improvement at this size of machine
under these workloads is still within the run-to-run variance of the
benchmarks I've run, but the fact the lock is no longer in the
profiles at all suggest that scalability for larger machines will be
significantly improved.

As for the memcg side of things, I'll leave that to Glauber....

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
