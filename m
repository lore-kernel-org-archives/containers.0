From: "Peter Dolding" <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Roadmap for features planed for containers where and Some future
	features ideas.
Date: Mon, 21 Jul 2008 21:03:47 +1000
Message-ID: <e7d8f83e0807210403g12b980e8jad4fa7e10d8b410e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

http://opensolaris.org/os/community/brandz/  I would like to see if
something equal to this is on the roadmap in particular.   Being able
to run solaris and aix closed source binaries contained would be
useful.

Other useful feature is some way to share a single process between PID
containers as like a container bridge.  For containers used for
desktop applications not having a single X11 server  interfacing with
video card is a issue.

These container bridges avoid having to go threw network cards and
other means to share data between containers.  A user space solution.

I know this reduces secuirty but when you need a application form X
distrobuton and you have Y distribution and its opengl heavy you are
kinda stuffed at moment.

Final one is some form of LSM processing different.  Lot of the Linux
Secuirty channel talk about containers as light weight virtualisation
so will never need to run a OS inside with a different LSM profile to
the master OS.   If containers plan to go after brandz like containers
this needs to be made clear that LSM different processing will be
required.

Peter Dolding
