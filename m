From: Matt Helsley <matthltc@us.ibm.com>
Subject: Ensuring c/r maintainability (WAS Re: [RFC][PATCH 00/11] track
	files for checkpointability)
Date: Thu, 12 Mar 2009 23:36:11 -0700
Message-ID: <20090313063611.GH7561@us.ibm.com>
References: <1236280567.22399.99.camel@nimitz> <20090305210840.GA2499@x200.localdomain> <1236288427.22399.122.camel@nimitz> <20090305220044.GA2819@x200.localdomain> <1236352121.5732.80.camel@bahia> <20090306153549.GA898@us.ibm.com> <49B15F35.2010909@free.fr> <20090306183055.GA6729@us.ibm.com> <49B76D91.1020807@free.fr> <20090312153048.GA11147@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757304AbZCMGg1@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090312153048.GA11147@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Serge Hallyn <serue@linux.vnet.ibm.com>
Cc: Containers <containers@lists.osdl.org>, LKML <linux-kernel@vger.kernel.org>, Oren Laadan <orenl@cs.columbia.edu>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Christoph Hellwig <hch@infradead.org>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

On Thu, Mar 12, 2009 at 10:30:48AM -0500, Serge E. Hallyn wrote:
> Quoting Cedric Le Goater (legoater@free.fr):
> > >> And if Ingo's requirement is fulfilled, would any C/R patchset be acceptable ?
> > > 
> > > Yup, no matter how hideous  :)  Ok not really.
> > > 
> > > But the point was that it wasn't Dave not understanding Alexey's
> > > suggestion, but Greg not understanding Ingo's.  If you think Ingo's
> > > goal isn't worthwhile or achievable, then argue that (as I am), don't
> > > keep elaborating on something we all agree will be needed (Alexey's
> > > suggestion or some other way of doing a true may-be-checkpointed test).
> > 
> > I rather spend my time on enabling things rather than forbid them. 
> 
> That sure sounds productive.  How could I argue with that.
> 
> But wait, haven't several teams been doing that for years?  So why is
> c/r not in the upstream kernel?  Could it be that ignoring the
> upstream maintainers' concerns about (a) treating the feature as a
> toy, (b) long-term maintainability, and (c) c/r becoming an impediment
> to future features, and instead hacking away at our toy feature, is
> *not* always the best course?

I've been thinking about how we could make checkpoint/restart (c/r) more
maintainable in the long-term. I've only come up with two ideas:

I. Implement sparse-like __cr struct annotations for some compile-time checking.

First we annotate structures which c/r needs to save. For example we might have:

	struct mm_struct {
		__cr struct vm_area_struct * mmap;
		struct rb_root mm_rb;
		struct vm_area_struct *mmap_cache;
		...
		__cr unsigned long mmap_base;
		__cr unsigned long task_size;
		..
	};

The __cr annotations indicate fields of the mm_struct which must be
saved during checkpoint restart. In fact, for non-pointer fields these
annotations would be sufficient to generate c/r code.

Next we would need a __cr_root annotation. These mark structures which
the c/r code visits that determine the scope of c/r. If there is no path from a
__cr annotation to a __cr_root annotation then we would conclude that c/r of
this struct is broken. These path constraint checks could be done at compile
time.

Since the example so far lacks a __cr_root we would know that there's a bug
since no __cr_root struct is reachable from an mm_struct. We'd fix that with:

	struct task_struct __cr_root {
		__cr volatile long state;
		..
		__cr struct mm_struct *mm;
		struct *active_mm;
		...
	};

Of course there are problems with this specific annotation scheme. It doesn't
follow casts -- e.g. list heads, rb_nodes, and anything that uses the important
container_of() idiom would be problematic if the containers themselves are not
uniform. What I've proposed so far doesn't check the functions that walk these
data structures during c/r to make sure each saved instance has a matching
restore (seems like this could be addressed though). I'm no sparse expert so I
don't know that sparse can check these kinds of struct constraints,
however I'm pretty sure that if sparse can't do it then we can do it
with the dwarf-2 debugging information available.

We could also save __cr-annotated struct definitions across one or more commits
and compare them to determine how structures with __cr annotations change. We
could use dwarf-2 information to detect certain types of changes which can then
be flagged for further review, emit warnings or even  errors. I think once c/r
was in mainline this would ideally be run against automated compile tests of
linux-next and the output sent to c/r maintainers/lists. This output would also
highlight changes relevant to userspace checkpoint-image converters that enable
things like kernel upgrades by doing checkpoint, kexec, and restart.

The idea of generating straight-line struct assignment code from these
annotations crossed my mind but I'm pretty sure that would be less 
maintainable.

II. JIT-instrumentation

WARNING: This idea is much more vaporous than the previous idea.

Confirm that, from the perspective of executing userspace code, a restarted
container does exactly the same thing as the original, checkpointed container.
Use valgrind's JIT instrumentation framework to do instruction by instruction
step-and-compare cycles between corresponding tasks in each container:

	1. Compare instruction pointer (IP)
	2. Compare the instruction (redundant if we check text mappings)
	3. Compare all register and memory operand contents

Each comparison must match exactly otherwise we "abort" the two containers.

Normally this would break even if c/r is correctly implemented. The idea is we
insert "mirroring" code into parts of the kernel to ensure that the timing and
contents of inputs external to the userspace portion of these containers match:
	1. Network
		i. Need to "mirror" packets to both containers
		ii. Need to merge packets from both containers
	2. Time
		Each corresponding call to functions like gettimeofday()
		would need to return the same struct timeval.
	
		Each timeout result from calls like ppoll() would need
		to be the same.
	3. Locking "order" would need to be "mirrored". This is probably
		the hardest to implement. Task A and A' (original and
		duplicate respectively) could try to acquire the same
		lock or semaphore in the kernel. The results of a system call
		could vary depending on whether trying to acquire this
		lock succeeds. Suddenly the task behavior would diverge
		even though c/r is correct. I haven't figured out how to
		address this problem but perhaps others can make
		suggestions.
	4. Scheduling
		Need to schedule tasks within a container in the same order.
		This is probably strongly tied to both timing and locking --
		perhaps so much so that taking care of those will take care
		of scheduling??

This should catch any points where the restarted application differs
from the original. I'm hoping it would catch most of the problems that
struct annotation would miss and make maintenance of c/r much less
problematic. One weakness of this method as I've described it so far is there's
no mechanism for relating the divergence of the two tasks to a spot in the c/r
code. Again, I haven't thought of a way to do that and perhaps others
can help take the idea farther.

A weakened version of this check might use the same kernel changes but only
compare system calls.

Cheers,
	-Matt Helsley
