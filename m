From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/10] user namespaces: enforce user namespaces for
	file permission
Date: Fri, 22 Aug 2008 19:57:15 -0500
Message-ID: <20080823005715.GB21064@us.ibm.com>
References: <20080822194513.GA10262@us.ibm.com>
	<20080822194609.GD10360@us.ibm.com>
	<m1ej4glsen.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1ej4glsen.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Add a user_ns to the sb.  It is always set to the user_ns of the task which
> > mounted the sb.
> >
> > Define 3 new super_operations.  convert_uid() and convert_gid() take a uid
> > or gid from an inode on the sb's fs, and attempt to convert them into ids
> > meaningful in the user namespace passed in, which presumably is current's.
> > is_capable() checks whether current has the requested capability with respect
> > to the sb's fs, which is dependent upon the relationship between current's
> > user_ns and those which the sb knows about.
> >
> > If the sb isn't user ns aware - which none are right now - then the new
> > super_operations won't be defined.  If in that case current and sb have
> > different user namespaces, then the userids can't be compared.
> >
> > If current's and sb's userids can't be compared, then current will get
> > 'user other' (we usually say 'nobody') permissions to the inode.
> >
> > Changelog:
> > 	Aug 5: send the whole inode to the super_operations.
> >
> > Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  fs/namei.c         |   29 +++++++++++++++++++++++---
> >  fs/super.c         |    3 ++
> >  include/linux/fs.h |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 83 insertions(+), 4 deletions(-)
> >
> > diff --git a/fs/namei.c b/fs/namei.c
> > index 4ea63ed..6bf5446 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -183,10 +183,27 @@ int generic_permission(struct inode *inode, int mask,
> >  		int (*check_acl)(struct inode *inode, int mask))
> >  {
> >  	umode_t			mode = inode->i_mode;
> > +	uid_t			iuid;
> > +	gid_t			igid;
> > +	int			ret;
> > +	int			good_userns = 1;
> > +
> > +	ret = s_convert_uid_gid(inode, current->user->user_ns,
> > +						&iuid, &igid);
> > +	if (!ret)
> > +		good_userns = 0;
> >  
> >  	mask &= MAY_READ | MAY_WRITE | MAY_EXEC;
> >  
> > -	if (current->fsuid == inode->i_uid)
> > +	/*
> > +	 * If we're not in the inode's user namespace, we get
> > +	 * user nobody permissions, and we ignore acls
> > +	 * (bc serge doesn't know how to handle acls in this case)
> > +	 */
> > +	if (!good_userns)
> > +		goto check;
> > +
> > +	if (current->fsuid == iuid)
> >  		mode >>= 6;
> >  	else {
> >  		if (IS_POSIXACL(inode) && (mode & S_IRWXG) && check_acl) {
> > @@ -197,15 +214,18 @@ int generic_permission(struct inode *inode, int mask,
> >  				return error;
> >  		}
> >  
> > -		if (in_group_p(inode->i_gid))
> > +		if (in_group_p(igid))
> >  			mode >>= 3;
> >  	}
> >  
> > +check:
> >  	/*
> >  	 * If the DACs are ok we don't need any capability check.
> >  	 */
> >  	if ((mask & ~mode) == 0)
> >  		return 0;
> > +	if (!good_userns)
> > +		return -EACCES;
> >  
> >   check_capabilities:
> >  	/*
> > @@ -214,14 +234,15 @@ int generic_permission(struct inode *inode, int mask,
> >  	 */
> >  	if (!(mask & MAY_EXEC) ||
> >  	    (inode->i_mode & S_IXUGO) || S_ISDIR(inode->i_mode))
> > -		if (capable(CAP_DAC_OVERRIDE))
> > +		if (s_is_capable(inode, current->user->user_ns,
> > +						CAP_DAC_OVERRIDE))
> >  			return 0;
> >  
> >  	/*
> >  	 * Searching includes executable on directories, else just read.
> >  	 */
> >  	if (mask == MAY_READ || (S_ISDIR(inode->i_mode) && !(mask & MAY_WRITE)))
> > -		if (capable(CAP_DAC_READ_SEARCH))
> > + if (s_is_capable(inode, current->user->user_ns, CAP_DAC_READ_SEARCH))
> >  			return 0;
> >  
> >  	return -EACCES;
> > diff --git a/fs/super.c b/fs/super.c
> > index e931ae9..3559637 100644
> > --- a/fs/super.c
> > +++ b/fs/super.c
> > @@ -38,6 +38,7 @@
> >  #include <linux/kobject.h>
> >  #include <linux/mutex.h>
> >  #include <linux/file.h>
> > +#include <linux/user_namespace.h>
> >  #include <asm/uaccess.h>
> >  #include "internal.h"
> >  
> > @@ -93,6 +94,7 @@ static struct super_block *alloc_super(struct file_system_type
> > *type)
> >  		s->s_qcop = sb_quotactl_ops;
> >  		s->s_op = &default_op;
> >  		s->s_time_gran = 1000000000;
> > +		s->user_ns = get_user_ns(current->user->user_ns);
> >  	}
> >  out:
> >  	return s;
> > @@ -109,6 +111,7 @@ static inline void destroy_super(struct super_block *s)
> >  	security_sb_free(s);
> >  	kfree(s->s_subtype);
> >  	kfree(s->s_options);
> > +	put_user_ns(s->user_ns);
> >  	kfree(s);
> >  }
> >  
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 580b513..bb58c2e 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1128,6 +1128,11 @@ struct super_block {
> >  	 * generic_show_options()
> >  	 */
> >  	char *s_options;
> > +
> > +	/*
> > +	 * namespace of the user which mounted the sb
> > +	 */
> > +	struct user_namespace *user_ns;
> 
> We should make it clear that this is a default, and not something
> a filesystem must use, just something a filesystem may use.
> >  };
> >  
> >  extern struct timespec current_fs_time(struct super_block *sb);
> > @@ -1320,6 +1325,9 @@ struct super_operations {
> >  	int (*remount_fs) (struct super_block *, int *, char *);
> >  	void (*clear_inode) (struct inode *);
> >  	void (*umount_begin) (struct super_block *);
> > +	int (*is_capable) (struct user_namespace *, struct inode *, int);
> > +	uid_t (*convert_uid_gid)(struct user_namespace *, struct inode *,
> > +						uid_t *, gid_t *);
> >  
> I'm not convinced either of those methods makes sense.
> >  	int (*show_options)(struct seq_file *, struct vfsmount *);
> >  	int (*show_stats)(struct seq_file *, struct vfsmount *);
> > @@ -1330,6 +1338,53 @@ struct super_operations {
> >  };
> >  
> >  /*
> > + * In the next 3, i'm passing the user_ns in so that I don't need
> > + * to know how to dereference struct user her (which would require
> > + * #including sched.h).
> > + * Note in particular that for instance in s_convert_uid, the uid is the
> > + * inode->i_uid, while user_ns is current->user->user_ns.
> > + */
> > +
> > +/*
> > + * s_convert_uid: attempt to translate the inode's stored
> > + * uid to a uid meaningful in user_ns passed in
> > + * If possible, store the result in reuid and return 1
> > + * Otherwise, return 0, meaningful the uid cannot be translated
> > + */
> > +static inline int s_convert_uid_gid(struct inode *ino,
> > +		struct user_namespace *user_ns, uid_t *retuid, gid_t *retgid)
> > +{
> > +	struct super_block *sb = ino->i_sb;
> > +
> > +	if (sb->user_ns == user_ns) {
> > +		*retuid = ino->i_uid;
> > +		*retgid = ino->i_gid;
> > +		return 1;
> > +	}
> > +	if (sb->s_op->convert_uid_gid)
> > +		return sb->s_op->convert_uid_gid(user_ns, ino, retuid, retgid);
> 
> We should be able to just use the existing inode->i_op->getattr.
> Especially as that method will have to be updated anyway..

That might make sense.  I guess the problem is I started trying to
handle generic permission.  But I don't need to...  the fs can
provide its own permission, else we do the simple userns check.

> > +	return 0;
> > +}
> > +
> > +/*
> > + * s_is_capable: check whether current is capable with respect
> > + * to the filesystem represented by sb.
> > + *
> > + * return 0 if false, 1 if true
> > + */
> ???  Capable should be with respect to a user namespace not with
> respect to a filesystem.

The user ns comes from the current task.  The fs must decide whether
current->user->uid in current->user->user_ns has capabilities over
the target file.  Only the fs can erify that the user is really
uid=0 or has CAP_DAC_OVERRIDE, for instance, with respect to the file.

-serge
