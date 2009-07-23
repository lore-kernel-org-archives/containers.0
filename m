From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Thu, 23 Jul 2009 22:33:29 +0200
Message-ID: <20090723203329.GC16322@megiteam.pl>
References: <20090715044744.GA25745@us.ibm.com>
	<20090715131923.GB21417@megiteam.pl>
	<20090718205244.GA23625@us.ibm.com>
	<20090719071531.GA20818@megiteam.pl>
	<20090722064120.GA24373@us.ibm.com>
	<20090722222550.GA633@megiteam.pl>
	<20090723012733.GB27764@us.ibm.com> <4A67C187.5000201@zytor.com>
	<20090723182620.GA16322@megiteam.pl>
	<20090723193245.GA25662@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090723193245.GA25662-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On czw, lip 23, 2009 at 12:32:45 -0700, Sukadev Bhattiprolu wrote:
> | OK, the first bad commit is:
> | commit 4a2b5fddd53b80efcb3266ee36e23b8de28e761a
> 
> Yes, I think this was fixed by 808ffa3d302257b9dc37b1412c1fcdf976fcddac

Any other tests I can do that will be helpful? E.g. 2.6.27 + 808ffa?

> | The oops itself is introduced by:
> | commit 527b3e4773628b30d03323a2cb5fb0d84441990f
> | Author: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> | Date:   Mon Oct 13 10:43:08 2008 +0100
> | 
> |     Simplify devpts_get_tty()
> | 
> |     As pointed out by H. Peter Anvin, since the inode for the pty is known,
> |     we don't need to look it up.
> | 
> |     Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> |     Signed-off-by: Alan Cox <alan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> |     Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> 
> Maybe before returning the tty, we need to take an extra reference on
> the dentry.

I tried that and while it did not oops, I wasn't sure where to dput it
back, so it leaked like a sieve. I'm probably missing something obvious
but I couldn't find a function whose calls balanced calls to
devpts_get_tty.

BTW, what would the semantics be? I.e. what can we do with a pty that has
its master side long gone?

Best regards,
 Grzegorz Nosek
