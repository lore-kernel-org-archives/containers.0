From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH]: Factor out PTY index allocation
Date: Thu, 17 Apr 2008 23:08:17 +0200
Message-ID: <4807BC41.50406@gmail.com>
References: <20080416221723.GB7112@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755659AbYDQVIl@vger.kernel.org>
In-Reply-To: <20080416221723.GB7112@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@us.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, serue@us.ibm.com, "Eric W. Biederman" <ebiederm@xmission.com>, hpa@zytor.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 04/17/2008 12:17 AM, sukadev@us.ibm.com wrote:
> We noticed this while working on pts namespaces and believe this might
> be an useful change even as we rework our pts/device namespace approach.
> 
> ---
> 
> From: Sukadev Bhattiprolu <sukadev@us.ibm.com>
> Subject: [PATCH]: Factor out PTY index allocation
> 
> Factor out the code used to allocate/free a pts index into new interfaces,
> devpts_new_index() and devpts_kill_index().  This localizes the external
> data structures used in managing the pts indices.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>
> Signed-off-by: Serge Hallyn<serue@us.ibm.com>
> Signed-off-by: Matt Helsley<matthltc@us.ibm.com>
> 
> ---
>  drivers/char/tty_io.c     |   40 ++++++----------------------------------
>  fs/devpts/inode.c         |   42 +++++++++++++++++++++++++++++++++++++++++-
>  include/linux/devpts_fs.h |    4 ++++
>  3 files changed, 51 insertions(+), 35 deletions(-)
[...]
> Index: 2.6.25-rc8-mm2/drivers/char/tty_io.c
> ===================================================================
> --- 2.6.25-rc8-mm2.orig/drivers/char/tty_io.c	2008-04-16 09:51:11.000000000 -0700
> +++ 2.6.25-rc8-mm2/drivers/char/tty_io.c	2008-04-16 09:51:15.000000000 -0700
> @@ -137,9 +136,6 @@ EXPORT_SYMBOL(tty_mutex);
>  
>  #ifdef CONFIG_UNIX98_PTYS
>  extern struct tty_driver *ptm_driver;	/* Unix98 pty masters; for /dev/ptmx */
> -extern int pty_limit;			/* Config limit on Unix98 ptys */
> -static DEFINE_IDR(allocated_ptys);
> -static DEFINE_MUTEX(allocated_ptys_lock);
[...]
> Index: 2.6.25-rc8-mm2/fs/devpts/inode.c
> ===================================================================
> --- 2.6.25-rc8-mm2.orig/fs/devpts/inode.c	2008-02-27 15:17:59.000000000 -0800
> +++ 2.6.25-rc8-mm2/fs/devpts/inode.c	2008-04-16 09:51:15.000000000 -0700
> @@ -26,6 +27,10 @@
>  
>  #define DEVPTS_DEFAULT_MODE 0600
>  
> +extern int pty_limit;			/* Config limit on Unix98 ptys */
> +static DEFINE_IDR(allocated_ptys);
> +static DECLARE_MUTEX(allocated_ptys_lock);

Ugh, why mutex->semaphore conversion?
