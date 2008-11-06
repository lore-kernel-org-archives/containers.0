From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Thu, 6 Nov 2008 11:01:54 -0500
Message-ID: <20081106160154.GA7461__3763.69179361991$1225988450$gmane$org@redhat.com>
References: <20081106153022.215696930@redhat.com>
	<1225986593.7803.4688.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1225986593.7803.4688.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Nov 06, 2008 at 04:49:53PM +0100, Peter Zijlstra wrote:
> On Thu, 2008-11-06 at 10:30 -0500, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org wrote:
> > Hi,
> > 
> > If you are not already tired of so many io controller implementations, here
> > is another one.
> > 
> > This is a very eary very crude implementation to get early feedback to see
> > if this approach makes any sense or not.
> > 
> > This controller is a proportional weight IO controller primarily
> > based on/inspired by dm-ioband. One of the things I personally found little
> > odd about dm-ioband was need of a dm-ioband device for every device we want
> > to control.  I thought that probably we can make this control per request
> > queue and get rid of device mapper driver. This should make configuration
> > aspect easy.
> > 
> > I have picked up quite some amount of code from dm-ioband especially for
> > biocgroup implementation.
> > 
> > I have done very basic testing and that is running 2-3 dd commands in different
> > cgroups on x86_64. Wanted to throw out the code early to get some feedback.
> > 
> > More details about the design and how to are in documentation patch.
> > 
> > Your comments are welcome.
> 
> please include
> 
> QUILT_REFRESH_ARGS="--diffstat --strip-trailing-whitespace"
> 
> in your environment or .quiltrc
> 

Sure, I will do. First time user of quilt. :-)

> I would expect all those bio* files to be placed in block/ not mm/
> 

Thinking more about it, probably block/ will be more appropriate place.
I will do that.

> Does this still require I use dm, or does it also work on regular block
> devices? Patch 4/4 isn't quite clear on this.

No. You don't have to use dm. It will simply work on regular devices. We
shall have to put few lines of code for it to work on devices which don't
make use of standard __make_request() function and provide their own
make_request function. 

Hence for example, I have put that few lines of code so that it can work
with dm device. I shall have to do something similar for md too.

Though, I am not very sure why do I need to do IO control on higher level
devices. Will it be sufficient if we just control only bottom most
physical block devices?

Anyway, this approach should work at any level.

Thanks
Vivek
