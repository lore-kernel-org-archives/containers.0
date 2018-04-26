From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH v3 1/3] ima: extend clone() with IMA namespace support
Date: Thu, 26 Apr 2018 17:18:43 -0400
Message-ID: <0d2b2635-d7fb-d240-7dd0-2a81014c58ba__4663.26983082599$1524777427$gmane$org@linux.vnet.ibm.com>
References: <1522159038-14175-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1522159038-14175-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87sh8lcecn.fsf@xmission.com>
	<1523636702.3272.63.camel@linux.vnet.ibm.com>
	<d8c30d7d-c679-9323-7a25-d3148e9b96c6@canonical.com>
	<1524081472.3272.319.camel@linux.vnet.ibm.com>
	<87wox4s282.fsf@xmission.com>
	<8895cb9c-7b9e-2f82-e3d8-a15f5fc26e25@canonical.com>
	<2103bbb9-3f2a-78f8-f7ad-28859659973f@linux.vnet.ibm.com>
	<f84ae8af-fa5b-9f31-fbef-5a49f90dd45a@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <f84ae8af-fa5b-9f31-fbef-5a49f90dd45a-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/19/2018 11:35 AM, John Johansen wrote:
> On 04/19/2018 04:03 AM, Stefan Berger wrote:
>> On 04/18/2018 05:32 PM, John Johansen wrote:
>>> On 04/18/2018 01:12 PM, Eric W. Biederman wrote:
>>>> Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
>>>>
>>>>> On Wed, 2018-04-18 at 09:09 -0700, John Johansen wrote:
>>>>>> On 04/13/2018 09:25 AM, Mimi Zohar wrote:
>>>>>>> [Cc'ing John Johansen]
>>>>>>>
>>>>>>> On Tue, 2018-03-27 at 18:01 -0500, Eric W. Biederman wrote:
>>>>>>> [...]
>>>>>>>> As such I expect the best way to create the ima namespace is by simply
>>>>>>>> writing to securityfs/imafs.  Possibly before the user namespace is
>>>>>>>> even unshared.  That would allow IMA to keep track of things from
>>>>>>>> before a container is created.
>>>>>> I do think this is generally the right approach for LSMs when looking
>>>>>> forward to LSM stacking and more LSMs.
>>>>>>
>>>>>>
>>>>>>> My initial thought was to stage IMA namespacing with just IMA-audit
>>>>>>> first, followed by either IMA-measurement or IMA-appraisal.  This
>>>>>>> would allow us to get the basic IMA namespacing framework working and
>>>>>>> defer dealing with the securityfs related namespacing of the IMA
>>>>>>> policy and measurement list issues to later.
>>>>>>>
>>>>>>> By tying IMA namespacing to a securityfs ima/unshare file, we would
>>>>>>> need to address the securityfs issues first.
>>>>>>>
>>>>>> well it depends on what you want to do. It would be possible to have
>>>>>> a simple file (not a jump link) within securityfs that IMA could use
>>>>>> without having to deal with all the securityfs issues first. However it
>>>>>> does require that securityfs (not necessarily imafs) be visible within
>>>>>> the mount namespace of the task doing the setup.
>>>>> Eric, would you be OK with that?
>>>> Roughly.  My understanding is that you have to have a write to some
>>>> filesystem to set the ima policy.
>>>>
>>>> I was expecting having to write an "create ima namespace" value
>>>> to the filesystem would not be any special effort.
>>>>
>>>> Now it sounds like providing the "create an ima namespace" is going to
>>>> be a special case, and that does not sound correct.
>>>>
>>> not necessarily special case, but they do need to settle on an interface
>>> that will work for them, and will work with the order they want to land
>>> things. I was just trying to point out that there are fs solutions that
>>> can work without having deal with the full securityfs/imafs namespacing
>>> solution landing first.
>>>
>>> While create a file directly in securityfs that lives along side the imafs
>>> dir.
>>> ima_create_ns
>>> ima/
>>> does feel like a special case. It could work
>>>
>>> what I was thinking of when I proposed a simple is to do it within the ima
>>> dir, say
>>> ima/create_ns
>> Having looked at SELinux and how Steve does it, I chose 'unshare' as the filename and put it into the neighborhood of  existing IMA securityfs files: /sys/kernel/security/ima/unshare. Write a '1' to it and you'll have an IMA namespace upon the next fork()/clone().
>>
>>> For now its just a single file but once imafs becomes "virtualized" to a
>>> namespace view, each dir that imafs jumplinks to contains a instance of the
>>> file.
>> Right. We need to virtualize our IMA securityfs entries pretty soon afterwards so that we can start setting policies in an IMA namespace. At the beginning we would not be able to create nested IMA namespaces if a user namespace is involved. My current patches that attempt to do this basically implement it by getting out of securityfs for namespace support and hooking it onto sysfs. On the host we would still use securityfs.
>>
>>>
>>> Or they could avoid securityfs/imafs entirely and leverage a file in
>>> procfs
>> If we want to it that way for all other subsystems that do not use a clone() flag, we should maybe decide on that now...
>>
> It sounds like its already decided, with ima and selinux going with an unshare file within their own fs.
>
> AppArmor went a different route already, splitting namespace creation (mkdir in the apparmorfs policy/namespace dir) and the task entering the namespace with a write apparmor's equiv of setexeccon.
>
I am supporting procfs entries for the IMA namespace spawned by writing 
a boolean '1' into IMA's securityfs 'unshare' file. It would allow to 
use setns(fd, 0), obviously with the 0 parameter. I think this is an 
important function to support considering entering a set of namespace. I 
am just wondering about the 0 parameter. We don't have a CLONE flag for 
it, so there's not other way to support it then. Does it matter ?

    Stefan
