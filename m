From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] [PATCH] Re: Prefixing cgroup generic control filenames
 with "cgroup."
Date: Fri, 29 Feb 2008 13:20:57 -0600
Message-ID: <20080229132057.bc1be568.pj@sgi.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
	<20080228132142.4d4b1eef.akpm@linux-foundation.org>
	<6599ad830802281328q162d0585v3ac6b45a119a4a05@mail.gmail.com>
	<20080228134027.05b2aa87.akpm@linux-foundation.org>
	<6599ad830802281406t38e486d8g267df1873bc754c2@mail.gmail.com>
	<20080228142100.2dce0e46.akpm@linux-foundation.org>
	<47C79F39.5080005@google.com>
	<20080229002051.86de45a5.pj@sgi.com>
	<6599ad830802290134u4cdfba44v39fd725b5c422720@mail.gmail.com>
	<20080229093013.1e136398.pj@sgi.com>
	<6599ad830802290959h5a736820i591ced2813f3014f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932649AbYB2TVZ@vger.kernel.org>
In-Reply-To: <6599ad830802290959h5a736820i591ced2813f3014f@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, xemul@openvz.org
List-Id: containers.vger.kernel.org

> >   2) "[a-z]+\.[a-z]+(_[a-z]+)*"
> 
> Why make it more complex?

It's a trade-off, between how many names the pattern covers,
and how complicated it is.  I don't really have a preference
between "[a-z].*", "[a-z]+\.[a-z_]+", or other variants.

This sort of namespace partitioning is common in other venues,
such as one or two leading underscores in various C or Python
names having particular 'system' uses.

Perhaps 90% of users who ever are in a position to construct
a name in the cgroup namespace won't worry much about this one
way or the other.  For them, the strlen() of the regex pattern
describing future possible kernel generated cgroup names won't
matter.  A few such constructors of cgroup names will appreciate
the precision of whatever rule you create.

> The main reason it's not my primary choice is that it's an implicit
> rule that the user has to know about or risk getting bitten in future.

Ok - as I suspected.

Note again, you can't keep the user from getting bitten.  You can
only avoid being one of the biters.

From the users perspective, since you can't actually eliminate the
risk of them ever seeing a collision, any complexity that you impose
on their code risks being viewed as your taxing them more for your
benefit (avoiding any blame to you) than for their benefit (actually
avoiding all collision risk, which we can't practically do.)

All name spaces co-operatively maintained in the commons have this
risk of collision.

As such name spaces go, the cgroup name space is easy.  It's a
small world.  A few simple lexical conventions should suffice.

I'd suggest something like you promise to stay in the "[a-z]+\.[a-z_]+"
space, where the leading "[a-z]+" prefix is "cgroup" or one of a
modest, slowly growing, set of cgroup subsystems, plus the existing
grand-fathered names.  Nothing here keeps others from intruding in
that same space; you would just be promising not to go outside of
that space.

Self-imposed restraint like this "sells" better. The vast majority can
just pay no mind; the small minority that care will appreciate that
you're imposing constraints on yourself (on cgroup kernel code) that
make their lives a little safer (one less chance of name collision)
without imposing any additional constraints on what they can do or
complexity for which they must inescapably code.

Such restraint is similar to what I see the major users of the similar
cpuset name space doing.  They each pick a distinct branding prefix
with which to start the names they add below /dev/cpuset.  They do so
without even a suggestion from myself, and without any consultation
amongst themselves; just seems a convenient and sensible thing to do.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214
