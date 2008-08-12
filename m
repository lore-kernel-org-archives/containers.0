From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Tue, 12 Aug 2008 09:49:05 -0500
Message-ID: <20080812144905.GA16016__47445.070758886$1218552777$gmane$org@us.ibm.com>
References: <20080807224033.FFB3A2C1@kernel> <200808090013.41999.arnd@arndb.de>
	<20080811152201.GB25930@us.ibm.com>
	<200808111853.13854.arnd@arndb.de>
	<1218484114.5598.43.camel@nimitz> <48A0CD86.6030704@goop.org>
	<87d4kfds5i.wl%peterc@chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87d4kfds5i.wl%peterc-LkDQP0DxSMGxwJ88Py/mJxCuuivNXqWP@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Chubb <peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
Cc: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Peter Chubb (peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org):
> >>>>> "Jeremy" == Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org> writes:
> 
> Jeremy> Dave Hansen wrote:
> >> Arnd, Jeremy and Oren,
> >> 
> 
> 
> Jeremy>    * multiple processes * pipes * UNIX domain sockets * INET
> Jeremy> sockets (both inter and intra machine) * unlinked open files *
> Jeremy> checkpointing file content * closed files (ie, files which
> Jeremy> aren't currently open, but will be soon, esp tmp files) *
> Jeremy> shared memory * (Peter, what have I forgotten?)
> 
> File sharing; multiple threads with wierd sharing arrangements (think:
> clone with various parameters, followed by exec in some of the threads
> but not others); MERT/system-V shared memory, semaphores and message
> queues; devices (audio, framebuffer, etc), HugeTLBFS, numa issues
> (pinning, memory layout), processes being debugged (so,
> checkpoint.restart a gdb/target pair), futexes, etc., etc.  Linux
> process state keeps expanding.
> 
> Jeremy> Having gone through this before, I don't think an all-kernel
> Jeremy> solution can work except for the most simple cases.
> 
> I agree ... it's better to put mechanisms into the kernel that can
> then be used by a user-space programme to actually do the
> checkpointing and restarting.
> 
> Beefing up ptrace or fixing /proc to be a real debugging interface
> would be a start ... when you can get at *all* the info you need,

Except we don't really want to export all the info you need for a
complete restartable checkpoint.  And especially not make it
generally writable.

We have also started down that path using ptrace (see cryo, at
git://git.sr71.net/~hallyn/cryodev.git).

Right before the containers mini-summit, where the general agreement was
that a complete in-kernel solution ought to be pursued, I had tried
a restart using a binary format that read a checkpoint file and used
cryo (userspace using ptrace) for the rest of the restart, only
because there was no other reasonable way to set tsk->did_exec on
restart.

> quickly and easily, the userspace checkpoint falls out fairly
> naturally.  You still have to work out an extensible file format to
> store stuff, and how to restore all that state you've so lovingly
> collected.
> 
> Jeremy> Lightweight filesystem checkpointing, such as btrfs provides,
> Jeremy> would seem like a powerful mechanism for handling a lot of the
> Jeremy> filesystem state problems.  It would have been useful when we
> Jeremy> did this...
> 
> And how!  saving bits of files was very timeconsuming.

Yes, we're looking forward to using btrfs' snapshots :)

-serge
