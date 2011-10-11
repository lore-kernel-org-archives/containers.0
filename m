From: david@lang.hm
Subject: Re: Detecting if you are running in a container
Date: Tue, 11 Oct 2011 15:25:27 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1110111520210.28233@asgard.lang.hm>
References: <1317943022.1095.25.camel@mop> <20111007074904.GC16723@count0.beaverton.ibm.com> <20111007160113.GB14201@tango.0pointer.de> <m17h4g2jqy.fsf@fess.ebiederm.org> <20111010163140.GA22191@tango.0pointer.de> <m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
 <20111011013201.GA7948@thunk.org> <20111011020530.GG16723@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111011020530.GG16723@count0.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Ted Ts'o <tytso@mit.edu>, "Eric W. Biederman" <ebiederm@xmission.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

On Mon, 10 Oct 2011, Matt Helsley wrote:

> On Mon, Oct 10, 2011 at 09:32:01PM -0400, Ted Ts'o wrote:
>> On Mon, Oct 10, 2011 at 01:59:10PM -0700, Eric W. Biederman wrote:
>>> Lennart Poettering <mzxreary@0pointer.de> writes:
>>>
>>>> To make a standard distribution run nicely in a Linux container you
>>>> usually have to make quite a number of modifications to it and disable
>>>> certain things from the boot process. Ideally however, one could simply
>>>> boot the same image on a real machine and in a container and would just
>>>> do the right thing, fully stateless. And for that you need to be able to
>>>> detect containers, and currently you can't.
>>>
>>> I agree getting to the point where we can run a standard distribution
>>> unmodified in a container sounds like a reasonable goal.
>>
>> Hmm, interesting.  It's not clear to me that running a full standard
>> distribution in a container is always going to be what everyone wants
>> to do.
>>
>> The whole point of containers versus VM's is that containers are
>> lighter weight.  And one of the ways that containers can be lighter
>> weight is if you don't have to have N copies of udev, dbus, running in
>> each container/VM.
>>
>> If you end up so much overhead to provide the desired security and/or
>> performance isolation, then it becomes fair to ask the question
>> whether you might as well pay a tad bit more and get even better
>> security and isolation by using a VM solution....
>>
>> 	     	       	  	     - Ted
>
> Yes, it does detract from the unique advantages of using a container.
> However, I think the value here is not the effeciency of the initial
> system configuration but the fact that it gives users a better place to
> start.
>
> Right now we're effectively asking users to start with non-working
> and/or unfamiliar systems and repair them until they work.
>
> By enabling unmodified distro installs in a container we're starting
> at the other end. The choices may not be the most efficient but the
> user may begin tuning from a working configuration. They can learn
> about and tune those parts that prove significant for their workload.
> This is better because in the end it's not just about how efficient the
> user  can make their containers but how much effort they will spend
> achieving and maintainingg that efficiency over time.

what's needed isn't a way to run all the daemons, processes and startup 
scripts that a distro uses in a container without conflicting with the 
parent, but instead a easy way to create the appropriate config changes in 
the parent, bind mounts, cgroups, etc  for the container and startup the 
apps that are wanted in the container.

This needs to be something with a lot of knowledge and hooks in the 
parent, so it's not just a matter of adding a way to detect "am I in a 
container" or not.

when I run things in containers, I want to bind mount some things from the 
parent, I want to configure syslog to listen on /dev/log inside the 
container, and then I want to starup just the processes I am planning to 
use inside the container, not all the daemons and other processes that I 
need to run the service the container is built for.

David Lang
