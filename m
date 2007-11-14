From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] Re: net 2.6.25
Date: Wed, 14 Nov 2007 12:05:09 +0100
Message-ID: <473AD665.3010000@fr.ibm.com>
References: <473AC169.1030202@sw.ru> <473ACE7F.5080007@fr.ibm.com>
	<473AD4F5.40505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <473AD4F5.40505-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Daniel Lezcano wrote:
>> Denis V. Lunev wrote:
>>> Hello, guys!
>>>
>>> David has been opened net-2.6.25 tree yesterday, so we could send a new
>>> portion of NETNS there. If there are no objections, I'll send first six
>>> patches from OpenVZ GIT tomorrow, i.e. RTNL infrastructure, Packet &
>>> Unix sockets virtualization + some our /proc cleanups.
>> Did Pavel had time to look at RCU looking mechanism to replace 
>> rtnl_lock/rtnl_unlock to protect the netns list ?
> 
> Unfortunately, I had not. Andrew has released the rc2-mm1 tree, so
> I'm now trying to prepare all the patches I wanted for this mm.
> 
> I will revisit this problem, but Denis said, that the problem we're
> trying to solve with the RCU protection can be solved w/o it, no?

Yes, if we create a timer per network namespace for ipv6 garbage 
collecting, we can avoid to use a rcu, in this case.

I am doing that right now, but I am afraid we can fall into another case 
where we need to browse the network list and I thought having the RCU 
will bring more flexibility.

But, we can live without rcu and go ahead with ipv6 anyway :)
