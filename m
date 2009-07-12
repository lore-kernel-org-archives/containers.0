From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Sun, 12 Jul 2009 09:49:33 +0200
Message-ID: <20090712074932.GA17291@megiteam.pl>
References: <d06d0dd6a4ddf760bea53291c048e291@[::1]>
	<20090413142038.GB13007@us.ibm.com>
	<20090704132851.GA16373@megiteam.pl>
	<20090704143412.GA27523@megiteam.pl>
	<20090708105417.GA16833@megiteam.pl>
	<20090711193055.GA11303@megiteam.pl>
	<20090711200133.GB11303@megiteam.pl>
	<20090711231935.6ff59796@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090711231935.6ff59796-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On sob, lip 11, 2009 at 11:19:35 +0100, Alan Cox wrote:
> > Talking to myself (again), kmemleak doesn't report anything (apart from
> > a few unrelated early-init warnings) but running the startup/shutdown loop
> > on tty1 causes totally crazy behaviour on every VT I used. By "totally
> > crazy" I mean not responding properly to arrow keys, backspace etc., but
> 
> You are only seeing this with containers ?

Well, that's how I could reproduce it, didn't try any other way.
Multiple devpts instances don't matter here, but quite possibly
namespaces do.

If I let the loop run unattended, after it finishes the VTs are fine,
even the tty1 where the loop ran. However, if I try to use them with the
loop on another VT, they break and stay broken afterwards. Looks like
the container init (which has /dev/pts/0 mounted over /dev/console)
somehow interacts with the current VT. This may be a container isolation
problem rather than a TTY layer bug, though.

Didn't try (yet) running the loop while logged in via ssh or in a mc
subshell (so via a pty). I wonder if that changes anything.

BTW, kmemleak *did* report something after all but it was
networking-related (got the traces).

BTW2, I could not reproduce the fd count error while leaving the VM
unattended (and not letting its tty ops interleave with my tty ops),
so could you please have a look and say if the patch stands on its own?

Best regards,
 Grzegorz Nosek
