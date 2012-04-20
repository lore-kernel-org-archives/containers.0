From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 22/43] userns: Convert capabilities related permsion checks
Date: Fri, 20 Apr 2012 16:18:50 -0700
Message-ID: <m1obqm56w5.fsf@fess.ebiederm.org>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-22-git-send-email-ebiederm@xmission.com>
	<20120418185106.GG4984@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120418185106.GG4984-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Wed, 18 Apr 2012 18:51:06 +0000")
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
>> - Use uid_eq when comparing kuids
>>   Use gid_eq when comparing kgids
>> - Use __make_kuid(user_ns, 0) to talk about the user_namespace root uid
>>   Use __make_kgid(user_ns, 0) to talk about the user_namespace root gid
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>
> though, nit,
>
>> ---
>>  fs/open.c            |    3 ++-
>>  security/commoncap.c |   43 ++++++++++++++++++++++++++++---------------
>>  2 files changed, 30 insertions(+), 16 deletions(-)
>> 

>> diff --git a/security/commoncap.c b/security/commoncap.c
>> index dbd465a..9bf8df8 100644
>> --- a/security/commoncap.c
>> +++ b/security/commoncap.c
>> @@ -472,19 +472,24 @@ int cap_bprm_set_creds(struct linux_binprm *bprm)
>>  	struct cred *new = bprm->cred;
>>  	bool effective, has_cap = false;
>>  	int ret;
>> +	kuid_t root_uid;
>> +	kgid_t root_gid;
>
> the root_gid is assigned but never used.

Thanks snipped.  It doesn't look like there will ever be a use for it.

>>  
>>  	effective = false;
>>  	ret = get_file_caps(bprm, &effective, &has_cap);
>>  	if (ret < 0)
>>  		return ret;
>>  
>> +	root_uid = make_kuid(new->user_ns, 0);
>> +	root_gid = make_kgid(new->user_ns, 0);
>> +

Eric
