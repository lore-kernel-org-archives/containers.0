From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Thu, 23 Jul 2009 15:11:50 -0700
Message-ID: <4A68E026.1070608@zytor.com>
References: <20090715044744.GA25745@us.ibm.com>
	<20090715131923.GB21417@megiteam.pl>
	<20090718205244.GA23625@us.ibm.com>
	<20090719071531.GA20818@megiteam.pl>
	<20090722064120.GA24373@us.ibm.com>
	<20090722222550.GA633@megiteam.pl>
	<20090723012733.GB27764@us.ibm.com> <4A67C187.5000201@zytor.com>
	<20090723182620.GA16322@megiteam.pl>
	<20090723193245.GA25662@us.ibm.com>
	<20090723203329.GC16322@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090723203329.GC16322-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Grzegorz Nosek wrote:
> 
> I tried that and while it did not oops, I wasn't sure where to dput it
> back, so it leaked like a sieve. I'm probably missing something obvious
> but I couldn't find a function whose calls balanced calls to
> devpts_get_tty.
> 
> BTW, what would the semantics be? I.e. what can we do with a pty that has
> its master side long gone?
> 

Nothing, but as long as something is keeping the pts file entry open, it
 should not be garbage-collected.

	-hpa
