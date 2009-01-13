From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Net containers config and usage
Date: Tue, 13 Jan 2009 20:52:58 +0100
Message-ID: <496CF11A.7090908@free.fr>
References: <20090112223545.GA15781@versecorp.net>
	<20090112225140.GA29834@us.ibm.com>
	<20090113005436.GA26167@versecorp.net> <496C4EB0.30203@free.fr>
	<20090113142925.GA11767@us.ibm.com>
	<20090113191837.GA29900@versecorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090113191837.GA29900-SqNQQPNds68nxqbYAscKCQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org wrote:
>>>>  [root@C100273 iproute2-2.6.25]# ps aux | grep tcsh
>>>>  root     21918  0.0  0.0  71036  2084 pts/1    S+   16:47   0:00 -bin/tcsh
>>>>  root     22008  0.0  0.0  61144   716 pts/2    R+   16:57   0:00 grep tcsh
>>>>  [root@C100273 iproute2-2.6.25]# ip/ip link set eth4 netns 21918
>>>>  RTNETLINK answers: Invalid argument
>>>>
>>>> Any idea what could cause that error?
>>>>   
>>>>         
>>> Assuming your prompt is showing the right version, try a version of  
>>> iproute2 >= 2.6.26
>>>       
>> Right, this was a bit of a pain for me - when you install iproute,
>> by default it goes into another location, so you probably have to
>> specify /usr/local/sbin/ip or something.  Just a guess, but that
>> may be your problem here :)
>>
>> -serge
>>     
>
> I was running 2.6.25 plus the patch from here:
>     http://marc.info/?l=linux-netdev&m=120905226611742&q=raw
>
> But I tried getting 2.6.26 and I have the same problem:
>
> [root@C100273 iproute2-2.6.26]# ip/ip link set eth4 netns 24755
> RTNETLINK answers: Invalid argument
>
> I'm pretty certain I'm running the right "version" of the command.  It
> does install it to /usr/sbin/ip, but if I run the version that came with the
> distribution (in /sbin/ip), I get a different error reporting netns as garbage.
> So.. since it at least parses the netns argument and sends the netlink request,
> it at least seems to be making it to the kernel.
>
> Does the kernel.org version of 2.6.29-rc1 have everything I need?
>
> Any other ideas?
>   
Is eth4 a physical network device or a virtual device (like a tunnel) 
renamed eth4 ?

Can you send the output of the "ip link" command and the value of
/sys/class/net/eth4/features to check if the network device is not 
flagged as a non-movable.

thanks.
  -- Daniel
