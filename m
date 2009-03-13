From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: Ensuring c/r maintainability (WAS Re: [RFC][PATCH 00/11] track
	files for checkpointability)
Date: Fri, 13 Mar 2009 12:53:01 -0500
Message-ID: <20090313175301.GA13050@us.ibm.com>
References: <20090305210840.GA2499@x200.localdomain> <1236288427.22399.122.camel@nimitz> <20090305220044.GA2819@x200.localdomain> <1236352121.5732.80.camel@bahia> <20090306153549.GA898@us.ibm.com> <49B15F35.2010909@free.fr> <20090306183055.GA6729@us.ibm.com> <49B76D91.1020807@free.fr> <20090312153048.GA11147@hallyn.com> <20090313063611.GH7561@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753672AbZCMRxW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090313063611.GH7561@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Serge Hallyn <serue@linux.vnet.ibm.com>, Containers <containers@lists.osdl.org>, LKML <linux-kernel@vger.kernel.org>, Oren Laadan <orenl@cs.columbia.edu>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Christoph Hellwig <hch@infradead.org>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc@us.ibm.com):
> On Thu, Mar 12, 2009 at 10:30:48AM -0500, Serge E. Hallyn wrote:
> > Quoting Cedric Le Goater (legoater@free.fr):
> > > >> And if Ingo's requirement is fulfilled, would any C/R patchset be acceptable ?
> > > > 
> > > > Yup, no matter how hideous  :)  Ok not really.
> > > > 
> > > > But the point was that it wasn't Dave not understanding Alexey's
> > > > suggestion, but Greg not understanding Ingo's.  If you think Ingo's
> > > > goal isn't worthwhile or achievable, then argue that (as I am), don't
> > > > keep elaborating on something we all agree will be needed (Alexey's
> > > > suggestion or some other way of doing a true may-be-checkpointed test).
> > > 
> > > I rather spend my time on enabling things rather than forbid them. 
> > 
> > That sure sounds productive.  How could I argue with that.
> > 
> > But wait, haven't several teams been doing that for years?  So why is
> > c/r not in the upstream kernel?  Could it be that ignoring the
> > upstream maintainers' concerns about (a) treating the feature as a
> > toy, (b) long-term maintainability, and (c) c/r becoming an impediment
> > to future features, and instead hacking away at our toy feature, is
> > *not* always the best course?
> 
> I've been thinking about how we could make checkpoint/restart (c/r) more
> maintainable in the long-term. I've only come up with two ideas:
> 
> I. Implement sparse-like __cr struct annotations for some compile-time checking.
> 
> First we annotate structures which c/r needs to save. For example we might have:
> 
> 	struct mm_struct {
> 		__cr struct vm_area_struct * mmap;
> 		struct rb_root mm_rb;
> 		struct vm_area_struct *mmap_cache;
> 		...
> 		__cr unsigned long mmap_base;
> 		__cr unsigned long task_size;
> 		..
> 	};
> 
> The __cr annotations indicate fields of the mm_struct which must be
> saved during checkpoint restart. In fact, for non-pointer fields these
> annotations would be sufficient to generate c/r code.
> 
> Next we would need a __cr_root annotation. These mark structures which
> the c/r code visits that determine the scope of c/r. If there is no path from a
> __cr annotation to a __cr_root annotation then we would conclude that c/r of
> this struct is broken. These path constraint checks could be done at compile
> time.

Hi Matt,

is what you're detecting here really something we're worried about?

Maybe that's something we should be doing - coming up with a list of
the things we are trying to detect or prevent.  I can only think of
a few offhand:

1. checkpoint (and restart) a task which has used a resource which we
do cannot (yet, or ever) safely checkpoint/restart.

2. kernel has a new feature for which we have not considered
checkpoint/restart.  Not only is it not safe to c/r a task using it,
but we haven't even implemented a check for tasks using it.

3. Some new kernel feature has an attribute which simply must be
stored away.  An example would be the vdso_base in s390 as of
recent 2.6.29 rc's, which was not present in 2.6.28.  So there are
two things to worry about in this one:

	a. detect that this happened and handle it, so c/r continues
	   to work.
	b. figure out a way to restart an older c/r image on a newer
	   kernel - or simply detect older images and call them
	   incompatible.

-serge
