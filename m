From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 1/3][cr][v2]: Define do_setlease()
Date: Wed, 26 May 2010 10:14:50 -0700
Message-ID: <20100526171450.GA26188__11744.5512711585$1274893956$gmane$org@us.ibm.com>
References: <1274836063-13271-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274836063-13271-2-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100526135256.GA25799@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100526135256.GA25799-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, matthew-Ztpu424NOJ8@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
| > Move the core functionality of fcntl_setlease() into a new function,
| > do_setlease(). do_setlease() is same as fcntl_setlease() except that
| > it takes an extra 'rem_lease' parameter. do_setlease() will be used
| > in a follow-on patch to checkpoint/restart file-leases.
| > 
| > Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| > ---
| >  fs/locks.c         |   27 ++++++++++++++++-----------
| >  include/linux/fs.h |    1 +
| >  2 files changed, 17 insertions(+), 11 deletions(-)
| > 
| > diff --git a/fs/locks.c b/fs/locks.c
| > index c62ab7f..4107295 100644
| > --- a/fs/locks.c
| > +++ b/fs/locks.c
| > @@ -1471,17 +1471,7 @@ int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
| >  }
| >  EXPORT_SYMBOL_GPL(vfs_setlease);
| > 
| > -/**
| > - *	fcntl_setlease	-	sets a lease on an open file
| > - *	@fd: open file descriptor
| > - *	@filp: file pointer
| > - *	@arg: type of lease to obtain
| > - *
| > - *	Call this fcntl to establish a lease on the file.
| > - *	Note that you also need to call %F_SETSIG to
| > - *	receive a signal when the lease is broken.
| > - */
| > -int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
| > +int do_setlease(unsigned int fd, struct file *filp, long arg, int rem_lease)
| >  {
| 
| Note that rem_lease arg here is int, but the value you're checkpointing
| and passing in is unsigned long.  So userspace on 64-bit could easily
| overflow that, though not sure to what end.  Also putting 'unsigned long'
| in the checkpoint_hdr.h is not in keeping with the rest of that file.

lease_break_time is an int, so I set rem_lease to int. But the unsigned long
in checkpoint_hdr.h is just wrong. I will change it __s32.

Sukadev
