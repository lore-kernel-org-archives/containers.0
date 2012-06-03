From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: container disk quota
Date: Sun, 3 Jun 2012 13:48:18 +0400
Message-ID: <4FCB32E2.6050404__30286.0209871598$1338717069$gmane$org@parallels.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<20120601155457.GA30909@quack.suse.cz>	<20120601160421.GA17402@amd1>
	<4FC9ABBB.3050303@oracle.com>
	<01FED15D-15A3-4542-B95B-1166F0A309E6@parallels.com>
	<4FC9B183.10605@oracle.com>
	<8660DDAA-D7A7-4C03-8CBB-9DB7E94C80CB@parallels.com>
	<4FCAE6CB.8060208@oracle.com>
	<81DE9C10-649B-4D13-86B0-200944AE8767@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <81DE9C10-649B-4D13-86B0-200944AE8767-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, "tinguely-sJ/iWh9BUns@public.gmane.org" <tinguely-sJ/iWh9BUns@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org" <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org" <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, "bpm-sJ/iWh9BUns@public.gmane.org" <bpm-sJ/iWh9BUns@public.gmane.org>, "christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "tytso-3s7WtUTddSA@public.gmane.org" <tytso-3s7WtUTddSA@public.gmane.org>, "tm-d1IQDZat3X0@public.gmane.org" <tm-d1IQDZat3X0@public.gmane.org>, "linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 06/03/2012 09:47 AM, Kirill Korotaev wrote:
>
> On Jun 3, 2012, at 08:23 , Jeff Liu wrote:
>
>> Hi Kirill,
>>
>> On 06/02/2012 11:21 PM, Kirill Korotaev wrote:
>>
>>>>>>>
>>>>>>> Not having looked closely at the original patchset, let me ask - is this
>>>>>>> feature going to be a freebie with Eric's usernamespace patches?
>>>>>>
>>>>>> It we can reach a consensus to bind quota on mount namespace for
>>>>>> container or other things maybe.
>>>>>
>>>>> 1. OpenVZ doesn't use mount namespaces and still has quotas per container.
>>>>
>>>> AFAICS, OpenVZ has self-released quota tools to supply this feature.
>>>
>>> but standard quota tools work inside container w/o any modifications.
>>> This is very important for us, cause we run unmodified distros inside.
>>
>> Yes, am agree.
>> I can work out a new patches regarding quota tools based on mount namespace w/o any modification.
>
> Jeff, why do you need fs namespace for quotas? OpenVZ works w/o it.
> It sounds as too strict use case limitation. Or do I understand your patchset description wrong?
>

OpenVZ has its own kernel, with its very own isolation capabilities.
So in upstream, something has to be used instead.
