From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Mon, 28 Sep 2009 13:14:20 -0400
Message-ID: <20090928171420.GA3643__16.9862913482532$1254158232$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<4ABC28DE.7050809@datenparkplatz.de>
	<20090925202636.GC15007@redhat.com>
	<4e5e476b0909271000u69d79346s27cccad219e49902@mail.gmail.com>
	<20090928145655.GB8192@redhat.com>
	<4e5e476b0909280835w3410d58aod93a29d1dcda8909@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4e5e476b0909280835w3410d58aod93a29d1dcda8909-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Corrado Zoccolo <czoccolo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Sep 28, 2009 at 05:35:02PM +0200, Corrado Zoccolo wrote:
> On Mon, Sep 28, 2009 at 4:56 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Sun, Sep 27, 2009 at 07:00:08PM +0200, Corrado Zoccolo wrote:
> >> Hi Vivek,
> >> On Fri, Sep 25, 2009 at 10:26 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrot=
e:
> >> > On Fri, Sep 25, 2009 at 04:20:14AM +0200, Ulrich Lukas wrote:
> >> >> Vivek Goyal wrote:
> >> >> > Notes:
> >> >> > - With vanilla CFQ, random writers can overwhelm a random reader.
> >> >> > =A0 Bring down its throughput and bump up latencies significantly.
> >> >>
> >> >>
> >> >> IIRC, with vanilla CFQ, sequential writing can overwhelm random rea=
ders,
> >> >> too.
> >> >>
> >> >> I'm basing this assumption on the observations I made on both OpenS=
use
> >> >> 11.1 and Ubuntu 9.10 alpha6 which I described in my posting on LKML
> >> >> titled: "Poor desktop responsiveness with background I/O-operations=
" of
> >> >> 2009-09-20.
> >> >> (Message ID: 4AB59CBB.8090907-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org)
> >> >>
> >> >>
> >> >> Thus, I'm posting this to show that your work is greatly appreciate=
d,
> >> >> given the rather disappointig status quo of Linux's fairness when it
> >> >> comes to disk IO time.
> >> >>
> >> >> I hope that your efforts lead to a change in performance of current
> >> >> userland applications, the sooner, the better.
> >> >>
> >> > [Please don't remove people from original CC list. I am putting them=
 back.]
> >> >
> >> > Hi Ulrich,
> >> >
> >> > I quicky went through that mail thread and I tried following on my
> >> > desktop.
> >> >
> >> > ##########################################
> >> > dd if=3D/home/vgoyal/4G-file of=3D/dev/null &
> >> > sleep 5
> >> > time firefox
> >> > # close firefox once gui pops up.
> >> > ##########################################
> >> >
> >> > It was taking close to 1 minute 30 seconds to launch firefox and dd =
got
> >> > following.
> >> >
> >> > 4294967296 bytes (4.3 GB) copied, 100.602 s, 42.7 MB/s
> >> >
> >> > (Results do vary across runs, especially if system is booted fresh. =
Don't
> >> > =A0know why...).
> >> >
> >> >
> >> > Then I tried putting both the applications in separate groups and as=
sign
> >> > them weights 200 each.
> >> >
> >> > ##########################################
> >> > dd if=3D/home/vgoyal/4G-file of=3D/dev/null &
> >> > echo $! > /cgroup/io/test1/tasks
> >> > sleep 5
> >> > echo $$ > /cgroup/io/test2/tasks
> >> > time firefox
> >> > # close firefox once gui pops up.
> >> > ##########################################
> >> >
> >> > Now I firefox pops up in 27 seconds. So it cut down the time by 2/3.
> >> >
> >> > 4294967296 bytes (4.3 GB) copied, 84.6138 s, 50.8 MB/s
> >> >
> >> > Notice that throughput of dd also improved.
> >> >
> >> > I ran the block trace and noticed in many a cases firefox threads
> >> > immediately preempted the "dd". Probably because it was a file system
> >> > request. So in this case latency will arise from seek time.
> >> >
> >> > In some other cases, threads had to wait for up to 100ms because dd =
was
> >> > not preempted. In this case latency will arise both from waiting on =
queue
> >> > as well as seek time.
> >>
> >> I think cfq should already be doing something similar, i.e. giving
> >> 100ms slices to firefox, that alternate with dd, unless:
> >> * firefox is too seeky (in this case, the idle window will be too smal=
l)
> >> * firefox has too much think time.
> >>
> >
> Hi Vivek,
> > Hi Corrado,
> >
> > "firefox" is the shell script to setup the environment and launch the
> > broser. It seems to be a group of threads. Some of them run in parallel
> > and some of these seems to be running one after the other (once previous
> > process or threads finished).
> =

> Ok.
> =

> >
> >> To rule out the first case, what happens if you run the test with your
> >> "fairness for seeky processes" patch?
> >
> > I applied that patch and it helps a lot.
> >
> > http://lwn.net/Articles/341032/
> >
> > With above patchset applied, and fairness=3D1, firefox pops up in 27-28=
 seconds.
> =

> Great.
> Can you try the attached patch (on top of 2.6.31)?
> It implements the alternative approach we discussed privately in july,
> and it addresses the possible latency increase that could happen with
> your patch.
> =

> To summarize for everyone, we separate sync sequential queues, sync
> seeky queues and async queues in three separate RR strucutres, and
> alternate servicing requests between them.
> =

> When servicing seeky queues (the ones that are usually penalized by
> cfq, for which no fairness is usually provided), we do not idle
> between them, but we do idle for the last queue (the idle can be
> exited when any seeky queue has requests). This allows us to allocate
> disk time globally for all seeky processes, and to reduce seeky
> processes latencies.
> =


Ok, I seem to be doing same thing at group level (In group scheduling
patches). I do not idle on individual sync seeky queues but if this is
last queue in the group, then I do idle to make sure group does not loose
its fair share and exit from idle the moment there is any busy queue in
the group.

So you seem to be grouping all the sync seeky queues system wide in a =

single group. So all the sync seeky queues collectively get 100ms in a
single round of dispatch? I am wondering what happens if there are lot
of such sync seeky queues this 100ms time slice is consumed before all the
sync seeky queues got a chance to dispatch. Does that mean that some of
the queues can completely skip the one dispatch round?

Thanks
Vivek

> I tested with 'konsole -e exit', while doing a sequential write with
> dd, and the start up time reduced from 37s to 7s, on an old laptop
> disk.
> =

> Thanks,
> Corrado
> =

> >
> >> To rule out the first case, what happens if you run the test with your
> >> "fairness for seeky processes" patch?
> >
> > I applied that patch and it helps a lot.
> >
> > http://lwn.net/Articles/341032/
> >
> > With above patchset applied, and fairness=3D1, firefox pops up in 27-28
> > seconds.
> >
> > So it looks like if we don't disable idle window for seeky processes on
> > hardware supporting command queuing, it helps in this particular case.
> >
> > Thanks
> > Vivek
> >
