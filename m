From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Tue, 24 Mar 2009 20:04:16 +0100
Message-ID: <20090324190416.GP18554__40130.217295564$1237921176$gmane$org@gandalf.sssup.it>
References: <20090312100054.GA8024@linux.vnet.ibm.com>
	<20090312140450.GE10919@redhat.com>
	<49C0A171.8060009@cn.fujitsu.com>
	<20090318215529.GA3338@redhat.com>
	<e98e18940903232232i432f62c5r9dfd74268e1b2684@mail.gmail.com>
	<20090324125842.GA21389@redhat.com>
	<e98e18940903241114u1e03ae7dhf654d7d8d0fc0302@mail.gmail.com>
	<20090324182906.GF21389@redhat.com>
	<20090324184101.GO18554@gandalf.sssup.it>
	<20090324183532.GG21389@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090324183532.GG21389-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

> From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Tue, Mar 24, 2009 02:35:32PM -0400
>
> On Tue, Mar 24, 2009 at 07:41:01PM +0100, Fabio Checconi wrote:
> > > From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > Date: Tue, Mar 24, 2009 02:29:06PM -0400
> > >
> > ...
> > > > Does keeping the sync queue in ready tree solves the problem too? Is
> > > > it because it avoid a virtual time jump?
> > > > 
> > > 
> > > I have not tried the second approch yet. But that also should solve the
> > > vtime jump issue.
> > > 
> > 
> > Do you mean that you intend to keep a queue with no backlog in the
> > active tree?
> 
> Yes. Is it possible to keep a not-backlogged queue in the tree for later
> expiry. So that we don't actively wait/idle for next request to come and
> hope queue will become backlogged soon. Otherwise, it will be deleted from
> the active queue. This is just a thought, I am not even sure how would it
> interefere with bfq code.
> 
> All this to solve the vtime jump issue for sync queues.
> 

Of course it is possible, but if you stick with wf2q+ the virtual time
will jump anyway, and the gain would be that each scheduling decision
will have O(N logN) complexity instead of O(log N), to skip empty
queues.

Otherwise, if you'll do your own timestamping (where any new request
can get a timestamp smaller that the virtual time) then nothing from
the theory BFQ was based on can give any hint on the guarantees that
the resulting algorithm can provide.
