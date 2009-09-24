From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][v7][PATCH 0/9] Implement clone2() system call
Date: Thu, 24 Sep 2009 18:06:42 -0400
Message-ID: <4ABBED72.9080901__3228.42467944628$1253830062$gmane$org@librato.com>
References: <20090924165548.GA16586@us.ibm.com> <4ABBAFE5.2000704@librato.com>
	<20090924201517.GA24786@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090924201517.GA24786-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> No, as Arnd pointed out, we already pass in a pointer to 'struct clone_struct'
> and the kernel can use that pointer to copy the parent and child tids.

In this form, you place a constraints on where userspace may
place the {parent,child}_tid variable, and require that this
particular clone_struct remain valid memory in the parent until
the child terminates.  This may break existing programs that
use this (threads libraries ?)

Oren.

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
> Good idea. Will do.
> 
> Thanks,
> 
> Sukadev
