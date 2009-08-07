From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Fri, 7 Aug 2009 12:08:02 -0700
Message-ID: <20090807190802.GB16671@us.ibm.com>
References: <20090722222550.GA633@megiteam.pl>
	<20090723012733.GB27764@us.ibm.com> <4A67C187.5000201@zytor.com>
	<20090723182620.GA16322@megiteam.pl>
	<20090723193245.GA25662@us.ibm.com>
	<20090723203329.GC16322@megiteam.pl> <4A68E026.1070608@zytor.com>
	<20090724073158.GA2617@megiteam.pl>
	<20090730180611.GA20872@us.ibm.com>
	<1249077522.9378.95.camel@eskarina>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1249077522.9378.95.camel@eskarina>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Grzegorz Nosek [root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org] wrote:
| Hi,
| 
| Dnia 2009-07-30, czw o godzinie 11:06 -0700, Sukadev Bhattiprolu pisze:
| > Well, I made some progress on this. In an earlier mail you mentioned
| > that your test case "survives" in kernels without the bad commit.
| > 
| > With the following patch the kernel seems to _survive_ but not sure if
| > "surviving" meets your real needs (i.e does the pty continue to function
| > as the console for the container) ? 
| 
| Both my patch and yours make the console open fail and I'm not sure we
| can do much better. I don't think this matters (too much) either as the
| supervisor (libvirt_lxc) exits only on container shutdown, so there's
| nothing much we can do to the container anyway.

Ok.  Hope you had some luck with the console and libvirtd.

FWIW, should we push this patch upstream ? It would at least prevent
the kernel crash and be consistent with the behavior before newptsinstance
changes ?

Peter, what do you think about this patch ?

---
Index: linux-2.6.30/fs/devpts/inode.c
===================================================================
--- linux-2.6.30.orig/fs/devpts/inode.c 2009-07-30 10:48:17.000000000 -0400
+++ linux-2.6.30/fs/devpts/inode.c      2009-08-04 11:43:51.000000000 -0400
@@ -519,11 +519,22 @@

 struct tty_struct *devpts_get_tty(struct inode *pts_inode, int number)
 {
+       struct dentry *dentry;
+       struct tty_struct *tty;
+
        BUG_ON(pts_inode->i_rdev == MKDEV(TTYAUX_MAJOR, PTMX_MINOR));

+       dentry = d_find_alias(pts_inode);
+       if (!dentry)
+               return NULL;
+
+       tty = NULL;
        if (pts_inode->i_sb->s_magic == DEVPTS_SUPER_MAGIC)
-               return (struct tty_struct *)pts_inode->i_private;
-       return NULL;
+               tty = (struct tty_struct *)pts_inode->i_private;
+
+       dput(dentry);
+
+       return tty;
 }

 void devpts_pty_kill(struct tty_struct *tty)
