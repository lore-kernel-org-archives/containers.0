From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC/PATCH 1/8]: CGroup Files: Add locking mode to cgroups control
	files
Date: Tue, 13 May 2008 17:23:29 +0800
Message-ID: <48295E11.2000003__41462.910854216$1210670907$gmane$org@cn.fujitsu.com>
References: <20080513063707.049448000@menage.corp.google.com>
	<20080513071522.133586000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080513071522.133586000-B63HFAS8fGlSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org wrote:
> Different cgroup files have different stability requirements of the
> cgroups framework while the handler is running; currently most
> subsystems that don't have their own internal synchronization just
> call cgroup_lock()/cgroup_unlock(), which takes the global cgroup_mutex.
> 
> This patch introduces a range of locking modes that can be requested
> by a control file; currently these are all implemented internally by
> taking cgroup_mutex, but expressing the intention will make it simpler
> to move to a finer-grained locking scheme in the future.
> 
> Signed-off-by: Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 

This patch series looks good to me. I've reviewed those patches and didn't
see anything wrong, except a little comments below.

[..snap..]

> -static ssize_t cgroup_write_X64(struct cgroup *cgrp, struct cftype *cft,
> -				struct file *file,
> -				const char __user *userbuf,
> -				size_t nbytes, loff_t *unused_ppos)
> +
> +
> +/**
> + * cgroup_file_lock(). Helper for cgroup read/write methods.
> + * @cgrp:  the cgroup being acted on
> + * @cft:   the control file being written to or read from
> + * *write: true if the access is a write access.

s/*write/@write

[..snip..]

>  
>  static ssize_t cgroup_common_file_read(struct cgroup *cgrp,
> @@ -1518,16 +1580,21 @@ static ssize_t cgroup_file_read(struct f
>  	struct cftype *cft = __d_cft(file->f_dentry);
>  	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
>  
> -	if (!cft || cgroup_is_removed(cgrp))
> +	if (cgroup_is_removed(cgrp))
>  		return -ENODEV;
>  

This check seems redundant now.

> -	if (cft->read)
> -		return cft->read(cgrp, cft, file, buf, nbytes, ppos);
> -	if (cft->read_u64)
> -		return cgroup_read_u64(cgrp, cft, file, buf, nbytes, ppos);
> -	if (cft->read_s64)
> -		return cgroup_read_s64(cgrp, cft, file, buf, nbytes, ppos);
> -	return -EINVAL;
> +	if (cft->read) {
> +		/* Raw read function - no extra processing by cgroups */
> +		ssize_t retval = cgroup_file_lock(cgrp, cft, 0);
> +		if (!retval)
> +			retval = cft->read(cgrp, cft, file, buf, nbytes, ppos);
> +		cgroup_file_unlock(cgrp, cft, 0);
> +		return retval;
> +	}
> +	if (cft->read_u64 || cft->read_s64)
> +		return cgroup_read_X64(cgrp, cft, file, buf, nbytes, ppos);
> +	else
> +		return -EINVAL;
>  }
