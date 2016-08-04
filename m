From: Andrew Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: why this behavior in 3.16 kernel ?
Date: Wed, 3 Aug 2016 23:21:50 -0700
Message-ID: <20160804062150.GB14503@gmail.com>
References: <CAJ5w2CmDcXzOKppojwN2F5H-mFu_OM-XUoTWnTuLKrdoPG9iQg@mail.gmail.com>
	<877fbxhhfi.fsf@x220.int.ebiederm.org>
	<20160804011401.GA20044@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160804011401.GA20044-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cool linux <linux.cool.hot-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 03, 2016 at 06:14:02PM -0700, Andrew Vagin wrote:
> On Wed, Aug 03, 2016 at 12:48:49PM -0500, Eric W. Biederman wrote:
> > cool linux <linux.cool.hot-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> > 
> > > Hi,
> > >
> > > I have executed below script on 3.16 kernel and it took to finish almost
> > > 1.30sec to 2 minutes, where as in my older kernel(3.2.30) it took only 3
> > > secs.
> > >
> > > ================================================
> > > date
> > >
> > > for (( i=1; i <= 2000; i++ ))
> > > do
> > >  ip netns exec gmk ip link show > /dev/null
> > > done
> > >
> > > date
> > > ================================================
> > >
> > > Please guide me why this behavior in 3.16 kernel ?
> > 
> > Good question.  What happens on a modern kernel? 4.7 is the most recent
> > release, 3.16 was released two years ago.  My hunch is that you just
> > started using systemd and it has changed the defaults with all of the
> > mounts.  But shrug.  I don't recall how all of those relevant kernel
> > pieces operated two years ago.
> 

[snip]

> [ ~]# time for i in `seq 2000`; do ip netns exec gmk ip
> link show; done > /dev/null
> 
> real	0m40.129s
> user	0m1.272s
> sys	0m3.898s
> 
> Then I boot the kernel with maxcpus=1. Surprise! Surprise! It works
> fast.
> 
> [ ~]# ip netns add gmk
> [ ~]# time for i in `seq 2000`; do ip netns exec gmk ip
> link show; done > /dev/null
> 
> real	0m2.445s
> user	0m0.604s
> sys	0m1.778s

This degradations is due to synchronize_rcu() in namespace_unlock(),
which was added in 48a066e72d9 ("RCU'd vfsmounts").

Here is timings for all calls during sys_unshare():
https://gist.github.com/avagin/3811fbbb553795a78fc6ae602f86866a

> 
> 
> > 
> > Eric
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linuxfoundation.org/mailman/listinfo/containers
