From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 2 Oct 2009 18:27:56 -0400
Message-ID: <20091002222756.GG4494__42021.6299863116$1254522551$gmane$org@redhat.com>
References: <200910021255.27689.czoccolo@gmail.com>
	<20091002124921.GA4494@redhat.com>
	<4e5e476b0910020827s23e827b1n847c64e355999d4a@mail.gmail.com>
	<1254497520.10392.11.camel@marge.simson.net>
	<20091002154020.GC4494@redhat.com>
	<12774.1254502217@turing-police.cc.vt.edu>
	<20091002195815.GE4494@redhat.com>
	<4e5e476b0910021514i1b461229t667bed94fd67f140@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4e5e476b0910021514i1b461229t667bed94fd67f140-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Oct 03, 2009 at 12:14:28AM +0200, Corrado Zoccolo wrote:
> On Fri, Oct 2, 2009 at 9:58 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Fri, Oct 02, 2009 at 12:50:17PM -0400, Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org wrote:
> >> On Fri, 02 Oct 2009 11:40:20 EDT, Vivek Goyal said:
> >>
> >> Umm... I got petabytes of hardware RAID across the hall that very defi=
nitely
> >> *is* rotating. =A0Did you mean "SSD and disk systems with big honking =
caches
> >> that cover up the rotation"? =A0Because "RAID" and "big honking caches=
" are
> >> not *quite* the same thing, and I can just see that corner case coming=
 out
> >> to bite somebody on the ass...
> >>
> >
> > I guess both. The systems which have big caches and cover up for rotati=
on,
> > we probably need not idle for seeky process. An in case of big hardware
> > RAID, having multiple rotating disks, instead of idling and keeping rest
> > of the disks free, we probably are better off dispatching requests from
> > next queue (hoping it is going to a different disk altogether).
> =

> In fact I think that the 'rotating' flag name is misleading.
> All the checks we are doing are actually checking if the device truly
> supports multiple parallel operations, and this feature is shared by
> hardware raids and NCQ enabled SSDs, but not by cheap SSDs or single
> NCQ-enabled SATA disk.
> =


While we are at it, what happens to notion of priority of tasks on SSDs?
Without idling there is not continuous time slice and there is no
fairness. So ioprio is out of the window for SSDs?

On SSDs, will it make more sense to provide fairness in terms of number or
IO or size of IO and not in terms of time slices.

Thanks
Vivek

> If we really wanted a "seek is cheap" flag, we could measure seek time
> in the io-scheduler itself, but in the current code base we don't have
> it used in this meaning anywhere.
> =

> Thanks,
> Corrado
> =

> >
> > Thanks
> > Vivek
> >
> =

> =

> =

> -- =

> __________________________________________________________________________
> =

> dott. Corrado Zoccolo                          mailto:czoccolo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> PhD - Department of Computer Science - University of Pisa, Italy
> --------------------------------------------------------------------------
> The self-confidence of a warrior is not the self-confidence of the average
> man. The average man seeks certainty in the eyes of the onlooker and calls
> that self-confidence. The warrior seeks impeccability in his own eyes and
> calls that humbleness.
>                                Tales of Power - C. Castaneda
