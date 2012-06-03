From: Jeff Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: container disk quota
Date: Sun, 03 Jun 2012 12:23:39 +0800
Message-ID: <4FCAE6CB.8060208@oracle.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<20120601155457.GA30909@quack.suse.cz>	<20120601160421.GA17402@amd1>
	<4FC9ABBB.3050303@oracle.com>
	<01FED15D-15A3-4542-B95B-1166F0A309E6@parallels.com>
	<4FC9B183.10605@oracle.com>
	<8660DDAA-D7A7-4C03-8CBB-9DB7E94C80CB@parallels.com>
Reply-To: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8660DDAA-D7A7-4C03-8CBB-9DB7E94C80CB-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kirill Korotaev <dev-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, "tytso-3s7WtUTddSA@public.gmane.org" <tytso-3s7WtUTddSA@public.gmane.org>, "tinguely-sJ/iWh9BUns@public.gmane.org" <tinguely-sJ/iWh9BUns@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org" <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, "hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org" <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, "bpm-sJ/iWh9BUns@public.gmane.org" <bpm-sJ/iWh9BUns@public.gmane.org>, "christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "tm-d1IQDZat3X0@public.gmane.org" <tm-d1IQDZat3X0@public.gmane.org>, "linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Kirill,

On 06/02/2012 11:21 PM, Kirill Korotaev wrote:

>>>>>
>>>>> Not having looked closely at the original patchset, let me ask - is this
>>>>> feature going to be a freebie with Eric's usernamespace patches?
>>>>
>>>> It we can reach a consensus to bind quota on mount namespace for
>>>> container or other things maybe.
>>>
>>> 1. OpenVZ doesn't use mount namespaces and still has quotas per container.
>>
>> AFAICS, OpenVZ has self-released quota tools to supply this feature.
> 
> but standard quota tools work inside container w/o any modifications.
> This is very important for us, cause we run unmodified distros inside.

Yes, am agree.
I can work out a new patches regarding quota tools based on mount namespace w/o any modification.

> 
> Actually, this is unrelated. I meant that OpenVZ needs ability to have group quotas w/o mount namespaces.
> 
>>
>>>
>>> 2. BTW, have you seen Dmitry Monakhov patches for same containers quotas via additional inode attribute? it allows to make it journaled.
>>
>> You means the directly/project quota on ext4?
>> If yes, I have observed this feature back to the end of last year in
>> EXT4 mail list.
> 
> yes
> 
>>
>>> How quotas are stored in your case?
>>
>> It simply cached at memory for now, it also can be tweak up to journaled
>> I think, if introducing corresponding routines quota_read/quota_write to
>> particular journal file system.
> 
> just cached quotas are bad - you never sure they are correct.
> journaled quotas (as standart) are much better.

Exactly.

> 
>>
>>>
>>> 3. I tend to think nowdays such quotas maybe of less need. Quota code doesn't scale well. And it's easier to put container in image file (as OpenVZ recently introduced).
>>
>> There have such requirements dropped to LXC mail list nowadays.
>> Directory quota is pretty cool and it also useful to containers perspective.
>>
>> However, that's two different quota mechanism.
>>
>> "Quota code doesn't scale well".
>> Do you means it have global locking mechanism and only quota structure
>> to bill up quota for all file systems with VFS quota enabled?
> 
> yes.

That's also means there has a potential opportunity for improvement in terms of scalability.

Thanks for your info!
-Jeff

> 
> Kirill
> 
