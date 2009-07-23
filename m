From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Wed, 22 Jul 2009 18:48:55 -0700
Message-ID: <4A67C187.5000201@zytor.com>
References: <20090713202610.GA6447@us.ibm.com>
	<20090713223444.GM18617@megiteam.pl>
	<20090714064905.GA25278@us.ibm.com>
	<20090714103129.GB12958@megiteam.pl>
	<20090715044744.GA25745@us.ibm.com>
	<20090715131923.GB21417@megiteam.pl>
	<20090718205244.GA23625@us.ibm.com>
	<20090719071531.GA20818@megiteam.pl>
	<20090722064120.GA24373@us.ibm.com>
	<20090722222550.GA633@megiteam.pl>
	<20090723012733.GB27764@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090723012733.GB27764-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/22/2009 06:27 PM, Sukadev Bhattiprolu wrote:
> | 
> | Immediate crash. I tried 2.6.18-something (Debian etch kernel) that I
> | had lying around on the VM. The result:
> 
> Interesting.
> 
> Attaching test program and Ccing Peter Anvin for any insights.
> 
> | idr_remove called for id=0 which is not allocated.
> |  [<c01b7abc>] idr_remove+0xd4/0x137
> |  [<c01fa871>] release_mem+0x1d5/0x1e1
> |  [<c01fb4ec>] release_dev+0x5d6/0x5ee
> |  [<c011669e>] __wake_up+0x2a/0x3d
> |  [<c01f9e1f>] tty_ldisc_enable+0x1f/0x21
> |  [<c01fabf5>] init_dev+0x378/0x49f
> |  [<c01fd2e4>] tty_open+0x2a9/0x2e8
> |  [<c0161899>] chrdev_open+0x126/0x141
> |  [<c0161773>] chrdev_open+0x0/0x141
> |  [<c0158b65>] __dentry_open+0xc8/0x1ac
> |  [<c0158cad>] nameidata_to_filp+0x19/0x28
> |  [<c0158ce7>] do_filp_open+0x2b/0x31
> |  [<c027fddd>] do_nanosleep+0x43/0x6a
> |  [<c0125f96>] do_sigaction+0x99/0x156
> |  [<c0158d2b>] do_sys_open+0x3e/0xb3
> |  [<c0158dcd>] sys_open+0x16/0x18
> |  [<c0102c7b>] syscall_call+0x7/0xb
> | 
> | (on the bright side, the machine is still usable afterwards).
> | 
> | However, 2.6.26 (both mine and Debian) survives the test so it may indeed
> | be a recent regression (was it broken again after fixing sometime
> | between .18 and .26?)
> | 
> | Bisecting...

Interesting... I have to say I'm more than a bit surprised that you can
mount a filesystem on top of a character device node at all, but there
isn't really a fundamental reason why you couldn't do it, so...

I am assuming that what causes the problem is that you have found a way
(vfsmount) to hold the pts device node busy which doesn't involve the
tty subsystem.  This isn't inherently a problem, but it does have
implications for freeing: in particular, the pts node cannot be removed
until the vfsmount is gone, *and* the device number cannot be reclaimed.
 It sounds like it's the latter piece which causes problems.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
