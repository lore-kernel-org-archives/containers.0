From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] userns: allow privileged user to operate locked mount
Date: Fri, 15 Nov 2013 08:47:09 +0800
Message-ID: <52856F0D.8090206@cn.fujitsu.com>
References: <1384327663-12032-1-git-send-email-gaofeng@cn.fujitsu.com>
	<874n7e4k78.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874n7e4k78.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/15/2013 07:50 AM, Eric W. Biederman wrote:
> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
> 
>> Privileged user should have rights to mount/umount/move
>> these even locked mount.
> 
> Hmm. This is pretty much a can't happen case, as the only exist in mount
> namespaces where the global root isn't the root.  How are you getting
> into this situation?  Using setns() ?
> 

Before, priviged user can use setns to set his mount namespace to the
container's mount namespace, and change container's mount directly.
this patch just gives back host the control of container.

> Why would we even care?
> 
> As implemented this patch does not handle nested user namespaces and
> that really worries me at a semantic level.
> 
> We don't want to design cases where we can create containers in
> containers.
> 
> Eric
> 
> 
>> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> ---
>>  fs/namespace.c | 14 ++++++++++----
>>  1 file changed, 10 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/namespace.c b/fs/namespace.c
>> index da5c494..7097fc7 100644
>> --- a/fs/namespace.c
>> +++ b/fs/namespace.c
>> @@ -1297,6 +1297,11 @@ static inline bool may_mount(void)
>>  	return ns_capable(current->nsproxy->mnt_ns->user_ns, CAP_SYS_ADMIN);
>>  }
>>  
>> +static inline bool may_mount_lock(struct mount *mnt)
>> +{
>> +	return !(mnt->mnt.mnt_flags & MNT_LOCKED) || capable(CAP_SYS_ADMIN);
>> +}
>> +
>>  /*
>>   * Now umount can handle mount points as well as block devices.
>>   * This is important for filesystems which use unnamed block devices.
>> @@ -1330,7 +1335,7 @@ SYSCALL_DEFINE2(umount, char __user *, name, int, flags)
>>  		goto dput_and_out;
>>  	if (!check_mnt(mnt))
>>  		goto dput_and_out;
>> -	if (mnt->mnt.mnt_flags & MNT_LOCKED)
>> +	if (!may_mount_lock(mnt))
>>  		goto dput_and_out;
>>  
>>  	retval = do_umount(mnt, flags);
>> @@ -1768,7 +1773,8 @@ static int do_loopback(struct path *path, const char *old_name,
>>  	if (!check_mnt(parent) || !check_mnt(old))
>>  		goto out2;
>>  
>> -	if (!recurse && has_locked_children(old, old_path.dentry))
>> +	if (!recurse && has_locked_children(old, old_path.dentry) &&
>> +	    !capable(CAP_SYS_ADMIN))
>>  		goto out2;
>>  
>>  	if (recurse)
>> @@ -1895,7 +1901,7 @@ static int do_move_mount(struct path *path, const char *old_name)
>>  	if (!check_mnt(p) || !check_mnt(old))
>>  		goto out1;
>>  
>> -	if (old->mnt.mnt_flags & MNT_LOCKED)
>> +	if (!may_mount_lock(old))
>>  		goto out1;
>>  
>>  	err = -EINVAL;
>> @@ -2679,7 +2685,7 @@ SYSCALL_DEFINE2(pivot_root, const char __user *, new_root,
>>  		goto out4;
>>  	if (!check_mnt(root_mnt) || !check_mnt(new_mnt))
>>  		goto out4;
>> -	if (new_mnt->mnt.mnt_flags & MNT_LOCKED)
>> +	if (!may_mount_lock(new_mnt))
>>  		goto out4;
>>  	error = -ENOENT;
>>  	if (d_unlinked(new.dentry))
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
