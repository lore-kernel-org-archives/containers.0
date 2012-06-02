From: Kirill Korotaev <dev-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: container disk quota
Date: Sat, 2 Jun 2012 10:06:59 +0400
Message-ID: <01FED15D-15A3-4542-B95B-1166F0A309E6__46370.1384760954$1338618033$gmane$org@parallels.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<20120601155457.GA30909@quack.suse.cz>	<20120601160421.GA17402@amd1>
	<4FC9ABBB.3050303@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4FC9ABBB.3050303-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, "tytso-3s7WtUTddSA@public.gmane.org" <tytso-3s7WtUTddSA@public.gmane.org>, "tinguely-sJ/iWh9BUns@public.gmane.org" <tinguely-sJ/iWh9BUns@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org" <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, "hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org" <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, "bpm-sJ/iWh9BUns@public.gmane.org" <bpm-sJ/iWh9BUns@public.gmane.org>, "christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "tm-d1IQDZat3X0@public.gmane.org" <tm-d1IQDZat3X0@public.gmane.org>, "linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


On Jun 2, 2012, at 09:59 , Jeff Liu wrote:

> Hi Serge,
> 
> On 06/02/2012 12:04 AM, Serge Hallyn wrote:
> 
>> Quoting Jan Kara (jack-AlSwsSmVLrQ@public.gmane.org):
>>>  Hello,
>>> 
>>> On Wed 30-05-12 22:58:54, jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org wrote:
>>>> According to glauber's comments regarding container disk quota, it should be binded to mount
>>>> namespace rather than cgroup.
>>>> 
>>>> Per my try out, it works just fine by combining with userland quota utilitly in this way.
>>>> However, they are something has to be done at user tools too IMHO.
>>>> 
>>>> Currently, the patchset is in very initial phase, I'd like to post it early to seek more
>>>> feedbacks from you guys.
>>>> 
>>>> Hopefully I can clarify my ideas clearly.
>>>  So what I miss in this introductory email is some highlevel description
>>> like what is the desired functionality you try to implement and what is it
>>> good for. Looking at the examples below, it seems you want to be able to
>>> set quota limits for namespace-uid (and also namespace-gid???) pairs, am I
>>> right?
>>> 
>>>  If yes, then I would like to understand one thing: When writing to a
>>> file, used space is accounted to the owner of the file. Now how do we
>>> determine owning namespace? Do you implicitely assume that only processes
>>> from one namespace will be able to access the file?
>>> 
>>> 								Honza
>> 
>> Not having looked closely at the original patchset, let me ask - is this
>> feature going to be a freebie with Eric's usernamespace patches?
> 
> It we can reach a consensus to bind quota on mount namespace for
> container or other things maybe.

1. OpenVZ doesn't use mount namespaces and still has quotas per container.

2. BTW, have you seen Dmitry Monakhov patches for same containers quotas via additional inode attribute? it allows to make it journaled.
How quotas are stored in your case?

3. I tend to think nowdays such quotas maybe of less need. Quota code doesn't scale well. And it's easier to put container in image file (as OpenVZ recently introduced).

Thanks,
Kirill
