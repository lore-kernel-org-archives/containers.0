From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Thu, 30 Jul 2009 11:06:11 -0700
Message-ID: <20090730180611.GA20872@us.ibm.com>
References: <20090719071531.GA20818@megiteam.pl>
	<20090722064120.GA24373@us.ibm.com>
	<20090722222550.GA633@megiteam.pl>
	<20090723012733.GB27764@us.ibm.com> <4A67C187.5000201@zytor.com>
	<20090723182620.GA16322@megiteam.pl>
	<20090723193245.GA25662@us.ibm.com>
	<20090723203329.GC16322@megiteam.pl> <4A68E026.1070608@zytor.com>
	<20090724073158.GA2617@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090724073158.GA2617-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
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
| On Thu, Jul 23, 2009 at 03:11:50PM -0700, H. Peter Anvin wrote:
| > Nothing, but as long as something is keeping the pts file entry open, it
| >  should not be garbage-collected.
| 
| The pts is opened after the parent (holding the master side) exits, so the
| ptm is not going away from under us while we have the pts open -- it's no
| longer there at open() time.
| 
| The lifetime rules and relations for master tty_struct, slave tty_struct
| and the corresponding devpts inode are still not completely clear to me
| (what is holding what alive etc.), so I want to be 100% sure we're on the
| same page.
| 
| In this case it looks like the ttys are gone but the inode still keeps a
| pointer to the pts tty_struct. So we can either:
|  1. overwrite the pointer with -EIO or something
|  2. extend the life of the ttys to match the inode
| 
| As the end result from userspace perspective is the same (we have to
| error out when opening the pts anyway -- as you implied above), I'd go for
| the simpler (1).
| 
| BTW, I was mistaken about experimenting with the dentry refcount -- I
| did it the other way around (tty_kref_get while creating the inode
| IIRC). Sorry for the confusion.

Well, I made some progress on this. In an earlier mail you mentioned
that your test case "survives" in kernels without the bad commit.

With the following patch the kernel seems to _survive_ but not sure if
"surviving" meets your real needs (i.e does the pty continue to function
as the console for the container) ? 

The way I understand, the child process does not get an open-file reference
to the pty. So when the parent closes the pty, devpts_pty_kill() unhashes
the dentry (although the bind mount() in the child has a reference count
on dentry).

Sukadev

---

Index: linux-2.6.30/fs/devpts/inode.c
===================================================================
--- linux-2.6.30.orig/fs/devpts/inode.c 2009-07-30 10:48:17.000000000 -0400
+++ linux-2.6.30/fs/devpts/inode.c      2009-07-30 10:58:37.000000000 -0400
@@ -519,8 +519,14 @@

 struct tty_struct *devpts_get_tty(struct inode *pts_inode, int number)
 {
+       struct dentry *dentry;
+
        BUG_ON(pts_inode->i_rdev == MKDEV(TTYAUX_MAJOR, PTMX_MINOR));

+       dentry = d_find_alias(pts_inode);
+       if (IS_ERR(dentry))
+               return NULL;
+
        if (pts_inode->i_sb->s_magic == DEVPTS_SUPER_MAGIC)
                return (struct tty_struct *)pts_inode->i_private;
        return NULL;
