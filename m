From: James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Thu, 28 Jul 2011 08:37:59 +0000
Message-ID: <1311842275.30253.27.camel@mulgrave>
References: <4E204466.8010204@parallels.com>
	<20110723002558.GE16940@count0.beaverton.ibm.com>
	<20110723051005.GE21089@mtj.dyndns.org>
	<20110726220215.GE14808@count0.beaverton.ibm.com>
	<20110726222109.GB28497@mtj.dyndns.org>
	<20110727000651.GA15501@count0.beaverton.ibm.com>
	<20110727120114.GZ2622@htj.dyndns.org>
	<20110727213510.GC15501@count0.beaverton.ibm.com>
	<20110728072141.GB2622@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110728072141.GB2622-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
Content-Language: en-US
Content-ID: <3B234AE17038294E9AE0BE990C026359-ruSsrxOD6xDby3iVrkZq2A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Lars Marowsky-Bree <lmb-l3A5Bk7waGM@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2011-07-28 at 09:21 +0200, Tejun Heo wrote:
> Hello, Matt.
> 
> On Wed, Jul 27, 2011 at 02:35:10PM -0700, Matt Helsley wrote:
> > The closest part of your analogy involved the networking code
> > and made me wonder how you think network sockets and connections
> > could best be checkpointed and restarted from userspace.
> 
> My knowledge of the networking stack is rather basic so it probably
> would require more research to be complete enough but I have something
> on mind.  I'll try to hack up an example code (and many combine it
> with the parasite so that it can hijack a socket) this weekend (or
> next week :)

So, this is actually a good example of why we don't want this
specifically bound to C/R in the kernel.  I think an individual network
socket can be checkpointed and restored separately specifically by
exporting some of its internal state (basically the current sequence
number and some of the window state).

The benefit to us of finding what this state is and making it available
is not only that we can now save and restore the socket as part of the
checkpoint, its that the High Availability people can use this feature
for individual sockets to build fault tolerant network service failover
on top of.  Thus by making the feature granular and available to
userspace, we've expanded the number of use cases (and hence the amount
of testing) we get for the feature.

James
