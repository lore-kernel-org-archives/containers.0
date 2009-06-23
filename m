From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Tue, 23 Jun 2009 13:02:52 +0530
Message-ID: <20090623073252.GJ8642__1480.03972503847$1245742484$gmane$org@balbir.in.ibm.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-3-git-send-email-vgoyal@redhat.com>
	<20090622084612.GD3728@balbir.in.ibm.com>
	<20090622124313.GF28770@gandalf.sssup.it>
	<20090623024337.GC3620@redhat.com>
	<20090623041052.GS28770@gandalf.sssup.it>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090623041052.GS28770-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

* Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2009-06-23 06:10:52]:

> > From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > Date: Mon, Jun 22, 2009 10:43:37PM -0400
> >
> > On Mon, Jun 22, 2009 at 02:43:13PM +0200, Fabio Checconi wrote:
> > 
> ...
> > > > Please help me understand this, we sort the tree by finish time, but
> > > > search by vtime, start_time. The worst case could easily be O(N),
> > > > right?
> > > > 
> > > 
> > > no, (again, the full answer is in the paper); the nice property of
> > > min_start is that it partitions the tree in two regions, one with
> > > eligible entities and one without any of them.  once we know that
> > > there is one eligible entity (checking the min_start at the root)
> > > we can find the node i with min(F_i) subject to S_i < V walking down
> > > a single path from the root to the leftmost eligible entity.  (we
> > > need to go to the right only if the subtree on the left contains 
> > > no eligible entities at all.)  since the RB tree is balanced this
> > > can be done in O(log N).
> > > 
> > 
> > Hi Fabio,
> > 
> > When I go thorough the paper you mentioned above, they seem to have
> > sorted the tree based on eligible time (looks like equivalent of start
> > time) and then keep track of minimum deadline on each node (equivalnet of
> > finish time).
> > 
> > We seem to be doing reverse in BFQ where we sort tree on finish time
> > and keep track of minimum start time on each node. Is there any specific
> > reason behind that?
> > 
> 
> Well... no specific reasons...  I think that our implementation is easier
> to understand than the one of the paper, because it actually uses finish
> times as the ordering key, and min_start to quickly locate eligible
> subtrees, following the definition of the algorithm.
> 

Is it still O(log N)?

> Moreover, if you look at the get_req() code in the paper, it needs a
> couple of loops to get to the result, while with our implementation
> we save the second loop.
> 
> Our version is still correct, because it always moves to the left
> (towards smaller finish times), except when moving to the left would
> mean entering a non feasible subtree, in which case it moves to the
> right.
> 
> Unfortunately I'm not aware of any paper describing a version of the
> algorithm more similar to the one we've implemented.  Sorry for not
> having mentioned that difference in the comments nor anywhere else,
> it has been a long long time since I read the paper, and I must have
> forgotten about that.

/me needs to go read the paper in full.

-- 
	Balbir
