From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Net containers config and usage
Date: Tue, 13 Jan 2009 08:29:25 -0600
Message-ID: <20090113142925.GA11767@us.ibm.com>
References: <20090112223545.GA15781@versecorp.net>
	<20090112225140.GA29834@us.ibm.com>
	<20090113005436.GA26167@versecorp.net> <496C4EB0.30203@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <496C4EB0.30203-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org wrote:
>> On Mon, Jan 12, 2009 at 04:51:40PM -0600, Serge E. Hallyn wrote:
>>   
>>>>   But I'm having trouble assigning an interface over to that container.
>>>>
>>>>   I tried doing:
>>>>      # echo <pid> > /sys/class/net/eth4/new_ns_pid
>>>>
>>>>   But there are no entries in sysfs called new_ns_pid.
>>>>       
>>> Yeah I'm not sure where that command came from.
>>>     
>>
>> OK - just FYI, I got that command from http://lxc.sourceforge.net/network.php
>>   
> You are right, it is not up-to-date.
>>   
>>> To move eth4 into a new
>>> netns, you'd want to do
>>>
>>> 	ip link set eth4 netns $pid_of_shell_in_ns
>>>
>>> See http://lxc.sourceforge.net/network/configuration.php for
>>> more  info.
>>>
>>>     
>>
>> Trying to use the "ip link set" command, I get a different problem - it
>> reports an RTNETLINK error:
>>
>>  [root@C100273 iproute2-2.6.25]# ps aux | grep tcsh
>>  root     21918  0.0  0.0  71036  2084 pts/1    S+   16:47   0:00 -bin/tcsh
>>  root     22008  0.0  0.0  61144   716 pts/2    R+   16:57   0:00 grep tcsh
>>  [root@C100273 iproute2-2.6.25]# ip/ip link set eth4 netns 21918
>>  RTNETLINK answers: Invalid argument
>>
>> Any idea what could cause that error?
>>   
> Assuming your prompt is showing the right version, try a version of  
> iproute2 >= 2.6.26

Right, this was a bit of a pain for me - when you install iproute,
by default it goes into another location, so you probably have to
specify /usr/local/sbin/ip or something.  Just a guess, but that
may be your problem here :)

-serge
