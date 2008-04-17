From: Matthew Helsley <matthltc@us.ibm.com>
Subject: Re: [PATCH]: Factor out PTY index allocation
Date: Thu, 17 Apr 2008 16:53:49 -0700
Message-ID: <1208476430.5134.9.camel@localhost.localdomain>
References: <20080416221723.GB7112@us.ibm.com>
	 <20080417141725.7cd8e50e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756703AbYDQXyU@vger.kernel.org>
In-Reply-To: <20080417141725.7cd8e50e.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: sukadev@us.ibm.com, serue@us.ibm.com, ebiederm@xmission.com, hpa@zytor.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


On Thu, 2008-04-17 at 14:17 -0700, Andrew Morton wrote:
> On Wed, 16 Apr 2008 15:17:23 -0700
> sukadev@us.ibm.com wrote:
> 
> > Factor out the code used to allocate/free a pts index into new interfaces,
> > devpts_new_index() and devpts_kill_index().  This localizes the external
> > data structures used in managing the pts indices.
> 
> err...
> 
> > -	mutex_lock(&allocated_ptys_lock);
> > +	down(&allocated_ptys_lock);
> 
> Why the mutex-to-semaphore conversion?

The patch series was originally developed for 2.6.22 -- prior to the
semaphore -> mutex migration. This appears to be a mistake in
forward-porting the series.

Acked-by: Matt Helsley <matthltc@us.ibm.com>

> 
> --- a/fs/devpts/inode.c~devpts-factor-out-pty-index-allocation-fix
> +++ a/fs/devpts/inode.c
> @@ -17,6 +17,7 @@
>  #include <linux/namei.h>
>  #include <linux/mount.h>
>  #include <linux/tty.h>
> +#include <linux/mutex.h>
>  #include <linux/idr.h>
>  #include <linux/devpts_fs.h>
>  #include <linux/parser.h>
> @@ -29,7 +30,7 @@
> 
>  extern int pty_limit;			/* Config limit on Unix98 ptys */
>  static DEFINE_IDR(allocated_ptys);
> -static DECLARE_MUTEX(allocated_ptys_lock);
> +static DEFINE_MUTEX(allocated_ptys_lock);
> 
>  static struct vfsmount *devpts_mnt;
>  static struct dentry *devpts_root;
> @@ -186,10 +187,10 @@ retry:
>  		return -ENOMEM;
>  	}
> 
> -	down(&allocated_ptys_lock);
> +	mutex_lock(&allocated_ptys_lock);
>  	idr_ret = idr_get_new(&allocated_ptys, NULL, &index);
>  	if (idr_ret < 0) {
> -		up(&allocated_ptys_lock);
> +		mutex_unlock(&allocated_ptys_lock);
>  		if (idr_ret == -EAGAIN)
>  			goto retry;
>  		return -EIO;
> @@ -197,18 +198,18 @@ retry:
> 
>  	if (index >= pty_limit) {
>  		idr_remove(&allocated_ptys, index);
> -		up(&allocated_ptys_lock);
> +		mutex_unlock(&allocated_ptys_lock);
>  		return -EIO;
>  	}
> -	up(&allocated_ptys_lock);
> +	mutex_unlock(&allocated_ptys_lock);
>  	return index;
>  }
> 
>  void devpts_kill_index(int idx)
>  {
> -	down(&allocated_ptys_lock);
> +	mutex_lock(&allocated_ptys_lock);
>  	idr_remove(&allocated_ptys, idx);
> -	up(&allocated_ptys_lock);
> +	mutex_unlock(&allocated_ptys_lock);
>  }
> 
>  int devpts_pty_new(struct tty_struct *tty)
> _
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
