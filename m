From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 07/14] cgroup: reorganize css init / exit paths
Date: Mon, 12 Aug 2013 09:39:04 -0400
Message-ID: <20130812133904.GA15892@htj.dyndns.org>
References: <1375992831-4650-1-git-send-email-tj@kernel.org>
	<1375992831-4650-8-git-send-email-tj@kernel.org>
	<52084CC5.8050207@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52084CC5.8050207-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Aug 12, 2013 at 10:47:33AM +0800, Li Zefan wrote:
> > +		/* each css holds a ref to the cgroup and the parent css */
> >  		dget(dentry);
> >  		percpu_ref_get(&css->parent->refcnt);
> 
> We called dget() and percpu_ref_get() for each css unconditionally...
> 
> > -	}
> >  
> > -	/* hold a ref to the parent's dentry */
> > -	dget(parent->dentry);
> > -
> > -	/* creation succeeded, notify subsystems */
> > -	for_each_root_subsys(root, ss) {
> > -		err = online_css(ss, cgrp);
> > +		/* creation succeeded, notify subsystems */
> > +		err = online_css(css);
> >  		if (err)
> >  			goto err_destroy;
> 
> but now dget() and percpu_ref_get() may not be called for some css's,
> but the code in failure path is not updated accordingly, which seems
> wrong.

Heh, yeah, brainfart.  Will post the updated version.

Thanks.

-- 
tejun
