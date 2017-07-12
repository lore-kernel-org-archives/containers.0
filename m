From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Wed, 12 Jul 2017 15:19:46 -0400
Message-ID: <3368afe9-1e0c-6f6a-aba6-9ce26d2e45e4__35352.6642815725$1499887205$gmane$org@linux.vnet.ibm.com>
References: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<20170712175357.GA32609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170712175357.GA32609-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Stefan Berger <StefanBergerstefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: lkp-JC7UmRfGjtg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/12/2017 01:53 PM, Vivek Goyal wrote:
> On Tue, Jul 11, 2017 at 11:05:11AM -0400, Stefan Berger wrote:
>
> [..]
>> @@ -301,14 +721,39 @@ ssize_t
>>   __vfs_getxattr(struct dentry *dentry, struct inode *inode, const char *name,
>>   	       void *value, size_t size)
>>   {
>> -	const struct xattr_handler *handler;
>> +	const struct xattr_handler *handler = NULL;
>> +	char *newname =  NULL;
>> +	int ret, userns_supt_xattr;
>> +	struct user_namespace *userns = current_user_ns();
>> +
>> +	userns_supt_xattr = (xattr_is_userns_supported(name, false) >= 0);
>> +
> Hi Stephan,
>
>> +	do {
>> +		kfree(newname);
>> +
>> +		newname = xattr_userns_name(name, userns);
> 					    ^^^
> Will name be pointing to a freed string in second iteration of loop.

Fixing for v3.

>
>> +		if (IS_ERR(newname))
>> +			return PTR_ERR(newname);
>> +
>> +		if (!handler) {
>> +			name = newname;
> Here we assign name and at the beginning of second iteration we free
> newname.
>
> Also I am not sure why do we do this assignment only if handler is NULL.

The handler shouldn't change but this optimization isn't helpful. Fixed 
through this patch:

https://github.com/stefanberger/linux/commit/10828401b29a13f8c56f8fad0c0fb2690e4af878


>
> BTW, I set cap_sys_admin on a file outside usernamespace and then launched
> user namespace (mapping 1000 to 0). And then tried to do getcap on file
> and I am not seeing security.capability set by host. Not sure what am I
> doing wrong. getxattr() seems to return -ENODATA. Still debugging it.

This was a regression due to the bug in the loop. I didn't have a test 
case (with runc) for it, now I do.

>
> Also, have we resovled the question of stacked filesystem like overlayfs.
> There we are switching creds to mounter's creds when doing operations on
> underlying filesystem. I am concenrned does that mean, we will get and
> return security.capability to caller in usernamespace instead of
> security.capability@uid=1000.

I would have to test this, otherwise I don't know. I'll try it out with 
Docker.

    Stefan

>
> Vivek
>
>> +			handler = xattr_resolve_name(inode, &name);
>> +			if (IS_ERR(handler)) {
>> +				ret = PTR_ERR(handler);
>> +				goto out;
>> +			}
>> +			if (!handler->get) {
>> +				ret = -EOPNOTSUPP;
>> +				goto out;
>> +			}
>> +		}
>> +		ret = handler->get(handler, dentry, inode, name, value, size);
>> +		userns = userns->parent;
>> +	} while ((ret == -ENODATA) && userns && userns_supt_xattr);
>>   
>> -	handler = xattr_resolve_name(inode, &name);
>> -	if (IS_ERR(handler))
>> -		return PTR_ERR(handler);
>> -	if (!handler->get)
>> -		return -EOPNOTSUPP;
>> -	return handler->get(handler, dentry, inode, name, value, size);
>> +out:
>> +	kfree(newname);
>> +	return ret;
>>   }
>>   EXPORT_SYMBOL(__vfs_getxattr);
>>   
> Thanks
> Vivek
>
