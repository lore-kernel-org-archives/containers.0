From: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] SI_ASYNCIO: should be a kernel signal ?
Date: Tue, 30 Dec 2008 15:53:26 -0800 (PST)
Message-ID: <20081230235327.063F0FC278@magilla.sf.frob.com>
References: <20081221010414.GA5284@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: Sukadev Bhattiprolu's message of  Saturday, 20 December 2008 17:04:14 -0800 <20081221010414.GA5284-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

The value of SI_ASYNCIO is part of the user ABI already, so you
can't really change it anyway.  But, there is a logic why it was
correct for it to be SI_FROMUSER (not just an old choice we are
stuck with, which it also is).

The real purpose of the SI_FROMUSER/SI_FROMKERNEL distinction is not
an abstract idea of "kernel-generated or not".  In fact, it's purely
to distinguish "forgeable" from "guaranteed exact kernel semantics".
SI_ASYNCIO is a notification about something the user asked for
specially, not one about any kernel-enforced sort of event.  If the
user wants to send himself signals with si_code=SI_ASYNCIO, then fine.
Noone's going to be fooled about who instigated such a signal.

In fact, the main use of SI_ASYNCIO signals in practice is for a user
to send them to himself.  That's what glibc (-lrt) does to implement
the POSIX aio_* calls.  The only uses in the kernel are in the USB
code related to some magic ioctls.

Those in-kernel cases call kill_pid_info_as_uid precisely for the same
issue of current vs instigating-process.  These are the only calls to
that function.  It really could be called something else like
"kill_self_from_interrupt", because its only use is this case that's
considered to be, "I'm sending it to myself, delayed."  That is, it
caches the uid/euid along with the struct pid to itself, in case of
instigating it, changing uids, and then having the interrupt deliver
the signal to the same process that is now differently-privileged.

It's not real clear you care about the old vs new pid namespace the
same way we care about the old vs new current_cred.  Since the sender
can only be "myself" or "my former self", maybe just call it "myself"
and be done with it--you just don't need any check in this path.


Thanks,
Roland
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
