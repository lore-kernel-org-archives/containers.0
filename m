From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [Patch v2 1/3] fs: add filp_clone_open API
Date: Tue, 08 Mar 2016 06:19:35 -0500
Message-ID: <1457435975.632.39.camel__35443.2009779432$1457435995$gmane$org@HansenPartnership.com>
References: <1456428890.2377.2.camel@HansenPartnership.com>
	<1456429008.2377.4.camel@HansenPartnership.com>
	<20160308091705.GB2189@mguzik>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160308091705.GB2189@mguzik>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2016-03-08 at 10:17 +0100, Mateusz Guzik wrote:
> On Thu, Feb 25, 2016 at 11:36:48AM -0800, James Bottomley wrote:
> > I need an API that allows me to obtain a clone of the current file
> > pointer to pass in to an exec handler.  I've labelled this as an
> > internal API because I can't see how it would be useful outside of
> > the
> > fs subsystem.  The use case will be a persistent binfmt_misc
> > handler.
> > 
> > Signed-off-by: James Bottomley <
> > James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
> > ---
> >  fs/internal.h |  1 +
> >  fs/open.c     | 20 ++++++++++++++++++++
> >  2 files changed, 21 insertions(+)
> > 
> > diff --git a/fs/internal.h b/fs/internal.h
> > index b71deee..c8ca0c9 100644
> > --- a/fs/internal.h
> > +++ b/fs/internal.h
> > @@ -108,6 +108,7 @@ extern long do_handle_open(int mountdirfd,
> >  			   struct file_handle __user *ufh, int
> > open_flag);
> >  extern int open_check_o_direct(struct file *f);
> >  extern int vfs_open(const struct path *, struct file *, const
> > struct cred *);
> > +extern struct file *filp_clone_open(struct file *);
> >  
> >  /*
> >   * inode.c
> > diff --git a/fs/open.c b/fs/open.c
> > index 55bdc75..bb7ffd6 100644
> > --- a/fs/open.c
> > +++ b/fs/open.c
> > @@ -1004,6 +1004,26 @@ struct file *file_open_root(struct dentry
> > *dentry, struct vfsmount *mnt,
> >  }
> >  EXPORT_SYMBOL(file_open_root);
> >  
> > +struct file *filp_clone_open(struct file *oldfile)
> > +{
> > +	struct file *file;
> > +	int retval;
> > +
> > +	file = get_empty_filp();
> > +	if (IS_ERR(file))
> > +		return file;
> > +
> > +	file->f_flags = oldfile->f_flags;
> > +	retval = vfs_open(&oldfile->f_path, file, oldfile
> > ->f_cred);
> > +	if (retval) {
> > +		fput(file);
> 
> You likely want put_file instead, although if I read it right this is
> only cosmetics for consistency with dentry_open.

get_empty_filp() is always paired with fput().  There isn't a
put_file(); there's a put_files_struct() but that's for something
different.

> Also vast majority of the file uses 'error' instead of 'retval'. Any
> reason to deviate here?

it mirrors the close routines which also use retval.

James


> > +		return ERR_PTR(retval);
> > +	}
> > +
> > +	return file;
> > +}
> > +EXPORT_SYMBOL(filp_clone_open);
> > +
> >  long do_sys_open(int dfd, const char __user *filename, int flags,
> > umode_t mode)
> >  {
> >  	struct open_flags op;
> > -- 
> > 2.6.2
> > 
> 
