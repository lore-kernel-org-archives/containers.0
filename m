From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 16/27] userns: Convert vfs posix_acl support to use kuids
	and kgids
Date: Tue, 09 Oct 2012 14:46:28 -0700
Message-ID: <878vbf5nez.fsf@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
	<1348105949-25454-16-git-send-email-ebiederm@xmission.com>
	<20121009204433.GB24622@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121009204433.GB24622-+0h/O2h83AeN3ZZ/Hiejyg@public.gmane.org> (Jan Kara's message of
	"Tue, 9 Oct 2012 22:44:33 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org> writes:

> On Wed 19-09-12 18:52:18, Eric W. Biederman wrote:
>> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> 
>> - In setxattr if we are setting a posix acl convert uids and gids from
>>   the current user namespace into the initial user namespace, before
>>   the xattrs are passed to the underlying filesystem.
>> 
>>   Untranslatable uids and gids are represented as -1 which
>>   posix_acl_from_xattr will represent as INVALID_UID or INVALID_GID.
>>   posix_acl_valid will fail if an acl from userspace has any
>>   INVALID_UID or INVALID_GID values.  In net this guarantees that
>>   untranslatable posix acls will not be stored by filesystems.
>> 
>> - In getxattr if we are reading a posix acl convert uids and gids from
>>   the initial user namespace into the current user namespace.
>> 
>>   Uids and gids that can not be tranlsated into the current user namespace
>>   will be represented as -1.
>> 
>> - Replace e_id in struct posix_acl_entry with an anymouns union of
>>   e_uid and e_gid.  For the short term retain the e_id field
>>   until all of the users are converted.
>> 
>> - Don't set struct posix_acl.e_id in the cases where the acl type
>>   does not use e_id.  Greatly reducing the use of ACL_UNDEFINED_ID.
>> 
>> - Rework the ordering checks in posix_acl_valid so that I use kuid_t
>>   and kgid_t types throughout the code, and so that I don't need
>>   arithmetic on uid and gid types.
>> 
>> Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
>> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
>> Cc: Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>
>> Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
>> Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
>> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>   I know this got merged but I got to seriously looking into it only now
> and frankly I think the push was a hurried one...


>> diff --git a/fs/xattr.c b/fs/xattr.c
>> index 4d45b71..c111745 100644
>> --- a/fs/xattr.c
>> +++ b/fs/xattr.c
>> @@ -20,6 +20,7 @@
>>  #include <linux/fsnotify.h>
>>  #include <linux/audit.h>
>>  #include <linux/vmalloc.h>
>> +#include <linux/posix_acl_xattr.h>
>>  
>>  #include <asm/uaccess.h>
>>  
>> @@ -347,6 +348,9 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
>>  			error = -EFAULT;
>>  			goto out;
>>  		}
>> +		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
>> +		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
>> +			posix_acl_fix_xattr_from_user(kvalue, size);
>>  	}
>>  
>>  	error = vfs_setxattr(d, kname, kvalue, size, flags);
>> @@ -450,6 +454,9 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
>>  
>>  	error = vfs_getxattr(d, kname, kvalue, size);
>>  	if (error > 0) {
>> +		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
>> +		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
>> +			posix_acl_fix_xattr_to_user(kvalue, size);
>>  		if (size && copy_to_user(value, kvalue, error))
>>  			error = -EFAULT;
>>  	} else if (error == -ERANGE && size >= XATTR_SIZE_MAX) {
>> diff --git a/fs/xattr_acl.c b/fs/xattr_acl.c
>> index 69d06b0..bf472ca 100644
>> --- a/fs/xattr_acl.c
>> +++ b/fs/xattr_acl.c
>> @@ -9,7 +9,65 @@
>>  #include <linux/fs.h>
>>  #include <linux/posix_acl_xattr.h>
>>  #include <linux/gfp.h>
>> +#include <linux/user_namespace.h>
>>  
>> +/*
>> + * Fix up the uids and gids in posix acl extended attributes in place.
>> + */
>> +static void posix_acl_fix_xattr_userns(
>> +	struct user_namespace *to, struct user_namespace *from,
>> +	void *value, size_t size)
>> +{
>> +	posix_acl_xattr_header *header = (posix_acl_xattr_header *)value;
>> +	posix_acl_xattr_entry *entry = (posix_acl_xattr_entry *)(header+1), *end;
>> +	int count;
>> +	kuid_t uid;
>> +	kgid_t gid;
>> +
>> +	if (!value)
>> +		return;
>> +	if (size < sizeof(posix_acl_xattr_header))
>> +		return;
>> +	if (header->a_version != cpu_to_le32(POSIX_ACL_XATTR_VERSION))
>> +		return;
>> +
>> +	count = posix_acl_xattr_count(size);
>> +	if (count < 0)
>> +		return;
>> +	if (count == 0)
>> +		return;
>> +
>> +	for (end = entry + count; entry != end; entry++) {
>> +		switch(le16_to_cpu(entry->e_tag)) {
>> +		case ACL_USER:
>> +			uid = make_kuid(from, le32_to_cpu(entry->e_id));

  
>   This should have some error checking I guess... The initial checks done
> in posix_acl_from_xattr() are for init_user_ns (why?) and only duplicated
> in posix_acl_valid().

The flow from userspace:
  posix_acl_fix_xattr_from_user
  posix_acl_from_xattr
  posix_acl_valid

The flow to userspace:
  posix_acl_to_xattr
  posix_acl_fix_xattr_to_user

The existence of the posix_acl_fix_xattr_from_user and
posix_fix_xattr_to_user ensure that filesystems only see xattrs encoded
in the initial user namespace. Which is why posix_acl_from_xattr only
takes init_user_ns as a parameter.

How filesystems handle xattrs that deal with acls is spread all across
the map.  Some filesystems do the reasonable thing and translate the
xattr from userspace into an acl and then translate the acl into their
on-disk format.  Other filesystems just stuff the acl onto the disk or
onto the fileserver without looking at it.

As for checks my interpretation was that a filesystem should already
be calling posix_acl_from_xattr and posix_acl_valid, and that
duplicating those checks in posix_acl_fix_xattr_to/from_user would
be redundnant and confusing.

What does happen is that any uid or gid that does not map gets
translated into -1, which should always fail the latter sanity
check.

>> +			entry->e_id = cpu_to_le32(from_kuid(to, uid));
>> +			break;
>> +		case ACL_GROUP:
>> +			gid = make_kgid(from, le32_to_cpu(entry->e_id));
>> +			entry->e_id = cpu_to_le32(from_kuid(to, uid));
>                                              here should be gid ^^^
Ugh.  Yes.  That is a very real bug. :(  The &init_user_ns short circuit
likely protects against regressions but I will fix this.

>> +			break;
>> +		default:
>> +			break;
>> +		}
>> +	}
>> +}
> Also what about the following scenario:
>
> We have namespace A with user U1 and namespace B which does not have a
> valid representation for U1.

> There is a file F which can be seen from both
> namespaces. In namespace A we create acl for user U1 attached to F. Now in
> namespace B we modify the acl via setfacl(1) command. What it does is
> getxattr(2) - returns mangled acl because U1 has no representation in B. We
> add something to xattr and call setxattr(2) - results in removing the
> original acl for U1 and instead adding acl for uid -1. That is a security
> bug I'd say.

What will happen in most reasonable filesystems is that
posix_acl_from_xattr or posix_acl_valid will see the -1 for the unmapped
uid or gid.  Realize that the -1 does not map, and return -EINVAL before
setting the xattr.  So I do not think the failure mode you are worried
about can happen.

Looking back at this I realize I have pretty much repeated my changelog
description.  Hopefully saying the same thing in different words makes
it clearer.

Eric
