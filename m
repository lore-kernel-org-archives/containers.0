From: "Daniel Hokka Zakrisson" <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] An attempt to have an unlimitedly extendable sys_clone
Date: Wed, 16 Jan 2008 09:07:21 +0100 (CET)
Message-ID: <37601.192.168.102.6.1200470841.squirrel@intranet>
References: <478CAC32.4080809@openvz.org>
	<39689.192.168.101.12.1200407681.squirrel@intranet>
	<478DB1AC.6050508@openvz.org>
	<41572.192.168.102.6.1200470331.squirrel@intranet>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

I wrote:
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
>>>
>>> This means that software built against a newer kernel won't work on an
>>> older one. Surely that's not intended?
>>
>> It is intended. If I ask an old kernel to clone the mq namespace, but
>> it doesn't support such, that I'd better like to get an -EINVAL error
>> rather than be silently held in an old global namespace.
>
> That rules out using the struct for things like child_tidptr, the desired
> pid for C/R, etc. I think the version Dave Hansen proposed would be
> better, or if it's really just for bits, use an array rather than a struct
> to make that obvious.

s/Dave Hansen/Oren Laadan/
Sorry, too early for me.

>> [snip]
>>

-- 
Daniel Hokka Zakrisson
