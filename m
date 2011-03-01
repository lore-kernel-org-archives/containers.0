From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 09/10] userns: check user namespace for task->file uid
	equivalence checks
Date: Tue, 1 Mar 2011 17:07:29 -0600
Message-ID: <20110301230729.GA28694__20630.5477688604$1299020903$gmane$org@hallyn.com>
References: <20110224150150.GA8262@mail.hallyn.com>
	<20110224150315.GI8262@mail.hallyn.com>
	<1299018281.461.16.camel@tp-t61>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1299018281.461.16.camel@tp-t61>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> On Thu, 2011-02-24 at 15:03 +0000, Serge E. Hallyn wrote:
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1446,8 +1446,13 @@ enum {
> >  #define put_fs_excl() atomic_dec(&current->fs_excl)
> >  #define has_fs_excl() atomic_read(&current->fs_excl)
> >  
> > -#define is_owner_or_cap(inode)	\
> > -	((current_fsuid() == (inode)->i_uid) || capable(CAP_FOWNER))
> > +/*
> > + * until VFS tracks user namespaces for inodes, just make all files
> > + * belong to init_user_ns
> > + */
> > +extern struct user_namespace init_user_ns;
> 
> init_user_ns gets declared in fs.h in this patch, utsname.h in patch #1,
> capability.h in #2, ipc_namespace.h in #7.  Could this declaration be
> kept to a single header?
> 

ipc/msgutil.c includes security.h which includes fs.h, so we should be
able to drop the one in ipc_namespace.h.  The one in utsname.h is
there for init/version.c and needed AFAICS.

The one in capability.h should be able to go when has_capability* are
turned into functions.  They couldn't be turned into static functions
in capability.h (left as exercise for reader), but they can be made
full-fledged functions in kernel/capability.c.  I will do that in a
follow-on patch and try to remove the extra init_user_ns defines as
well.

thanks,
-serge
