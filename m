From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][v7][PATCH 0/9] Implement clone2() system call
Date: Thu, 01 Oct 2009 11:19:27 -0400
Message-ID: <4AC4C87F.3000702__44830.3167162978$1254410427$gmane$org@librato.com>
References: <20090924165548.GA16586@us.ibm.com> <4ABBAFE5.2000704@librato.com>
	<20091001023618.GA31344@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091001023618.GA31344-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: arnd-r2nGTMty4D4@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org] wrote:
> | 
> | 
> | Sukadev Bhattiprolu wrote:
> | > === NEW CLONE() SYSTEM CALL:
> | > 
> | > To support application checkpoint/restart, a task must have the same pid it
> | > had when it was checkpointed.  When containers are nested, the tasks within
> | > the containers exist in multiple pid namespaces and hence have multiple pids
> | > to specify during restart.
> | > 
> | > This patchset implements a new system call, clone2() that lets a process
> | > specify the pids of the child process.
> | > 
> | > Patches 1 through 6 are helper patches, needed for choosing a pid for the
> | > child process.
> | > 
> | > Patch 8 defines a prototype of the new system call. Patch 9 adds some
> | > documentation on the new system call, some/all of which will eventually
> | > go into a man page.
> | > 
> | 
> | [...]
> | 
> | > 
> | > Based on these requirements and constraints, we explored a couple of system
> | > call interfaces (in earlier versions of this patchset) and currently define
> | > the system call as:
> | > 
> | > 	struct clone_struct {
> | > 		u64 flags;
> | > 		u64 child_stack;
> | > 		u32 nr_pids;
> | > 		u32 parent_tid;
> | > 		u32 child_tid;
> | 
> | So @parent_tid and @child_tid are pointers to userspace memory and
> | require 'u64' (and it won't hurt to make @reserved1 a 'u64' as well).
> 
> Well, if we make parent_tid and child_tid u64, we could move reserved1
> after ->nr_pids and leave it as a 32-bit value.

Sure. In any case, won't hurt to leave large reserved space -
someone may be thankful for it in the future ;)

> 
> | 
> | > 		u32 reserved1;
> | > 		u64 reserved2;
> | > 	};
> | > 
> | 
> | Also, for forward/backward compatibility, explicitly state in the
> | documentation, and enforce in the kernel, that flags which are not
> | defined must not be set, and that reserved{1,2} must remain 0.
> 
> Agree with checking for reserved1 and reserved2.
> 
> We currently don't check for invalid clone_flags - we just ignore them.
> Adding checks like
> 
> 	if (fls(kcs.flags) > fls(CLONE_LAST_FLAG))
> 
> would assume we always use bits in order (while it seems to make sense, to
> use them in order, we don't seem to have done so in the past).
> 
> Alternatively we could define a CLONE_FLAG_MASK of valid flags and update
> the mask when each new clone flag is added. 
> 
> But do we really need to check for invalid flags ?

I'd go for a a mask.

The idea is that we want to educate userspace to _not_ use unused
flags now. For if userspace sets an unused flag now and we let it
be, the application will break when we give meaning to that flag.

Oren.
