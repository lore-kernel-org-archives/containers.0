From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] IO scheduler based IO controller V6
Date: Wed, 8 Jul 2009 20:09:25 +0530
Message-ID: <20090708143925.GE3215__42766.5933887058$1247064026$gmane$org@balbir.in.ibm.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<20090708035621.GB3215@balbir.in.ibm.com>
	<20090708134114.GA24048@redhat.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090708134114.GA24048-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

* Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2009-07-08 09:41:14]:

> On Wed, Jul 08, 2009 at 09:26:21AM +0530, Balbir Singh wrote:
> > * Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2009-07-02 16:01:32]:
> > 
> > > 
> > > Hi All,
> > > 
> > > Here is the V6 of the IO controller patches generated on top of 2.6.31-rc1.
> > > 
> > > Previous versions of the patches was posted here.
> > > 
> > > (V1) http://lkml.org/lkml/2009/3/11/486
> > > (V2) http://lkml.org/lkml/2009/5/5/275
> > > (V3) http://lkml.org/lkml/2009/5/26/472
> > > (V4) http://lkml.org/lkml/2009/6/8/580
> > > (V5) http://lkml.org/lkml/2009/6/19/279
> > > 
> > > This patchset is still work in progress but I want to keep on getting the
> > > snapshot of my tree out at regular intervals to get the feedback hence V6.
> > >
> > 
> > Hi, Vivek,
> > 
> > I was able to compile and boot a 2.6.31-rc1 kernel with this patchset.
> > I have a request could you fold up all patches and make one
> > consolidated patch available somewhere (makes it easier to test), may
> > be a git tree?
> > 
> 
> Thanks for trying it out balbir. Ok, for ease of patching and testing, I 
> will also maintain a consolidated patch. For V6 you can download the patch
> from here.
> 
> http://people.redhat.com/~vgoyal/io-controller/io-scheduler-based-io-controller-v6.patch
>

Thanks, this will definitely help me get more testing done!
 
> > I did some quick tests with some io benchmarks and found in a simple
> > scenario that the scheduler worked as expected, except that it took
> > very long. I'll investigate further and revert back.
> 
> Thanks. I will wait for details.
>

I'll try and send something out by Friday, but for now I am not even
very sure if it is a real problem. I ran iozone on two groups with 500
and 1000 as weights on the same parition and set fairness to 1 in
sysfs for the partition. I used a record size of 4 (default) and tried
to run it on a file size of 1G.

BTW, I don't see anything about weights being multiple of an expected
figure documented anywhere. I tried weights of 1024 (similar to the
scheduler and got shouted back at :) ). Does the documentation patch
specify the expected range for weights? 

-- 
	Balbir
