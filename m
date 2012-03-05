From: Lennart Poettering <mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Mon, 5 Mar 2012 12:37:30 +0100
Message-ID: <20120305113730.GC10929__33100.9230496877$1330947803$gmane$org@tango.0pointer.de>
References: <20120221211938.GE12236@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120221211938.GE12236-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 21.02.12 13:19, Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org) wrote:

> Hello, guys.

Heya,

> I've been thinking about multiple hierarchy support in cgroup for a
> while, especially after Frederic's pending task counter patchset.
> This is a write up of what I've been thinking.  I don't know what to
> do yet and simply continuing the current situation definitely is an
> option, so please read on and throw in your 20 Won (or whatever amount
> in whatever currency you want).

Sorry for responding to this thread only this late, but here are my 2
eurocents on this.

Yes, I think it would make a ton of sense simplifiying the cgroup logic
drastically. I see no need to maintain a number of entirely orthogonal
hierarchies in parallel. That said, I think that allowing some kind of
deviation from the main cgroup tree for some controlls might be a good
idea, however. More specifically, even if a task is placed in some
specific cgroup down the tree it might make sense for some controllers
to consider it in the root cgroup. e.g. since some controllers are more
expensive than others it might make sense to leave task A in
/foobar/waldo for the memory controller, but in / for the block IO
controller. But placing A in /foobar/waldo for the memory controller and
in /piep/papo makes little sense, if you understand what I mean. 

To implement something like this it might be enough to enforce a single
hierarchy only but then allow tasks to either live in the tree or live
outside the tree for a specific controller, and that's it.

> Heh, I don't know.  IIRC, last year at LinuxCon Japan, I heard
> Christoph saying that the biggest problem w/ cgroup was that it was
> building completely separate hierarchies out of the traditional
> process hierarchies.  After thinking about this stuff for a while, I
> fully agree with him.  I think this whole thing should have been a
> layer over the process tree like sessions or program groups.

Hmm, so while in general I think I agree with this sentiment, I am not
entirely sure. For example, on systemd systems we currently set up one
cgroup per user (/user/lennart/), and in that cgroup a cgroup per
session (/user/lennart/4711/). This implies that when the same user logs
in twice his processes will be placed beneath the same parent cgroup
(/user/lennart/), which I kinda read would be conflicting with what you
suggest, no?

>    This path would require the most amount of work and we would be
>    excluding a feature - support for multiple orthogonal
>    categorizations - which has been available till now, probably
>    through deprecation process spanning years; however, this at least
>    gives us hope that we may reach sanity in the end, how distant that
>    end may be.  Oh, hope. :)
> 
> So, I mean, I don't know.  What do other people think?  Is this a
> unnecessary worry?  Are people generally happy with the way things
> are?  Lennart, Kay, what do you guys think?

A clean-up like you suggest as 3, is something we'd be happy to
support. I am happy to make any change necessary to adapt systemd to
whatever makes sense in the kernel. To me the current flexibility of the
cgroup interface appears way over-the-top, and a much simpler design
would suffice too and be more understandable to the user. (starting from
the fact that ps output currently looks really awful, since it lists
cgroup membership for all hierarchies, which just looks crazy)

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
