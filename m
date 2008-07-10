From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [RFC PATCH 0/5] Resend - Use procfs to change a syscall behavior
Date: Thu, 10 Jul 2008 20:45:12 +0200
Message-ID: <20080710184512.GA19428@elf.ucw.cz>
References: <20080703144013.737951000@bull.net>
	<20080704102702.GB4531@elf.ucw.cz> <486E1276.2080605@bull.net>
	<20080708105143.GA15311@elf.ucw.cz> <4875BD4B.2070402@bull.net>
	<20080710085406.GA13258@elf.ucw.cz>
	<1215712415.9398.24.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1215712415.9398.24.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu 2008-07-10 10:53:35, Dave Hansen wrote:
> On Thu, 2008-07-10 at 10:54 +0200, Pavel Machek wrote:
> > 
> > If you don't see a backward compatibility problem here, perhaps you
> > should not be hacking kernel...? The way ids are assigned is certainly
> > part of syscall semantics (applications rely on), at least for open.
> 
> We also used to have a pretty defined ordering for handing out address
> space with mmap().  That all changed with address space randomization.
> Are file descriptors different somehow?
> 
> Anyway, it's not like we're actually changing existing behavior.  An
> application has to do something special and new to trigger this new
> behavior.  Nobody is going to stumble over it, and it will *not* break
> backward compatibility.

It will break compatibility, but not in a way you expect. There's
application called "subterfugue" that monitors other applications
using ptrace and enforces security policy (or does other stuff). Such
hacks depend on existing syscalls behaving in a way they are
specified...

Then you'll have to update open.2 man page:

DESCRIPTION
       Given a pathname for a file, open() returns a file descriptor,
a small, non-
       negative integer for use in  subsequent  system  calls
(read(2),  write(2),
       lseek(2),  fcntl(2),  etc.).   The  file descriptor returned by
a successful
       call will be the lowest-numbered file descriptor not currently
open for  the
       process.

...you'll need to add "unless someone write some number in file in
/proc somewhere"... hmm... is new behaviour even POSIX compliant?
open() is specified in POSIX...

Ok, so it will not break too many apps... but echo "123 >
/proc/something" breaking bash (etc) is not nice.

(Plus proposed interface is so ugly that this discussion is moot.)

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
