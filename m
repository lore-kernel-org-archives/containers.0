From: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 16/27] userns: Convert vfs posix_acl support to use
	kuids and kgids
Date: Wed, 10 Oct 2012 13:42:27 +0200
Message-ID: <20121010114227.GC32581__48542.4084974968$1349869374$gmane$org@quack.suse.cz>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
	<1348105949-25454-16-git-send-email-ebiederm@xmission.com>
	<20121009204433.GB24622@quack.suse.cz>
	<878vbf5nez.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <878vbf5nez.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue 09-10-12 14:46:28, Eric W. Biederman wrote:
> Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org> writes:
> >> diff --git a/fs/xattr.c b/fs/xattr.c
> >> index 4d45b71..c111745 100644
> >> --- a/fs/xattr.c
> >> +++ b/fs/xattr.c
> >> @@ -20,6 +20,7 @@
> >>  #include <linux/fsnotify.h>
> >>  #include <linux/audit.h>
> >>  #include <linux/vmalloc.h>
> >> +#include <linux/posix_acl_xattr.h>
> >>  
> >>  #include <asm/uaccess.h>
> >>  
> >> @@ -347,6 +348,9 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
> >>  			error = -EFAULT;
> >>  			goto out;
> >>  		}
> >> +		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
> >> +		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
> >> +			posix_acl_fix_xattr_from_user(kvalue, size);
> >>  	}
> >>  
> >>  	error = vfs_setxattr(d, kname, kvalue, size, flags);
> >> @@ -450,6 +454,9 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
> >>  
> >>  	error = vfs_getxattr(d, kname, kvalue, size);
> >>  	if (error > 0) {
> >> +		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
> >> +		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
> >> +			posix_acl_fix_xattr_to_user(kvalue, size);
> >>  		if (size && copy_to_user(value, kvalue, error))
> >>  			error = -EFAULT;
> >>  	} else if (error == -ERANGE && size >= XATTR_SIZE_MAX) {
> >> diff --git a/fs/xattr_acl.c b/fs/xattr_acl.c
> >> index 69d06b0..bf472ca 100644
> >> --- a/fs/xattr_acl.c
> >> +++ b/fs/xattr_acl.c
> >> @@ -9,7 +9,65 @@
> >>  #include <linux/fs.h>
> >>  #include <linux/posix_acl_xattr.h>
> >>  #include <linux/gfp.h>
> >> +#include <linux/user_namespace.h>
> >>  
> >> +/*
> >> + * Fix up the uids and gids in posix acl extended attributes in place.
> >> + */
> >> +static void posix_acl_fix_xattr_userns(
> >> +	struct user_namespace *to, struct user_namespace *from,
> >> +	void *value, size_t size)
> >> +{
> >> +	posix_acl_xattr_header *header = (posix_acl_xattr_header *)value;
> >> +	posix_acl_xattr_entry *entry = (posix_acl_xattr_entry *)(header+1), *end;
> >> +	int count;
> >> +	kuid_t uid;
> >> +	kgid_t gid;
> >> +
> >> +	if (!value)
> >> +		return;
> >> +	if (size < sizeof(posix_acl_xattr_header))
> >> +		return;
> >> +	if (header->a_version != cpu_to_le32(POSIX_ACL_XATTR_VERSION))
> >> +		return;
> >> +
> >> +	count = posix_acl_xattr_count(size);
> >> +	if (count < 0)
> >> +		return;
> >> +	if (count == 0)
> >> +		return;
> >> +
> >> +	for (end = entry + count; entry != end; entry++) {
> >> +		switch(le16_to_cpu(entry->e_tag)) {
> >> +		case ACL_USER:
> >> +			uid = make_kuid(from, le32_to_cpu(entry->e_id));
> 
>   
> >   This should have some error checking I guess... The initial checks done
> > in posix_acl_from_xattr() are for init_user_ns (why?) and only duplicated
> > in posix_acl_valid().
> 
> The flow from userspace:
>   posix_acl_fix_xattr_from_user
>   posix_acl_from_xattr
>   posix_acl_valid
> 
> The flow to userspace:
>   posix_acl_to_xattr
>   posix_acl_fix_xattr_to_user
> 
> The existence of the posix_acl_fix_xattr_from_user and
> posix_fix_xattr_to_user ensure that filesystems only see xattrs encoded
> in the initial user namespace. Which is why posix_acl_from_xattr only
> takes init_user_ns as a parameter.
>
> How filesystems handle xattrs that deal with acls is spread all across
> the map.  Some filesystems do the reasonable thing and translate the
> xattr from userspace into an acl and then translate the acl into their
> on-disk format.  Other filesystems just stuff the acl onto the disk or
> onto the fileserver without looking at it.
> 
> As for checks my interpretation was that a filesystem should already
> be calling posix_acl_from_xattr and posix_acl_valid, and that
> duplicating those checks in posix_acl_fix_xattr_to/from_user would
> be redundnant and confusing.
> 
> What does happen is that any uid or gid that does not map gets
> translated into -1, which should always fail the latter sanity
> check.
  Ah, I got lost in the maze of xattr callbacks. You are right, things work
as you say. Thanks for explanation.
 
> >> +			entry->e_id = cpu_to_le32(from_kuid(to, uid));
> >> +			break;
> >> +		case ACL_GROUP:
> >> +			gid = make_kgid(from, le32_to_cpu(entry->e_id));
> >> +			entry->e_id = cpu_to_le32(from_kuid(to, uid));
> >                                              here should be gid ^^^
> Ugh.  Yes.  That is a very real bug. :(  The &init_user_ns short circuit
> likely protects against regressions but I will fix this.
  Actually, it will cause a regression because you will end up converting
uninitialized 'uid' variable.

> > Also what about the following scenario:
> >
> > We have namespace A with user U1 and namespace B which does not have a
> > valid representation for U1.
> 
> > There is a file F which can be seen from both
> > namespaces. In namespace A we create acl for user U1 attached to F. Now in
> > namespace B we modify the acl via setfacl(1) command. What it does is
> > getxattr(2) - returns mangled acl because U1 has no representation in B. We
> > add something to xattr and call setxattr(2) - results in removing the
> > original acl for U1 and instead adding acl for uid -1. That is a security
> > bug I'd say.
> 
> What will happen in most reasonable filesystems is that
> posix_acl_from_xattr or posix_acl_valid will see the -1 for the unmapped
> uid or gid.  Realize that the -1 does not map, and return -EINVAL before
> setting the xattr.  So I do not think the failure mode you are worried
> about can happen.
  Hum, so for filesystems as ext4 or xfs you won't be able to modify acls
from namespace B on F. I guess this is a modest option (although I can
imagine users will ponder hard to find out while setfacl fails without
apparent reason for some files) until someone cares enough to implement
something more clever. But filesystems such as ubifs or nfs4 will just
silently corrupt the acl. I don't think that is acceptable... I think you
should fix these to fail setting the acl or fail compilation with
CONFIG_USER_NS or whatever. Anything is better than corrupting on disk
data.

								Honza
-- 
Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
SUSE Labs, CR
