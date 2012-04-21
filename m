From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 27/43] userns: Use uid_eq gid_eq helpers when comparing
	kuids and kgids in the vfs
Date: Fri, 20 Apr 2012 17:05:56 -0700
Message-ID: <m1y5pq3q57.fsf__12383.9228101589$1334966524$gmane$org@fess.ebiederm.org>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-27-git-send-email-ebiederm@xmission.com>
	<20120418190213.GD5186@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120418190213.GD5186-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Wed, 18 Apr 2012 19:02:13 +0000")
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
>> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>>  fs/attr.c                |    8 ++++----
>>  fs/exec.c                |   10 +++++-----
>>  fs/fcntl.c               |    6 +++---
>>  fs/ioprio.c              |    4 ++--
>>  fs/locks.c               |    2 +-
>>  fs/namei.c               |    8 ++++----
>>  include/linux/quotaops.h |    4 ++--
>>  7 files changed, 21 insertions(+), 21 deletions(-)
>> 
>> diff --git a/fs/attr.c b/fs/attr.c
>> index 73f69a6..2f094c6 100644
>> --- a/fs/attr.c
>> +++ b/fs/attr.c
>> @@ -47,14 +47,14 @@ int inode_change_ok(const struct inode *inode, struct iattr *attr)
>>  
>>  	/* Make sure a caller can chown. */
>>  	if ((ia_valid & ATTR_UID) &&
>> -	    (current_fsuid() != inode->i_uid ||
>> -	     attr->ia_uid != inode->i_uid) && !capable(CAP_CHOWN))
>> +	    (!uid_eq(current_fsuid(), inode->i_uid) ||
>> +	     !uid_eq(attr->ia_uid, inode->i_uid)) && !capable(CAP_CHOWN))
>>  		return -EPERM;
>>  
>>  	/* Make sure caller can chgrp. */
>>  	if ((ia_valid & ATTR_GID) &&
>> -	    (current_fsuid() != inode->i_uid ||
>> -	    (!in_group_p(attr->ia_gid) && attr->ia_gid != inode->i_gid)) &&
>> +	    (!uid_eq(current_fsuid(), inode->i_uid) ||
>> +	    (!in_group_p(attr->ia_gid) && gid_eq(attr->ia_gid, inode->i_gid))) &&
>
> This should be !gid_eq() ?

Yes.  Thank you, it is now fixed in my tree.

Eric
