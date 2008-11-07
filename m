From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Fri, 07 Nov 2008 11:31:44 +0100
Message-ID: <1226053904.7803.5856.camel__43495.1725918383$1226054004$gmane$org@twins>
References: <20081106153022.215696930@redhat.com>
	<1225986593.7803.4688.camel@twins> <20081106160154.GA7461@redhat.com>
	<1225988173.7803.4723.camel@twins> <20081106163957.GB7461@redhat.com>
	<1225990327.7803.4776.camel@twins> <491321ED.5010103@redhat.com>
	<1225991487.7803.4801.camel@twins>  <20081107004131.GD2373@disturbed>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081107004131.GD2373@disturbed>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-11-07 at 11:41 +1100, Dave Chinner wrote:
> On Thu, Nov 06, 2008 at 06:11:27PM +0100, Peter Zijlstra wrote:
> > On Thu, 2008-11-06 at 11:57 -0500, Rik van Riel wrote:
> > > Peter Zijlstra wrote:
> > > 
> > > > The only real issue I can see is with linear volumes, but those are
> > > > stupid anyway - non of the gains but all the risks.
> > > 
> > > Linear volumes may well be the most common ones.
> > > 
> > > People start out with the filesystems at a certain size,
> > > increasing onto a second (new) disk later, when more space
> > > is required.
> > 
> > Are they aware of how risky linear volumes are? I would discourage
> > anyone from using them.
> 
> In what way are they risky?

You loose all your data when one disk dies, so your mtbf decreases with
the number of disks in your linear span.

And you get non of the benefits from having multiple disks, like extra
speed from striping, or redundancy from raid.

Therefore I say that linear volumes are the absolute worst choice.
