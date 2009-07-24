From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Fri, 24 Jul 2009 09:31:58 +0200
Message-ID: <20090724073158.GA2617@megiteam.pl>
References: <20090718205244.GA23625@us.ibm.com>
	<20090719071531.GA20818@megiteam.pl>
	<20090722064120.GA24373@us.ibm.com>
	<20090722222550.GA633@megiteam.pl>
	<20090723012733.GB27764@us.ibm.com> <4A67C187.5000201@zytor.com>
	<20090723182620.GA16322@megiteam.pl>
	<20090723193245.GA25662@us.ibm.com>
	<20090723203329.GC16322@megiteam.pl> <4A68E026.1070608@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A68E026.1070608-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 23, 2009 at 03:11:50PM -0700, H. Peter Anvin wrote:
> Nothing, but as long as something is keeping the pts file entry open, it
>  should not be garbage-collected.

The pts is opened after the parent (holding the master side) exits, so the
ptm is not going away from under us while we have the pts open -- it's no
longer there at open() time.

The lifetime rules and relations for master tty_struct, slave tty_struct
and the corresponding devpts inode are still not completely clear to me
(what is holding what alive etc.), so I want to be 100% sure we're on the
same page.

In this case it looks like the ttys are gone but the inode still keeps a
pointer to the pts tty_struct. So we can either:
 1. overwrite the pointer with -EIO or something
 2. extend the life of the ttys to match the inode

As the end result from userspace perspective is the same (we have to
error out when opening the pts anyway -- as you implied above), I'd go for
the simpler (1).

BTW, I was mistaken about experimenting with the dentry refcount -- I
did it the other way around (tty_kref_get while creating the inode
IIRC). Sorry for the confusion.

Best regards,
 Grzegorz Nosek
