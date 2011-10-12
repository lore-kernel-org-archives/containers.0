From: david@lang.hm
Subject: Re: Detecting if you are running in a container
Date: Tue, 11 Oct 2011 22:10:56 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1110112208230.12310@asgard.lang.hm>
References: <1317943022.1095.25.camel@mop> <20111007074904.GC16723@count0.beaverton.ibm.com> <20111007160113.GB14201@tango.0pointer.de> <m17h4g2jqy.fsf@fess.ebiederm.org> <20111010163140.GA22191@tango.0pointer.de> <m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
 <20111011013201.GA7948@thunk.org> <20111011020530.GG16723@count0.beaverton.ibm.com> <20111011032523.GB7948@thunk.org> <m1ty7ghvvn.fsf@fess.ebiederm.org> <203BBB0D-293D-4BFB-A57B-41C56F58F9B3@mit.edu> <m17h4bfcuv.fsf@fess.ebiederm.org>
 <alpine.DEB.2.02.1110111525450.28233@asgard.lang.hm> <m139eyg7if.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m139eyg7if.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Theodore Tso <tytso@MIT.EDU>, Matt Helsley <matthltc@us.ibm.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

On Tue, 11 Oct 2011, Eric W. Biederman wrote:

> david@lang.hm writes:
>
>> On Tue, 11 Oct 2011, Eric W. Biederman wrote:
>>
>>> Theodore Tso <tytso@MIT.EDU> writes:
>>>
>>>> On Oct 11, 2011, at 2:42 AM, Eric W. Biederman wrote:
>>>>
>>> I admit for a lot of test cases that it makes sense not to use a full
>>> set of userspace daemons.  At the same time there is not particularly
>>> good reason to have a design that doesn't allow you to run a full
>>> userspace.
>>
>> how do you share the display between all the different containers if they are
>> trying to run the X server?
>
> Either X does not start because the hardware it needs is not present or
> Xnest or similar gets started.
>
>> how do you avoid all the containers binding to the same port on the default IP
>> address?
>
> Network namespaces.
>
>> how do you arbitrate dbus across the containers.
>
> Why should you?

because the containers are simulating different machines, and dbus doesn't 
work arcross different machines.

>> when a new USB device gets plugged in, which container gets control of
>> it?
>
> None of them.  Although today they may all get the uevent.  None of the
> containers should have permission to call mknod to mess with it.

why would the software inside a container not have the rights to do a 
mknod inside the container?

>> there are a LOT of hard questions when you start talking about running a full
>> system inside a container that do not apply for other use of
>> containers.
>
> Not really mostly the answer is that you say no.
>
> Eric
>

David Lang
