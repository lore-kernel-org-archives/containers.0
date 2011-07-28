From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Thu, 28 Jul 2011 11:10:46 +0200
Message-ID: <20110728091046.GE2622@htj.dyndns.org>
References: <4E204466.8010204@parallels.com>
	<20110723002558.GE16940@count0.beaverton.ibm.com>
	<20110723051005.GE21089@mtj.dyndns.org>
	<20110726220215.GE14808@count0.beaverton.ibm.com>
	<20110726222109.GB28497@mtj.dyndns.org>
	<20110727000651.GA15501@count0.beaverton.ibm.com>
	<20110727120114.GZ2622@htj.dyndns.org>
	<20110727213510.GC15501@count0.beaverton.ibm.com>
	<20110728072141.GB2622@htj.dyndns.org>
	<1311842275.30253.27.camel@mulgrave>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1311842275.30253.27.camel@mulgrave>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Lars Marowsky-Bree <lmb-l3A5Bk7waGM@public.gmane.org>
List-Id: containers.vger.kernel.org

Hey, James.  Nice to see you w/ parallels hat on.

On Thu, Jul 28, 2011 at 08:37:59AM +0000, James Bottomley wrote:
> So, this is actually a good example of why we don't want this
> specifically bound to C/R in the kernel.  I think an individual network
> socket can be checkpointed and restored separately specifically by
> exporting some of its internal state (basically the current sequence
> number and some of the window state).

I actually think network socket would be a pretty well behaving
candidate for userland CR.  Its behavior and interaction are strictly
defined.  The thing is designed to talk to other machines after all so
we basically already have well documented and enforced mechanism to
coerce it.  We need some bits and pieces but I'm expecting kernel side
of it to be very small.

> The benefit to us of finding what this state is and making it available
> is not only that we can now save and restore the socket as part of the
> checkpoint, its that the High Availability people can use this feature
> for individual sockets to build fault tolerant network service failover
> on top of.  Thus by making the feature granular and available to
> userspace, we've expanded the number of use cases (and hence the amount
> of testing) we get for the feature.

Yeah, exactly, and that in turn makes it easy to push the feature into
the kernel.

Thanks.

-- 
tejun
