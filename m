From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: net 2.6.25
Date: Wed, 14 Nov 2007 09:03:30 -0700
Message-ID: <m1fxz824rx.fsf@ebiederm.dsl.xmission.com>
References: <473AC169.1030202@sw.ru> <473ACE7F.5080007@fr.ibm.com>
	<473AD3F0.1000604@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <473AD3F0.1000604-3ImXcnM4P+0@public.gmane.org> (Denis V. Lunev's message of "Wed, 14
	Nov 2007 13:54:40 +0300")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

"Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org> writes:

> Daniel Lezcano wrote:
>> Denis V. Lunev wrote:
>>> Hello, guys!
>>>
>>> David has been opened net-2.6.25 tree yesterday, so we could send a new
>>> portion of NETNS there. If there are no objections, I'll send first six
>>> patches from OpenVZ GIT tomorrow, i.e. RTNL infrastructure, Packet &
>>> Unix sockets virtualization + some our /proc cleanups.
>> 
>> Did Pavel had time to look at RCU looking mechanism to replace
>> rtnl_lock/rtnl_unlock to protect the netns list ?
> not yet
>
>> ps: isn't the openvz mailing list already subscribed to containers@
> hmm :) Pavel say yes :) trying...

Well honestly I think I would rather have a spin lock then an rcu thing.

It may not be a big deal because we already have to check the count and
if it is zero ignore the namespace, so rcu may not add complications but
changing something that already has interesting usage and lifetime rules
to rcu sends up warning signs for me.

Eric
