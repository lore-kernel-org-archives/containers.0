From: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Subject: Re: [PATCH 03/11] fs: Allow superblock owner to change ownership of
	inodes
Date: Tue, 9 Jan 2018 16:10:54 +0100
Message-ID: <CANxcAMvDQFH0g5PPnVZ3p2Tei04N+8fNf0pk02DrfTkBHjjrPQ__35422.9614990347$1515510565$gmane$org@mail.gmail.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<ac3d34002d7690f6ca5928b57b7fc4d707104b04.1512041070.git.dongsu@kinvolk.io>
	<20180105192407.GF22430@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180105192407.GF22430-B4tOwbsTzaBolqkO4TVVkw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

On Fri, Jan 5, 2018 at 8:24 PM, Luis R. Rodriguez <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Fri, Dec 22, 2017 at 03:32:27PM +0100, Dongsu Park wrote:
>> diff --git a/fs/attr.c b/fs/attr.c
>> index 12ffdb6f..bf8e94f3 100644
>> --- a/fs/attr.c
>> +++ b/fs/attr.c
>> @@ -18,6 +18,30 @@
>>  #include <linux/evm.h>
>>  #include <linux/ima.h>
>>
>> +static bool chown_ok(const struct inode *inode, kuid_t uid)
>> +{
>> +     if (uid_eq(current_fsuid(), inode->i_uid) &&
>> +         uid_eq(uid, inode->i_uid))
>> +             return true;
>> +     if (capable_wrt_inode_uidgid(inode, CAP_CHOWN))
>> +             return true;
>> +     if (ns_capable(inode->i_sb->s_user_ns, CAP_CHOWN))
>> +             return true;
>> +     return false;
>> +}
>> +
>> +static bool chgrp_ok(const struct inode *inode, kgid_t gid)
>> +{
>> +     if (uid_eq(current_fsuid(), inode->i_uid) &&
>> +         (in_group_p(gid) || gid_eq(gid, inode->i_gid)))
>> +             return true;
>> +     if (capable_wrt_inode_uidgid(inode, CAP_CHOWN))
>> +             return true;
>> +     if (ns_capable(inode->i_sb->s_user_ns, CAP_CHOWN))
>> +             return true;
>> +     return false;
>> +}
>> +
>>  /**
>>   * setattr_prepare - check if attribute changes to a dentry are allowed
>>   * @dentry:  dentry to check
>> @@ -52,17 +76,11 @@ int setattr_prepare(struct dentry *dentry, struct iattr *attr)
>>               goto kill_priv;
>>
>>       /* Make sure a caller can chown. */
>> -     if ((ia_valid & ATTR_UID) &&
>> -         (!uid_eq(current_fsuid(), inode->i_uid) ||
>> -          !uid_eq(attr->ia_uid, inode->i_uid)) &&
>> -         !capable_wrt_inode_uidgid(inode, CAP_CHOWN))
>> +     if ((ia_valid & ATTR_UID) && !chown_ok(inode, attr->ia_uid))
>>               return -EPERM;
>
> I think this patch would read much better and easier to review if it was
> split up by first adding the helpers, and then extending them afterwards.

I'm fine with splitting it up into multiple patches, if the original author
Eric agrees.

>>       /* Make sure caller can chgrp. */
>> -     if ((ia_valid & ATTR_GID) &&
>> -         (!uid_eq(current_fsuid(), inode->i_uid) ||
>> -         (!in_group_p(attr->ia_gid) && !gid_eq(attr->ia_gid, inode->i_gid))) &&
>> -         !capable_wrt_inode_uidgid(inode, CAP_CHOWN))
>> +     if ((ia_valid & ATTR_GID) && !chgrp_ok(inode, attr->ia_gid))
>>               return -EPERM;
>>
>>       /* Make sure a caller can chmod. */
>> diff --git a/fs/proc/base.c b/fs/proc/base.c
>> index 31934cb9..9d50ec92 100644
>> --- a/fs/proc/base.c
>> +++ b/fs/proc/base.c
>> @@ -665,10 +665,17 @@ int proc_setattr(struct dentry *dentry, struct iattr *attr)
>>  {
>>       int error;
>>       struct inode *inode = d_inode(dentry);
>> +     struct user_namespace *s_user_ns;
>>
>>       if (attr->ia_valid & ATTR_MODE)
>>               return -EPERM;
>>
>> +     /* Don't let anyone mess with weird proc files */
>> +     s_user_ns = inode->i_sb->s_user_ns;
>> +     if (!kuid_has_mapping(s_user_ns, inode->i_uid) ||
>> +         !kgid_has_mapping(s_user_ns, inode->i_gid))
>> +             return -EPERM;
>> +
>>       error = setattr_prepare(dentry, attr);
>>       if (error)
>>               return error;
>
> Are we sure proc is the only special one? How was it observed first that this was
> require for proc? Has anyone tried fuzzing by trying this op with a slew of other
> filesystems on all files?

From my limited knowledge about procfs, I suppose that procfs is a little
different from ordinary filesystems. Procfs is not exactly namespaced,
it has many inconsistencies. Some files under /proc should be owned by the
global root, regardless of user namespaces. That's why we need to handle such
special cases for proc. As it has been historically like that since the
beginning, it's hard to change it fundamentally.

However, you have good points. Other than procfs, there could be other
filesystems that have potential issues when relaxing privileges. Question is
how we can be sure that there's no hidden issues. From my understanding,
usually we could run testsuites like LTP
(https://github.com/linux-test-project/ltp.git) to avoid such regressions.
Today I have run LTP tests for fs & containers, with the patchset included.
It seemed to work fine without failures. Obviously it doesn't mean that it's
completely bug-free, when we are talking about unknown issues.
Please let me know if there are other good ways to figure out potential issues.

Thanks,
Dongsu

>   Luis
