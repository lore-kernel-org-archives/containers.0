From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Mon, 12 Mar 2012 17:37:07 -0500
Message-ID: <20120312223707.GA8272__8820.37689812041$1331591854$gmane$org@peqn>
References: <20120221211938.GE12236@google.com>
	<20120312221050.GG23255@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120312221050.GG23255-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> Hello, guys.
> 
> Thanks a lot for the discussion and here are my take aways:
> 
> * At least to me, nobody seems to have strong enough justification for
>   orthogonal multiple hierarchies, so, yeah, unless something else

First off, can you (sorry) show an example of exactly what would no
longer be supported?  Is this the ability to not separately mount
freezer and cpusets (for instance)?

I've submitted a topic for the upcoming linux foundation end user summit
in new york, to get feedback from end users.  (Frankly I don't want to go
so would love if someone else wanted to do this :).  I think it'd be nice
to wait and see if this gets accepted, and see whether any end users are
relying on this.

(IMO it's wrong to say that "if you are using a current feature, you'd
better be reading lkml so you can speak up lest that feature might get
removed.")

>   happens, I'm scheduling multiple hierarchy support for the chopping
>   block.  This is a long term thing (think years), so no need to panic
>   right now and as is life plans may change and fail to materialize,
>   but I intend to at least move away from it.
> 
> * Several people pointed out that it would be inconvenient to require
>   cgroup hierarchy to be a strict super-imposed tree on top of process
>   tree and that program groups / sessions aren't like that either.  I
>   agree, so it will hopefully be single hierarchy which more or less
>   behaves the same as the current hierarchy.
> 
> * How to map controllers which aren't aware of full hierarchy is still
>   an open question but I'm still standing by one active node on any
>   root-to-leaf path w/ root group serving as the special rest group.
> 
>   This should happen first for the long migration to begin.  I might
>   get to it someday but if anyone can beat me to it, please go ahead.
>   I'll be ecstatic to review and merge the patches.
> 
> Also, I'll slowly be marking features which don't seem essential,
> especially the convenience features for multiple hierarchies, as
> deprecated and eventually chop them.
> 
> Thank you.
> 
> -- 
> tejun
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
