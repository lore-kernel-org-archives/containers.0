From: Jeff Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: container disk quota
Date: Mon, 04 Jun 2012 12:46:49 +0800
Message-ID: <4FCC3DB9.40105@oracle.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<20120601155457.GA30909@quack.suse.cz>
	<20120601160421.GA17402@amd1> <4FC9ABBB.3050303@oracle.com>
	<20120604025716.GA3480@sergelap>
Reply-To: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120604025716.GA3480@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: tytso-3s7WtUTddSA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 06/04/2012 10:57 AM, Serge Hallyn wrote:

> Quoting Jeff Liu (jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org):
>> Hi Serge,
>>
>> On 06/02/2012 12:04 AM, Serge Hallyn wrote:
>>
>>> Quoting Jan Kara (jack-AlSwsSmVLrQ@public.gmane.org):
>>>>   Hello,
>>>>
>>>> On Wed 30-05-12 22:58:54, jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org wrote:
>>>>> According to glauber's comments regarding container disk quota, it should be binded to mount
>>>>> namespace rather than cgroup.
>>>>>
>>>>> Per my try out, it works just fine by combining with userland quota utilitly in this way.
>>>>> However, they are something has to be done at user tools too IMHO.
>>>>>
>>>>> Currently, the patchset is in very initial phase, I'd like to post it early to seek more
>>>>> feedbacks from you guys.
>>>>>
>>>>> Hopefully I can clarify my ideas clearly.
>>>>   So what I miss in this introductory email is some highlevel description
>>>> like what is the desired functionality you try to implement and what is it
>>>> good for. Looking at the examples below, it seems you want to be able to
>>>> set quota limits for namespace-uid (and also namespace-gid???) pairs, am I
>>>> right?
>>>>
>>>>   If yes, then I would like to understand one thing: When writing to a
>>>> file, used space is accounted to the owner of the file. Now how do we
>>>> determine owning namespace? Do you implicitely assume that only processes
>>>> from one namespace will be able to access the file?
>>>>
>>>> 								Honza
>>>
>>> Not having looked closely at the original patchset, let me ask - is this
>>> feature going to be a freebie with Eric's usernamespace patches?
>>
>> It we can reach a consensus to bind quota on mount namespace for
>> container or other things maybe.
>> I think it definitely should depends on user namespace.
>>
>>>
>>> There, a container can be started in its own user namespace.  It's uid
>>> 1000 will be mapped to something like 1101000 on the host.  So the actual
>>> uid against who the quota is counted is 1101000.  In another container,
>>> uid 1000 will be mapped to 1201000, and again quota will be counted against
>>> 1201000.
>>
>> Is it also an implications that we can examine do container quota or not
>> based on the uid/gid number?
> 
> I'm sorry I don't understand the question.

Sorry for my poor english.

> 
> As an attempt at an answer:  the quota code wouldn't change at all.  We would
> simply exploit the fact that uid 1000 in container1 has a real uid of 101100,
> which is different from the real uid 102100 assigned to uid 1000 in container2
> and from real uid 1000 (uid 1000 on the host).

In that case, looks we only need to figure out how to let quota tools
works at container.
I'll build a new kernel with user_ns to give a try.

> 
>>> Note that this won't work with bind mounts, as a file can only be owned
>>> by one uid, be it 1000, 1101000, or 1201000.  So for the quota to work
>>> each container would need its own files.  (Of course the underlying
>>> metadata can be shared through whatever ways - btrfs, lvm snapshotting,
>>> etc)
>>
>> Do you means that we can not bind mount outside files to container for
>> as general adquot.user/adquot.group purpose?
> 
> Right, not without some sort of stackable filesystem which masks the uid.
> 
> Actually there may be a way around it (simply provide a mount option,
> requiring privilege in the original user namespace, saying mask uid x to
> look like uid y for this bind mount), but it's too early to say how
> cleanly that could be done.

> 
>> If so, per glauber's comments, bind quota to mount namespace should be a
>> generic feature, and container just one of users could make use of it.
>>
>> Again, if bind quota to mount namespace is on right direction, and it
>> only does make sense to container for now, maybe we don't need such
>> files. IMHO, container is a lightweight virtualization solution, maybe
>> its fine to make it as simple as possible.  If the server admin need to
>> configure hundreds of user/group dquot per container, perhaps he should
>> consider KVM/XEN.
> 
> Server admin doesn't need to do that.

Thanks for the info!

-Jeff

> 
> -serge
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
