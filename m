From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: Re: nets: status of sysfs with netns
Date: Fri, 14 Mar 2008 16:54:07 +0100
Message-ID: <47DA9F9F.5060502@bull.net>
References: <47DA9BEA.9070907@bull.net> <47DA9D71.2010707@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47DA9D71.2010707-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Benjamin Thery wrote:
>> Eric, Pavel,
>>
>> I haven't followed everything about the sysfs/netns issue recently and I 
>> think I have missed some of its recent developments in the past weeks. 
>> So I'm wondering what is the current status? Is anyone still working on it?
> 
> I'm thinking on it, but have no graceful solution :( Sysfs is a big...
> no - HUUUUUUUUUUGE problem.

Agreed.

>> As several netns patches for IPv4 and IPv6 have already been merged in 
>> net-2.6.26, it would be great to have the sysfs part also to help people 
>> who want test netns.
>> Right now, it is a pain to boot and test a system with CONFIG_SYSFS=n.
>>
>> (I know the problem is not trivial and won't be easy to solve. I just 
>> want to be sure it is not forgotten)
> 
> It is (unfortunately) not.
> 
>> Pavel, I've heard you sent (or have) a patch that prevents sysfs access 
>> from a "child" netns. A patch that can be a good workaround until we 
>> have the full thing ready. I can't find it in mailing lists archives, 
>> can you give some hints about where to find it? :)
> 
> Hm. I haven't had plans to do such things actually.

Oh, that explains why I didn't find it :)
I must have misunderstood what I heard...

> 
>> Thanks a lot.
>>
>> Benjamin
>>
> 
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
