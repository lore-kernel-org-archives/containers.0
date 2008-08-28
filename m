From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: checkpoint/restart ABI
Date: Thu, 28 Aug 2008 16:40:21 -0700
Message-ID: <m1abewaeu2.fsf__28210.2029923864$1219967199$gmane$org@frodo.ebiederm.org>
References: <20080807224033.FFB3A2C1@kernel>
	<200808090013.41999.arnd@arndb.de> <20080811152201.GB25930@us.ibm.com>
	<200808111853.13854.arnd@arndb.de> <1218484114.5598.43.camel@nimitz>
	<48A0CD86.6030704@goop.org> <87d4kfds5i.wl%peterc@chubb.wattle.id.au>
	<20080812144905.GA16016@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080812144905.GA16016-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Tue, 12 Aug 2008 09:49:05 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Peter Chubb <peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Peter Chubb (peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org):

>> Beefing up ptrace or fixing /proc to be a real debugging interface
>> would be a start ... when you can get at *all* the info you need,
>
> Except we don't really want to export all the info you need for a
> complete restartable checkpoint.  And especially not make it
> generally writable.

That and unless we get a lot of synergy from authors of debuggers
and debugging code it is a more general and slower interface for
no apparent gain.

> We have also started down that path using ptrace (see cryo, at
> git://git.sr71.net/~hallyn/cryodev.git).
>
> Right before the containers mini-summit, where the general agreement was
> that a complete in-kernel solution ought to be pursued, I had tried
> a restart using a binary format that read a checkpoint file and used
> cryo (userspace using ptrace) for the rest of the restart, only
> because there was no other reasonable way to set tsk->did_exec on
> restart.

Can we please describe this as the giant syscall approach.  Instead
of a complete in-kernel solution.  There are things like filesystems
that should be checkpointed separately, or not checkpointed at all.

However there is a large set of processes and process state that always
goes together and if you checkpoint a container you always want.

So building something that is roughly equivalent to a binfmt module
but that can save and restore multiple tasks with a single operation
looks like the right granularity.

>> Jeremy> Lightweight filesystem checkpointing, such as btrfs provides,
>> Jeremy> would seem like a powerful mechanism for handling a lot of the
>> Jeremy> filesystem state problems.  It would have been useful when we
>> Jeremy> did this...
>> 
>> And how!  saving bits of files was very timeconsuming.
>
> Yes, we're looking forward to using btrfs' snapshots :)

Yep.  And in the case of migration we don't even need to snapshot
a filesystem just mount it from on the target machine.  Except for
the unlinked files challenge.

Eric
