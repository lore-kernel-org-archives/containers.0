From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 18/43] userns: Convert group_info values from gid_t to
	kgid_t.
Date: Fri, 20 Apr 2012 16:05:34 -0700
Message-ID: <m1vcku57i9.fsf@fess.ebiederm.org>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-18-git-send-email-ebiederm@xmission.com>
	<20120418184936.GC4984@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120418184936.GC4984-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Wed, 18 Apr 2012 18:49:36 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Beiderman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> 
>> As a first step to converting struct cred to be all kuid_t and kgid_t
>> values convert the group values stored in group_info to always be
>> kgid_t values.   Unless user namespaces are used this change should
>> have no effect.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>>  arch/s390/kernel/compat_linux.c   |   13 ++++++++-
>>  fs/nfsd/auth.c                    |    5 ++-
>>  fs/proc/array.c                   |    5 +++-
>>  include/linux/cred.h              |    9 ++++---
>>  kernel/groups.c                   |   48 +++++++++++++++++++-----------------
>>  kernel/uid16.c                    |   14 +++++++++-
>>  net/ipv4/ping.c                   |   11 ++++++--
>>  net/sunrpc/auth_generic.c         |    4 +-
>>  net/sunrpc/auth_gss/svcauth_gss.c |    7 ++++-
>>  net/sunrpc/auth_unix.c            |   15 ++++++++---
>>  net/sunrpc/svcauth_unix.c         |   18 ++++++++++---
>>  security/keys/permission.c        |    3 +-
>>  12 files changed, 103 insertions(+), 49 deletions(-)
>> 
>> diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
>> index ab64bdb..5baac18 100644
>> --- a/arch/s390/kernel/compat_linux.c
>> +++ b/arch/s390/kernel/compat_linux.c
>> @@ -173,11 +173,14 @@ asmlinkage long sys32_setfsgid16(u16 gid)
>>  
>>  static int groups16_to_user(u16 __user *grouplist, struct group_info *group_info)
>>  {
>> +	struct user_namespace *user_ns = current_user_ns();
>>  	int i;
>>  	u16 group;
>> +	kgid_t kgid;
>>  
>>  	for (i = 0; i < group_info->ngroups; i++) {
>> -		group = (u16)GROUP_AT(group_info, i);
>> +		kgid = GROUP_AT(group_info, i);
>> +		group = (u16)from_kgid_munged(user_ns, kgid);
>>  		if (put_user(group, grouplist+i))
>>  			return -EFAULT;
>>  	}
>> @@ -187,13 +190,19 @@ static int groups16_to_user(u16 __user *grouplist, struct group_info *group_info
>>  
>>  static int groups16_from_user(struct group_info *group_info, u16 __user *grouplist)
>>  {
>> +	struct user_namespace *user_ns = current_user_ns();
>>  	int i;
>>  	u16 group;
>
> need
>
> 	kgid_t kgid;
>
> here

Doh!  Thank you.

Now I am wondering why s390 has it's own copy of this function instead
of using the version in uid16.c.

>>  	for (i = 0; i < group_info->ngroups; i++) {
>>  		if (get_user(group, grouplist+i))
>>  			return  -EFAULT;
>> -		GROUP_AT(group_info, i) = (gid_t)group;
>> +
>> +		kgid = make_kgid(user_ns, (gid_t)group);
>> +		if (!gid_valid(kgid))
>> +			return -EINVAL;
>> +
>> +		GROUP_AT(group_info, i) = kgid;
>>  	}
>>  
>>  	return 0;

Eric
