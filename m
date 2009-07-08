From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO scheduler based IO controller V6
Date: Wed, 8 Jul 2009 09:41:14 -0400
Message-ID: <20090708134114.GA24048__2089.5698377446$1247060581$gmane$org@redhat.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<20090708035621.GB3215@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090708035621.GB3215-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 08, 2009 at 09:26:21AM +0530, Balbir Singh wrote:
> * Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2009-07-02 16:01:32]:
> 
> > 
> > Hi All,
> > 
> > Here is the V6 of the IO controller patches generated on top of 2.6.31-rc1.
> > 
> > Previous versions of the patches was posted here.
> > 
> > (V1) http://lkml.org/lkml/2009/3/11/486
> > (V2) http://lkml.org/lkml/2009/5/5/275
> > (V3) http://lkml.org/lkml/2009/5/26/472
> > (V4) http://lkml.org/lkml/2009/6/8/580
> > (V5) http://lkml.org/lkml/2009/6/19/279
> > 
> > This patchset is still work in progress but I want to keep on getting the
> > snapshot of my tree out at regular intervals to get the feedback hence V6.
> >
> 
> Hi, Vivek,
> 
> I was able to compile and boot a 2.6.31-rc1 kernel with this patchset.
> I have a request could you fold up all patches and make one
> consolidated patch available somewhere (makes it easier to test), may
> be a git tree?
> 

Thanks for trying it out balbir. Ok, for ease of patching and testing, I 
will also maintain a consolidated patch. For V6 you can download the patch
from here.

http://people.redhat.com/~vgoyal/io-controller/io-scheduler-based-io-controller-v6.patch

> I did some quick tests with some io benchmarks and found in a simple
> scenario that the scheduler worked as expected, except that it took
> very long. I'll investigate further and revert back.

Thanks. I will wait for details.

Vivek
