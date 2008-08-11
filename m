From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Mon, 11 Aug 2008 23:47:49 +0200
Message-ID: <200808112347.50245.arnd__34357.7446336441$1218491830$gmane$org@arndb.de>
References: <20080807224033.FFB3A2C1@kernel> <200808111853.13854.arnd@arndb.de>
	<1218484114.5598.43.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1218484114.5598.43.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Monday 11 August 2008, Dave Hansen wrote:
> Thanks for all of the very interesting comments about the ABI. =A0
> =

> Considering that we're still *really* early in getting this concept
> merged up into mainline, what do you all think we should do now?

I think the two most important aspects here need to be security and
simplicity. If you have to choose between the two, it probably makes
sense to put security first, because loading untrusted data into
the kernel puts you at a significant risk to start with. If you
can show a restart interface that lets regular users restart their
tasks in a way anyone can verify to be secure, that will be a
good indication that you're on the right track.

The other problem that you really need to solve is interface
stability. What you are creating is a binary representation
of many kernel internal data structures, so in our common
rules, you have to make sure that you remain forward and
backward compatible. Simply saying that you need to run
an identical kernel when restarting from a checkpoint is not
enough IMHO.


Some more words on specific interfaces that we have discussed:

The single-file-descriptor approach has the big advantage of
keeping the complexity in one place (the kernel). To be consistent
with other kernel interfaces, I would make the kernel hand out a
file descriptor, not let the user open a file and pass that into
the kernel as you do now.

A new file system is a good idea for many complex interfaces that
make their way into the kernel, but I don't think it will help
in this case.

For checkpointing a single task, or even a task with its children,
a different interface I could imagine would be to have a new
file in procfs per pid that you can read as a pipe giving our
the same data that you currently save in the checkpoint file
descriptor. It does mean that you won't be able to pass flags
down easily (you could write to the pipe before you start reading,
but that's not too nice).

On the restart side, I think the most consistent interface would
be a new binfmt_chkpt implementation that you can use to execve
a checkpoint, just like you execute an ELF file today. The binfmt
can be a module (unlike a syscall), so an administrator that is
afraid of the security implications can just disable it by not
loading the module. In an execve model, the parent process can
set up anything related to credentials as good as it's allowed
to and then let the kernel do the rest.

	Arnd <><
