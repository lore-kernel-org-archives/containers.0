From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v4] Introduce v3 namespaced file capabilities
Date: Fri, 16 Jun 2017 18:24:00 -0400
Message-ID: <6b3431cf-d4cf-f92c-d3c8-073d199fb580@linux.vnet.ibm.com>
References: <20170507092105.GA67584@inn.lkp.intel.com>
	<20170508044408.GA11400@mail.hallyn.com>
	<CACOXgS9a=avAWZEre1Q1CGjSHeq78Pkq1fYfwPjiyEX-u=B5wQ@mail.gmail.com>
	<20170508181156.GA23112@mail.hallyn.com>
	<9f80188c-df03-066a-5dac-785cc711d064@linux.vnet.ibm.com>
	<20170613171818.GA9070@mail.hallyn.com>
	<74e490f3-3c47-abfa-86ae-0fa0d1ddb43a@linux.vnet.ibm.com>
	<20170613235521.GC15685@mail.hallyn.com>
	<ce471b11-e76a-25f3-eae8-eca30e7233af@linux.vnet.ibm.com>
	<20170615030543.GA8979@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170615030543.GA8979-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

On 06/14/2017 11:05 PM, Serge E. Hallyn wrote:
> On Wed, Jun 14, 2017 at 08:27:40AM -0400, Stefan Berger wrote:
>> On 06/13/2017 07:55 PM, Serge E. Hallyn wrote:
>>> Quoting Stefan Berger (stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>>>>   If all extended
>>>> attributes were to support this model, maybe the 'uid' could be
>>>> associated with the 'name' of the xattr rather than its 'value' (not
>>>> sure whether that's possible).
>>> Right, I missed that in your original email when I saw it this morning.
>>> It's not what my patch does, but it's an interesting idea.  Do you have
>>> a patch to that effect?  We might even be able to generalize that to
>> No, I don't have a patch. It may not be possible to implement it.
>> The xattr_handler's  take the name of the xattr as input to get().
> That may be ok though.  Assume the host created a container with
> 100000 as the uid for root, which created a container with 130000 as
> uid for root.  If root in the nested container tries to read the
> xattr, the kernel can check for security.foo[130000] first, then
> security.foo[100000], then security.foo.  Or, it can do a listxattr
> and look for those.  Am I overlooking one?

So that sounds like a child would 'inherit' the value of an xattr from 
the closest parent if it doesn't have one itself. I guess it would 
depend on the xattr whether that should apply? And removing an xattr 
becomes difficult then if the parent container's xattr always shines 
through...

>
>> So one could try to encode the mapped uid in the name. However, that
> I thought that's exactly what you were suggesting in your original
> email?  "security.capability[uid=2000]"
>
>> could lead to problems with stale xattrs in a shared filesystem over
>> time unless one could limit the number of xattrs with the same
>> prefix, e.g., security.capability*. So I doubt that it would work.
> Hm.  Yeah.  But really how many setups are there like that?  I.e. if
> you launch a regular docker or lxd container, the image doesn't do a
> bind mount of a shared image, it layers something above it or does a
> copy.  What setups do you know of where multiple containers in different
> user namespaces mount the same filesystem shared and writeable?

So you think it's a good idea? I am not sure when I would get to it, 
though...

    Stefan


>
>> Otherwise it would be good if the value was wrapped in a data
>> structure use by all xattrs, but that doesn't seem to be the case,
>> either. So I guess we have to go into each type of value structure
>> and add a uid field there.
>>
>>> namespace any security.* xattrs.  Wouldn't be automatically enabled
>>> for anything but ima and capabilities, but we could make the infrastructure
>>> generic and re-usable.
>>>
