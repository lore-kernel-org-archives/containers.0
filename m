From: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Fri, 23 Jan 2009 02:25:32 +0300
Message-ID: <20090122232532.GA5656__44521.717952057$1232666983$gmane$org@ioremap.net>
References: <alpine.DEB.2.00.0901220156310.1738@chino.kir.corp.google.com>
	<20090122101424.GA12317@ioremap.net>
	<alpine.DEB.2.00.0901220218120.2851@chino.kir.corp.google.com>
	<20090122132133.GA17524@ioremap.net>
	<alpine.DEB.2.00.0901221216330.2085@chino.kir.corp.google.com>
	<20090122210613.GA10158@ioremap.net>
	<alpine.DEB.2.00.0901221314010.6145@chino.kir.corp.google.com>
	<20090122220446.GA1651@ioremap.net>
	<alpine.DEB.2.00.0901221415050.10427@chino.kir.corp.google.com>
	<20090122225304.GA3551@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090122225304.GA3551-i6C2adt8DTjR7s880joybQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jan 23, 2009 at 01:53:04AM +0300, Evgeniy Polyakov (zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org) wrote:
> > I'm quite certain you've spent more time writing emails to me than merging 
> > the patch and testing its possibilities, given your lack of understanding 
> > of its very basic concepts.
> 
> How cute :)
> Any other technical arguments of the same strength?

Its my turn now for the professional statements, let's start with this
technical side: you wanted to send a signal for the process to be killed,
but this will need
1. to allocate a signal, which will deadlock
2. no need to do this for sigill, but it will not work if process is in
unkillable state, while oom-killer clears iirc

Now to the oom-handler: if it will want to free some memory, it will
have to call a syscall with some pointer, which in turn may be in the
swapped area, so handler will be locked.

-- 
	Evgeniy Polyakov
