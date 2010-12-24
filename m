From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Fri, 24 Dec 2010 18:09:01 -0500
Message-ID: <20101224230901.GA30136@ghc17.ghc.andrew.cmu.edu>
References: <AANLkTim7HW0wNyqOPePFXmEMV8hx_fMKNMTAsSwkRzZX@mail.gmail.com>
	<AANLkTin7aK5uEFi0U+iU_9=cbfRTHfDzKsbWupn73fSL@mail.gmail.com>
	<20101216002603.6741874a.akpm@linux-foundation.org>
	<20101224033352.GA7804@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012240245040.775@chino.kir.corp.google.com>
	<20101224114500.GA18036@ghc17.ghc.andrew.cmu.edu>
	<20101224035331.b907b410.akpm@linux-foundation.org>
	<20101224120853.GA18518@ghc17.ghc.andrew.cmu.edu>
	<20101224212452.GA27275@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012241333010.13509@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012241333010.13509-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 24, 2010 at 01:34:06PM -0800, David Rientjes wrote:
> On Fri, 24 Dec 2010, Ben Blum wrote:
> 
> > Oh, also, most (not all) times that NODEMASK_ALLOC is used in cpusets,
> > cgroup_mutex is also held. So how about just using static storage for
> > them? (There could be a new macro "NODEMASK_ALLOC_STATIC", for use when
> > the caller can never race against itself.) As long as the call-graph
> > isn't recursive, there shouldn't be a problem...
> > 
> 
> Yes, that sounds good but I'd suggest using it only when dynamic 
> allocation cannot be done with GFP_KERNEL to avoid the waste.

I'll add a patch to my current series to do this. Should I leave alone
the other cases where an out-of-memory causes a silent failure?
(cpuset_change_nodemask, scan_for_empty_cpusets)

-- Ben
