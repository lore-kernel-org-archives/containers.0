From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Tue, 4 Nov 2008 13:50:04 -0800
Message-ID: <20081104135004.f1717fcf.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com>
	<20081104124753.fb1dde5a.akpm@linux-foundation.org>
	<1225831988.7803.1939.camel@twins>
	<20081104131637.68fbe055.akpm@linux-foundation.org>
	<1225833710.7803.1993.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756422AbYKDVu3@vger.kernel.org>
In-Reply-To: <1225833710.7803.1993.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: rientjes@google.com, cl@linux-foundation.org, npiggin@suse.de, menage@google.com, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Tue, 04 Nov 2008 22:21:50 +0100
Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, 2008-11-04 at 13:16 -0800, Andrew Morton wrote:
> > On Tue, 04 Nov 2008 21:53:08 +0100
> > Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > On Tue, 2008-11-04 at 12:47 -0800, Andrew Morton wrote:
> > > > On Thu, 30 Oct 2008 12:23:10 -0700 (PDT)
> > > > David Rientjes <rientjes@google.com> wrote:
> > > > 
> > > > > This is the revised cpuset writeback throttling patchset
> > > > 
> > > > I'm all confused about why this is a cpuset thing rather than a cgroups
> > > > thing.  What are the relationships here?
> > > > 
> > > > I mean, writeback throttling _should_ operate upon a control group
> > > > (more specifically: a memcg), yes?  I guess you're assuming a 1:1
> > > > relationship here?
> > > 
> > > I think the main reason is that we have per-node vmstats so the cpuset
> > > extention is relatively easy. Whereas we do not currently maintain
> > > vmstats on a cgroup level - although I imagine that could be remedied.
> > 
> > It didn't look easy to me - it added a lot more code in places which are
> > already wicked complex.
> > 
> > I'm trying to understand where this is all coming from and what fits
> > into where.  Fiddling with a cpuset's mems_allowed for purposes of
> > memory partitioning is all nasty 2007 technology, isn't it?  Does a raw
> > cpuset-based control such as this have a future?
> 
> Yes, cpusets are making a come-back on the embedded multi-core Real-Time
> side. Folks love to isolate stuff..
> 
> Not saying I really like it...
> 
> Also, there seems to be talk about node aware pdflush from the
> filesystems folks, not sure we need cpusets for that, but this does seem
> to add some node information into it.

Sorry, but I'm not seeing enough solid justification here for merging a
fairly large amount of fairly tricksy code into core kernel.  Code
which, afaict, is heading in the opposite direction from where we've
all been going for a year or two.

What are the alternatives here?  What do we need to do to make
throttling a per-memcg thing?


The patchset is badly misnamed, btw.  It doesn't throttle writeback -
in fact several people are working on IO bandwidth controllers and
calling this thing "writeback throttling" risks confusion.

What we're in fact throttling is rate-of-memory-dirtying.  The last
thing we want to throttle is writeback - we want it to go as fast as
possible!

Only I can't think of a suitable handy-dandy moniker for this concept.
