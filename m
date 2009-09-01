From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Tue, 01 Sep 2009 20:37:01 +0200
Message-ID: <4A9D69CD.8050109@free.fr>
References: <4A929F83.80207@free.fr>
	<20090826104312.97ff028f.kamezawa.hiroyu@jp.fujitsu.com>
	<4A952689.9020704@free.fr>
	<ac1c4bf20908260650x3311d5d3q44631a30205089b7@mail.gmail.com>
	<ac1c4bf20908261625g71dff96cu77190056540cbb7@mail.gmail.com>
	<4A97A448.5050506@free.fr> <20090831134045.GD4837@us.ibm.com>
	<4A9BE134.5040804@free.fr> <20090831145423.GA8107@us.ibm.com>
	<4A9BE9A9.1080907@free.fr> <20090831163114.GA13896@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090831163114.GA13896-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org, Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>   
>> Serge E. Hallyn wrote:
>>     
>>>> The idea of Kamezawa-san to use a fuse proc is maybe a good idea in 
>>>> this  case. So we can address the entire /proc specific informations. 
>>>> For      
>>>>         
>>> I agree, nice idea.  And hopefully pretty simple to whip up for the
>>> meminfo and cpuinfo files as an example.
>>>
>>> Are you thinking a fuse fs which takes a config file, holds an open
>>> ref to its ancestor /proc, and for each file looks in a config file to
>>> decide whether to show userspace:
>>> 	1. nothing
>>> 	2. the underlying file, unprocessed
>>> 	3. a simple ascii file instead
>>> 	4. the underlying file, processed?
>>>   
>>>       
>> Yes, exactly :)
>> But, I am not sure how to retrieve the container context, I mean how to  
>> pick and return the right information.
>> eg: in the container foo, when looking at /proc/meminfo, fuse-lxcfs  
>> should process /cgroup/foo/(somefiles), how to know the request is  
>> coming from 'foo' without doing multiple mount, one in each container ?
>>     
>
> Why without doing one mount per container?  :)
>
> I figure the container can be responsible for the actual mounting,
> if it cares.  The host/kernel should keep it *safe* for the container
> to use unfiltered /proc (, /sys, /cgroup, etc), but the container
> can be responsible for filtering it however much it feels necessary.
>
> (That fits with the 2006 kernel summit pseudo-decree that we are not
> trying to fake a container into thinking it is a real host, only
> make the container useful.)
>
> Are you worried about the extra memory overhead?
>   

Well, I am used to see a single instance of a daemon like sshfs :)
I am not used of fuse, I will play a bit with a trivial fuse-lxcfs to 
see how that behaves with a container.
