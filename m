From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 2/2][NETNS][RFD] use dst_entries to retrieve the network
 namespace pointer
Date: Wed, 12 Dec 2007 12:18:39 +0100
Message-ID: <475FC38F.4060708@fr.ibm.com>
References: <20071211131231.701104221@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071211131754.788346594@ICON-9-164-138-215.megacenter.de.ibm.com>
	<475EC229.8020605@sw.ru> <475FA3D5.90900@fr.ibm.com>
	<475FA961.3080605@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <475FA961.3080605-3ImXcnM4P+0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: xemul-3ImXcnM4P+0@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

Denis V. Lunev wrote:
> Daniel Lezcano wrote:
>> Denis V. Lunev wrote:
>>> Daniel Lezcano wrote:
>>>> The objective we have is to remove the fl_net field from the struct
>>>> flowi.
>>>>
>>>> In the previous patch, we make the network namespace to go up to the
>>>> dst_entry.
>>>> This patch makes an example in how we can use the dst_entry/rtable
>>>> combined with
>>>> a container_of to retrieve the network namespace when we have the
>>>> flowi parameter.
>>>>
>>>> One restriction is we should pass always a flowi parameter coming
>>>> from a struct
>>>> dst_entry.
>>> this is an obfuscation IMHO. You use rtable instead of flowi, so
>>> - rtable obtain flowi meaning and keeps original meaning
>>> - stack usage in increased
>> Yes, you are right. Using container_of is not a good idea finally.
>>
>>> So, for the case, I think it is better to have an additional parameter
>>> on IP route output path. (There is a device on the input one).
>> I thought that at the beginning, but I was not inclined to change
>> exported functions API, so I looked a way to avoid that but I failed
>> miserably :)
>> Obviously, the ip route output path extra parameter is the cleanest way
>> to introduce the network namespace pointer in the routing code. So why
>> not ?
>>
> 
> Daniel,
> 
> I am in somewhere near the end of routing back-end namespacing, so could
> you wait a bit till I send it to Dave. I think this could be done just
> after Pavel's set will be commited (netns_ipv4 is needed :)
> 
> Regards,
> 	Den

No problem.

Benjamin and I will change the ipv6 routing then.

Thanks.
	-- Daniel
