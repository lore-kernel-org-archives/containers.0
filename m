From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] An attempt to have an unlimitedly extendable sys_clone
Date: Wed, 16 Jan 2008 11:09:06 +0300
Message-ID: <478DBBA2.6080202@openvz.org>
References: <478CAC32.4080809@openvz.org>
	<39689.192.168.101.12.1200407681.squirrel@intranet>
	<478DB1AC.6050508@openvz.org>
	<41572.192.168.102.6.1200470331.squirrel@intranet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <41572.192.168.102.6.1200470331.squirrel@intranet>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Hokka Zakrisson <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Hokka Zakrisson wrote:
> Pavel Emelyanov wrote:
>> [snip]
>>
>>>> +static struct long_clone_arg *get_long_clone_arg(int __user
>>>> *child_tidptr)
>>>> +{
>>>> +	int size;
>>>> +	struct long_clone_arg *carg;
>>>> +
>>>> +	if (get_user(size, child_tidptr))
>>>> +		return ERR_PTR(-EFAULT);
>>>> +
>>>> +	if (size > sizeof(struct long_clone_arg))
>>>> +		return ERR_PTR(-EINVAL);
>>> This means that software built against a newer kernel won't work on an
>>> older one. Surely that's not intended?
>> It is intended. If I ask an old kernel to clone the mq namespace, but
>> it doesn't support such, that I'd better like to get an -EINVAL error
>> rather than be silently held in an old global namespace.
> 
> That rules out using the struct for things like child_tidptr, the desired
> pid for C/R, etc. I think the version Dave Hansen proposed would be

A new system call? Ok - what arguments should it take?

> better, or if it's really just for bits, use an array rather than a struct
> to make that obvious.

It's for anything you'd like to tell to clone(). In the nearest future - for
more bits to clone new namespaces. In the far future - for pid to create the
task with (for c/r jobs). In the the far-far future - for anything you will
need then.

>> [snip]
>>
> 
