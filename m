From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: linux-cr:  v23-rc1 pushed
Date: Thu, 13 Jan 2011 22:59:11 -0800
Message-ID: <20110114065911.GA11086@us.ibm.com>
References: <4D2BAFD4.1080400@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D2BAFD4.1080400-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| Folks,
| 
| I just pushed out a new v23-rc1 branch of linux-cr. This one is
| rebased to 2.6.37, and contains nearly all the patches pulled
| on v22-dev. I only gave it a brief test drive... feel free to 
| throw all your ammo it.

Oren,

We need the file_tty() helper to get the tty object from the file pointer
(otherwise we will be off by 4 bytes and fail tty_paranoia_check() in
tty_file_checkpoint()).

Thanks,

Sukadev

diff --git a/drivers/tty/tty_io.c b/drivers/tty/tty_io.c
index c89f055..6aa458e 100644
--- a/drivers/tty/tty_io.c
+++ b/drivers/tty/tty_io.c
@@ -2781,7 +2784,7 @@ static int tty_file_checkpoint(struct ckpt_ctx *ctx, struc
        int master_objref, slave_objref;
        int ret;
 
-       tty = (struct tty_struct *)file->private_data;
+       tty = file_tty(file);
        inode = file->f_path.dentry->d_inode;
        if (tty_paranoia_check(tty, inode, "tty_file_checkpoint"))
                return -EIO;
