From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Sat, 11 Jul 2009 22:01:33 +0200
Message-ID: <20090711200133.GB11303@megiteam.pl>
References: <d06d0dd6a4ddf760bea53291c048e291@[::1]>
	<20090413142038.GB13007@us.ibm.com>
	<20090704132851.GA16373@megiteam.pl>
	<20090704143412.GA27523@megiteam.pl>
	<20090708105417.GA16833@megiteam.pl>
	<20090711193055.GA11303@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090711193055.GA11303-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Jul 11, 2009 at 09:30:55PM +0200, Grzegorz Nosek wrote:
> With the following (whitespace-damaged etc.) patch applied I can no longer
> oops the kernel but there are several issues:
> 
> 1. A warning occurs (after several dozen start/shutdown cycles):
> Warning: dev (pts0) tty->count(2) != #fd's(1) in tty_release_dev
> So refcounting is still broken and this patch possibly just papers over
> the real bug.
> 
> 2. There's a memory leak somewhere (don't know if it was there before as
> the system hadn't survived long enough to test that) guesstimated at
> several KB per container cycle; building with kmemleak to see what
> happens.
> 
> 3. After adding tons of debug statements I saw that the TTY objects
> weren't always freed immediately after container shutdown but were
> somehow batched (e.g. a single container shut down would cause two or
> three previous containers' tty objects to be freed). Increasing the
> delay between subsequent cycles from 3 to 10 seconds didn't seem to
> affect the batching. On an otherwise unpatched kernel, the crashes
> happened right after the 'batched' cleanups.

Talking to myself (again), kmemleak doesn't report anything (apart from
a few unrelated early-init warnings) but running the startup/shutdown loop
on tty1 causes totally crazy behaviour on every VT I used. By "totally
crazy" I mean not responding properly to arrow keys, backspace etc., but
printing stuff like ^[B for arrows and a dot for backspace. Note: this
happened _most_ of the time but not _all_ (navigating shell history was
fun). Even the shell started to misbehave as I tried to execute:
echo 3 > drop_caches
and the shell helpfully said:
3 > drop_caches

Any ideas, anyone?

Best regards,
 Grzegorz Nosek
