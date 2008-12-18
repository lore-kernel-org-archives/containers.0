From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] ipc namespaces: implement support for posix msqueues
Date: Thu, 18 Dec 2008 15:36:33 -0600
Message-ID: <20081218213633.GA20733@us.ibm.com>
References: <20081217175513.GA23291@us.ibm.com>
	<20081217175549.GB23331@us.ibm.com>
	<20081217212521.GA14740@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081217212521.GA14740-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> |  static int mqueue_get_sb(struct file_system_type *fs_type,
> |  			 int flags, const char *dev_name,
> |  			 void *data, struct vfsmount *mnt)
> |  {
> | -	return get_sb_single(fs_type, flags, data, mqueue_fill_super, mnt);
> | +	if (flags & MS_KERNMOUNT)
> | +		return get_sb_single_ns(fs_type, flags, data,
> | +					mqueue_fill_super, mnt);
> | +	return get_sb_single_ns(fs_type, flags, current->nsproxy->ipc_ns,
> | +				mqueue_fill_super, mnt);
> 
> nit. This maybe easier to read with an ns local variable and a single
> call to get_sb_single_ns().

The first time I read this I completely misunderstood what you
meant.  Yes, that's nicer.  Thanks for taking a look.

New version coming tomorrow (I want to stress this a bit).

thanks,
-serge
