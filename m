From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 08/10] Introduce functions to restart a process
Date: Fri, 24 Oct 2008 07:57:36 +0400
Message-ID: <200810240757.38012.major__22707.0136265413$1224820878$gmane$org@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<200810231300.50628.amirkin@parallels.com>
	<1224770277.12673.21.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224770277.12673.21.camel@nimitz>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thursday 23 October 2008 17:57 Dave Hansen wrote:
> On Thu, 2008-10-23 at 13:00 +0400, Andrey Mirkin wrote:
> > > >>> It is not related to the freezer code actually.
> > > >>> That is needed to restart syscalls. Right now I don't have a code
> > > >>> in my patchset which restarts a syscall, but later I plan to add
> > > >>> it. In OpenVZ checkpointing we restart syscalls if process was
> > > >>> caught in syscall during checkpointing.
> > > >>
> > > >> Do you checkpoint uninterruptible syscalls as well? If only
> > > >> interruptible syscalls are checkpointed, I'd say that either this
> > > >> syscall uses ERESTARTSYS or ERESTART_RESTARTBLOCK, and then signal
> > > >> handling code already does the trick, or this syscall does not
> > > >> restart itself when interrupted, and well, this is life, userspace
> > > >> just sees -EINTR, which is allowed by the syscall spec.
> > > >> Actually this is how we checkpoint/migrate tasks in interruptible
> > > >> syscalls in Kerrighed and this works.
> > > >
> > > > We checkpoint only interruptible syscalls. Some syscalls do not
> > > > restart themself, that is why after restarting a process we restart
> > > > syscall to complete it.
> > >
> > > Can you please elaborate on this ?  I don't recall having had issues
> > > with that.
> >
> > Right now in 2.6.18 kernel we restarts in such a way pause,
> > rt_sigtimedwait and futex syscalls. Recently futex syscall was reworked
> > and we will not need such hooks for it.
>
> Could you elaborate on this a bit?
>
> If the futex syscall was reworked, perhaps we can do the same for
> rt_sigtimedwait() and get rid of this code completely.

Well, we can try to rework rt_sigtimedwait(), but we will still need this code 
in the future to restart pause syscall from kernel without returning to user 
space. Also this code will be needed to restore some complex states.
As concerns pause syscall I have already written to Louis about the problem we 
are trying to solve with this code. There is a gap when process will be in 
user space just before entering syscall again. At this time a signal can be 
delivered to process and it even can be handled. So, we will miss a signal 
which must interrupt pause syscall.

Andrey
