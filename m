From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO Controller
Date: Thu, 12 Mar 2009 09:46:46 -0400
Message-ID: <20090312134646.GC10919@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<49B8810B.7030603@oss.ntt.co.jp>
	<d95d44a20903112340s3c77807dt465e68901747ad89@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <d95d44a20903112340s3c77807dt465e68901747ad89-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Mar 12, 2009 at 02:40:23PM +0800, anqin wrote:
> Hi Vivek,
> 
> It would be very appreciated if the patches can be based on 2.6.28.
> 

Hi Anquin,

I think most of the people want to test new patches on latest kernels
so I will keep it that way. You can backport it to previous kernels if
you really need to. For me it will become very difficult to maintain
two versions. 

Is there any reason why you can't move to latest kernels?  

Thanks
Vivek

> Thanks a lot.
> 
> Anqin
> 
> On Thu, Mar 12, 2009 at 11:27 AM, Takuya Yoshikawa
> <yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org> wrote:
> > Hi Vivek,
> >
> > Could you tell me to which kernel I can apply your patches?
> >   # latest mm?
> > I would like to test your controller.
> >
> > Thank you,
> >   Takuya Yoshikawa
> >
> >
> > Vivek Goyal wrote:
> >>
> >> Hi All,
> >>
> >> Here is another posting for IO controller patches. Last time I had posted
> >> RFC patches for an IO controller which did bio control per cgroup.
> >>
> >> http://lkml.org/lkml/2008/11/6/227
> >>
> >> One of the takeaway from the discussion in this thread was that let us
> >> implement a common layer which contains the proportional weight scheduling
> >> code which can be shared by all the IO schedulers.
> >>
> >> Implementing IO controller will not cover the devices which don't use
> >> IO schedulers but it should cover the common case.
> >>
> >> There were more discussions regarding 2 level vs 1 level IO control at
> >> following link.
> >>
> >> https://lists.linux-foundation.org/pipermail/containers/2009-January/015402.html
> >>
> >> So in the mean time we took the discussion off the list and spent time on
> >> making the 1 level control apporoach work where majority of the proportional
> >> weight control is shared by the four schedulers instead of each one having
> >> to replicate the code. We make use of BFQ code for fair queuing as posted
> >> by Paolo and Fabio here.
> >>
> >> http://lkml.org/lkml/2008/11/11/148
> >>
> >> Details about design and howto have been put in documentation patch.
> >>
> >> I have done very basic testing of running 2 or 3 "dd" threads in different
> >> cgroups. Wanted to get the patchset out for feedback/review before we dive
> >> into more bug fixing, benchmarking, optimizations etc.
> >>
> >> Your feedback/comments are welcome.
> >>
> >> Patch series contains 10 patches. It should be compilable and bootable after
> >> every patch. Intial 2 patches implement flat fair queuing (no cgroup
> >> support) and make cfq to use that. Later patches introduce hierarchical
> >> fair queuing support in elevator layer and modify other IO schdulers to use
> >> that.
> >>
> >> Thanks
> >> Vivek
> >> _______________________________________________
> >> Containers mailing list
> >> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> >> https://lists.linux-foundation.org/mailman/listinfo/containers
> >>
> >
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
> >
