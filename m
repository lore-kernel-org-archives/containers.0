From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] SI_ASYNCIO: should be a kernel signal ?
Date: Mon, 22 Dec 2008 14:15:22 -0800
Message-ID: <20081222221522.GC10183@us.ibm.com>
References: <20081221010414.GA5284@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081221010414.GA5284-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org
Cc: daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu [sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| 
| From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| Date: Fri, 19 Dec 2008 20:45:49 -0800
| Subject: [RFC][PATCH] SI_ASYNCIO: should be a kernel signal ?
| 
| SI_ASYNCIO is currently defined as -4 in the kernel. This makes it appear
| like a "user" signal (i.e SI_FROMUSER() is true). SI_ASYNCIO is generated
| by the kernel for async events like SI_MESGQ and SI_POLL, but unlike
| SI_ASYNCIO, SI_MESGQ and SI_POLL are "kernel" signals (i.e SI_FROMKERNEL()
| is true).
| 
| Shouldn't SI_ASYNCIO be a "kernel" signal too ? It is currently generated
| from USB core code.
| 
| This quick/untested RFC patch changes the in-kernel value of SI_ASYNCIO
| as follows so that it becomes a "kernel" signal.
| 
| 	(7 << 16)|(-4 & 0xffff) = 0x7fffc which is SI_FROMKERNEL().
| 
| The user-space value of SI_ASYNCIO continues to be -4.
| 
| Known side-effects:
| 
| 	Is this required to be SI_FROMUSER() to enable the uid checks in
| 	kill_pid_info_as_uid() ? Also, changing to "kernel" signal would skip
| 	the permission checks in check_kill_permission().  Would that be a
| 	problem ?
| 
| Why bother now ? (Sigh. Condensed long story)
| 
| 	Besides the consistency with SI_POLL and SI_MESGQ this could simplify
| 	implementation of special signal semantics for container-init.  When a
| 	signal is sent to container-init from user-space, we need to check the
| 	pid namespace of the sender in send_signal(). But since send_signal()
| 	can also be called from interrupt context,  we have no way of knowing
| 	if it is safe to check the pid namespace of the caller.
| 
| 	If SI_ASYNCIO signal appears as a kernel signal, we could possibly use
| 	SI_FROMUSER() to check if it safe to reference the pid namespace of
| 	the sender.
| 
| 	If this change has no other side-effects/breakage we will explore this
| 	path further for the signal semantics for container-init. (There could
| 	be other hurdles along the way...) 
| 
| 	See also http://lkml.org/lkml/2008/12/20/183
| 
| Appreciate any comments on this.
| 
| TODO:
| 	If this makes sense, make corresponding change to the SI_ASYNCIO
| 	in arch/mips/siginfo.h.

Grr. Importantly, we would also need to update the copy_siginfo*() and
friends for this to be complete.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
