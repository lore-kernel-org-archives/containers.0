From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Tue, 24 Mar 2009 14:29:06 -0400
Message-ID: <20090324182906.GF21389@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312100054.GA8024@linux.vnet.ibm.com>
	<20090312140450.GE10919@redhat.com>
	<49C0A171.8060009@cn.fujitsu.com>
	<20090318215529.GA3338@redhat.com>
	<e98e18940903232232i432f62c5r9dfd74268e1b2684@mail.gmail.com>
	<20090324125842.GA21389@redhat.com>
	<e98e18940903241114u1e03ae7dhf654d7d8d0fc0302@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e98e18940903241114u1e03ae7dhf654d7d8d0fc0302-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Mar 24, 2009 at 11:14:13AM -0700, Nauman Rafique wrote:
> On Tue, Mar 24, 2009 at 5:58 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Mon, Mar 23, 2009 at 10:32:41PM -0700, Nauman Rafique wrote:
> >
> > [..]
> >> > DESC
> >> > io-controller: idle for sometime on sync queue before expiring it
> >> > EDESC
> >> >
> >> > o When a sync queue expires, in many cases it might be empty and then
> >> > =E1it will be deleted from the active tree. This will lead to a scen=
ario
> >> > =E1where out of two competing queues, only one is on the tree and wh=
en a
> >> > =E1new queue is selected, vtime jump takes place and we don't see se=
rvices
> >> > =E1provided in proportion to weight.
> >> >
> >> > o In general this is a fundamental problem with fairness of sync que=
ues
> >> > =E1where queues are not continuously backlogged. Looks like idling is
> >> > =E1only solution to make sure such kind of queues can get some decen=
t amount
> >> > =E1of disk bandwidth in the face of competion from continusouly back=
logged
> >> > =E1queues. But excessive idling has potential to reduce performance =
on SSD
> >> > =E1and disks with commnad queuing.
> >> >
> >> > o This patch experiments with waiting for next request to come befor=
e a
> >> > =E1queue is expired after it has consumed its time slice. This can e=
nsure
> >> > =E1more accurate fairness numbers in some cases.
> >>
> >> Vivek, have you introduced this option just to play with it, or you
> >> are planning to make it a part of the patch set. Waiting for a new
> >> request to come before expiring time slice sounds problematic.
> >
> > Why are the issues you forsee with it. This is just an extra 8ms idling
> > on the sync queue that is also if think time of the queue is not high.
> >
> > We already do idling on sync queues. In this case we are doing an extra
> > idle even if queue has consumed its allocated quota. It helps me get
> > fairness numbers and I have put it under a tunable "fairness". So by
> > default this code will not kick in.
> >
> > Other possible option could be that when expiring a sync queue, don't
> > remove the queue immediately from the tree and remove it later if there
> > is no request from the queue in 8ms or so. I am not sure with BFQ, is it
> > feasible to do that without creating issues with current implementation.
> > Current implementation was simple, so I stick to it to begin with.
> =

> If the maximum wait is bounded by 8ms, then it should be fine. The
> comments on the patch did not talk about such limit; it sounded like
> unbounded wait to me.
> =

> Does keeping the sync queue in ready tree solves the problem too? Is
> it because it avoid a virtual time jump?
> =


I have not tried the second approch yet. But that also should solve the
vtime jump issue.

Thanks
Vivek
