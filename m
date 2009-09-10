From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][v6][PATCH 8/9]: Define clone_with_pids() syscall
Date: Thu, 10 Sep 2009 14:28:37 -0700
Message-ID: <20090910212837.GA31459__39039.8290394389$1252620358$gmane$org@us.ibm.com>
References: <20090910060627.GA24343@us.ibm.com>
	<20090910061301.GG25883@us.ibm.com>
	<200909100931.25585.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200909100931.25585.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Arnd Bergmann [arnd-r2nGTMty4D4@public.gmane.org] wrote:
| 
| I wonder if we can avoid spreading copies of this function across
| all architectures.
| 
| Would it be possible to define it like this?

Since this is a variant of clone() and clone is listed as a PTREGSCALL(),
I pass in the pt_regs.

arch/x86/kernel/entry_32.S lists clone() under this comment:

/*
 * System calls that need a pt_regs pointer.
 */

Is there a guideline on what system calls use/need pt_regs ?

Thanks,

Suakdev

| 
| asmlinkage long
| clone_with_pids(int flags, unsigned long child_stack_base, int __user *parent_tid_ptr,
|                        int __user *child_tid_ptr, struct pid_set __user *pid_setp)
| {
| 	if (!child_stack_base) {
| 		struct pt_regs *regs;
| 
| 		regs = task_pt_regs(current);
| 		child_stack_base = user_stack_pointer(regs);
| 	}
| 
| 	return do_fork_with_pids(clone_flags, child_stack_base, 0,
| 		parent_tid_ptr, child_tid_ptr, pid_setp);
| }
