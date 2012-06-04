From: Jeff Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: container disk quota
Date: Mon, 04 Jun 2012 22:55:32 +0800
Message-ID: <4FCCCC64.5060301@oracle.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<20120601155457.GA30909@quack.suse.cz>
	<20120601160421.GA17402@amd1> <4FC9ABBB.3050303@oracle.com>
	<20120604025716.GA3480@sergelap> <4FCC3DB9.40105@oracle.com>
	<20120604094224.GA7670@quack.suse.cz> <4FCCB98A.2030703@oracle.com>
	<20120604135615.GD11010@quack.suse.cz>
Reply-To: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120604135615.GD11010-+0h/O2h83AeN3ZZ/Hiejyg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: tytso-3s7WtUTddSA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 06/04/2012 09:56 PM, Jan Kara wrote:

> On Mon 04-06-12 21:35:06, Jeff Liu wrote:
>> On 06/04/2012 05:42 PM, Jan Kara wrote:
>>
>>> On Mon 04-06-12 12:46:49, Jeff Liu wrote:
>>>> On 06/04/2012 10:57 AM, Serge Hallyn wrote:
>>>>> Quoting Jeff Liu (jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org):
>>>>>> Hi Serge,
>>>>>>
>>>>>> On 06/02/2012 12:04 AM, Serge Hallyn wrote:
>>>>>>
>>>>>>> Quoting Jan Kara (jack-AlSwsSmVLrQ@public.gmane.org):
>>>>>>>>   Hello,
>>>>>>>>
>>>>>>>> On Wed 30-05-12 22:58:54, jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org wrote:
>>>>>>>>> According to glauber's comments regarding container disk quota, it should be binded to mount
>>>>>>>>> namespace rather than cgroup.
>>>>>>>>>
>>>>>>>>> Per my try out, it works just fine by combining with userland quota utilitly in this way.
>>>>>>>>> However, they are something has to be done at user tools too IMHO.
>>>>>>>>>
>>>>>>>>> Currently, the patchset is in very initial phase, I'd like to post it early to seek more
>>>>>>>>> feedbacks from you guys.
>>>>>>>>>
>>>>>>>>> Hopefully I can clarify my ideas clearly.
>>>>>>>>   So what I miss in this introductory email is some highlevel description
>>>>>>>> like what is the desired functionality you try to implement and what is it
>>>>>>>> good for. Looking at the examples below, it seems you want to be able to
>>>>>>>> set quota limits for namespace-uid (and also namespace-gid???) pairs, am I
>>>>>>>> right?
>>>>>>>>
>>>>>>>>   If yes, then I would like to understand one thing: When writing to a
>>>>>>>> file, used space is accounted to the owner of the file. Now how do we
>>>>>>>> determine owning namespace? Do you implicitely assume that only processes
>>>>>>>> from one namespace will be able to access the file?
>>>>>>>>
>>>>>>>> 								Honza
>>>>>>>
>>>>>>> Not having looked closely at the original patchset, let me ask - is this
>>>>>>> feature going to be a freebie with Eric's usernamespace patches?
>>>>>>
>>>>>> It we can reach a consensus to bind quota on mount namespace for
>>>>>> container or other things maybe.
>>>>>> I think it definitely should depends on user namespace.
>>>>>>
>>>>>>>
>>>>>>> There, a container can be started in its own user namespace.  It's uid
>>>>>>> 1000 will be mapped to something like 1101000 on the host.  So the actual
>>>>>>> uid against who the quota is counted is 1101000.  In another container,
>>>>>>> uid 1000 will be mapped to 1201000, and again quota will be counted against
>>>>>>> 1201000.
>>>>>>
>>>>>> Is it also an implications that we can examine do container quota or not
>>>>>> based on the uid/gid number?
>>>>>
>>>>> I'm sorry I don't understand the question.
>>>>
>>>> Sorry for my poor english.
>>>>
>>>>>
>>>>> As an attempt at an answer:  the quota code wouldn't change at all.  We would
>>>>> simply exploit the fact that uid 1000 in container1 has a real uid of 101100,
>>>>> which is different from the real uid 102100 assigned to uid 1000 in container2
>>>>> and from real uid 1000 (uid 1000 on the host).
>>>>
>>>> In that case, looks we only need to figure out how to let quota tools
>>>> works at container.
>>>> I'll build a new kernel with user_ns to give a try.
>>>   GETQUOTA or SETQUOTA quotactls should work just fine inside a container
>>> (for those quota-tools just need access to /proc/mounts). QUOTAON should
>>> also work for e.g. XFS or ext4 with hidden quota files. When quota files
>>> are visible in fs namespace (as for ext3 or so), things would be a bit
>>> tricky because they won't be possibly visible from container and QUOTAON
>>> needs that.
>>
>> I still think if we can cache container dquot on memory to make this
>> feature as simple as possible. :)
>   Sorry, I don't understand. Quota structures are cached in memory.

I means teaching Q_SETQUOTA routine, don't write those info to quota
file if it was issued from container in quotacheck stage.  Instead,
allocate a dquot object at memory and keep it until quotaoff or
container destory procedures maybe.

> Also what would be simpler if you also do some caching in a container?

Sorry, does it means do caching in quota files?
currently, I have no good idea in this point. :(

> 
>> And also, quotacheck is the major issue I have faced previously, since we need a reasonable approach to calculate
>> and save the current inodes/blocks usage firstly.
>   Yes, quotacheck inside a container is a problem. But similarly as with
> quotaon(8), I think such global operation should rather be done outside.
>  
>>> Also with QUOTAON there is the principial problem that quotas either are or
>>> are not enabled for the whole filesystem.
>>
>> IMHO, we could supply uid/gid quota for the whole filesystem only(i.e,
>> the "/" rootfs), and we can support project quota among sub-directories
>> in the future if possible.
>>
>>> So probably the only reasonable
>>> choice when you would like to supporot quotas in the container would be to
>>> have quotas enabled all the time, and inside the container, you would just
>>> set some quota limits or you won't...
>>
>> I remember that ext4 has already supported quota as the first class,
>> looks we can consider container quota same to that.
>>
>> So we can ignore the quotacheck step, only focus on quota limits setup
>> inside container?
>   Yes, that would be my suggestion.

Yeah, that would be fine.

Thanks,
-Jeff

> 
> 								Honza
