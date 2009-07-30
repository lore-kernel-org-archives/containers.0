From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Thu, 30 Jul 2009 11:44:20 -0700
Message-ID: <20090730184420.GA4581@us.ibm.com>
References: <20090722064120.GA24373@us.ibm.com>
	<20090722222550.GA633@megiteam.pl>
	<20090723012733.GB27764@us.ibm.com> <4A67C187.5000201@zytor.com>
	<20090723182620.GA16322@megiteam.pl>
	<20090723193245.GA25662@us.ibm.com>
	<20090723203329.GC16322@megiteam.pl> <4A68E026.1070608@zytor.com>
	<20090724073158.GA2617@megiteam.pl>
	<20090730180611.GA20872@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090730180611.GA20872-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu [sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| Index: linux-2.6.30/fs/devpts/inode.c
| ===================================================================
| --- linux-2.6.30.orig/fs/devpts/inode.c 2009-07-30 10:48:17.000000000 -0400
| +++ linux-2.6.30/fs/devpts/inode.c      2009-07-30 10:58:37.000000000 -0400
| @@ -519,8 +519,14 @@
| 
|  struct tty_struct *devpts_get_tty(struct inode *pts_inode, int number)
|  {
| +       struct dentry *dentry;
| +
|         BUG_ON(pts_inode->i_rdev == MKDEV(TTYAUX_MAJOR, PTMX_MINOR));
| 
| +       dentry = d_find_alias(pts_inode);
| +       if (IS_ERR(dentry))

Sorry, this should be:

	if (!dentry)

| +               return NULL;
| +
|         if (pts_inode->i_sb->s_magic == DEVPTS_SUPER_MAGIC)
|                 return (struct tty_struct *)pts_inode->i_private;
|         return NULL;
| 
| _______________________________________________
| Containers mailing list
| Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
| https://lists.linux-foundation.org/mailman/listinfo/containers
