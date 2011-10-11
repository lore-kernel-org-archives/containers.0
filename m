From: Theodore Tso <tytso@MIT.EDU>
Subject: Re: Detecting if you are running in a container
Date: Tue, 11 Oct 2011 08:53:46 -0400
Message-ID: <203BBB0D-293D-4BFB-A57B-41C56F58F9B3@mit.edu>
References: <1317943022.1095.25.camel@mop> <20111007074904.GC16723@count0.beaverton.ibm.com> <20111007160113.GB14201@tango.0pointer.de> <m17h4g2jqy.fsf@fess.ebiederm.org> <20111010163140.GA22191@tango.0pointer.de> <m1mxd8lg0x.fsf_-_@fess.ebiederm.org> <20111011013201.GA7948@thunk.org> <20111011020530.GG16723@count0.beaverton.ibm.com> <20111011032523.GB7948@thunk.org> <m1ty7ghvvn.fsf@fess.ebiederm.org>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1ty7ghvvn.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Theodore Tso <tytso@mit.edu>, Matt Helsley <matthltc@us.ibm.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org


On Oct 11, 2011, at 2:42 AM, Eric W. Biederman wrote:

> I am totally in favor of not starting the entire world.  But just
> like I find it convienient to loopback mount an iso image to see
> what is on a disk image.  It would be handy to be able to just
> download a distro image and play with it, without doing anything
> special.

Agreed, but what's wrong with firing up KVM to play with a distro image?  Personally, I don't consider that "doing something special".

> 
>> Things should just work, except that
>> processes in one container can't use more than their fair share (as
>> dictated by policy) of memory, CPU, networking, and I/O bandwidth.
> 
> You have to be careful with the limiters.  The fundamental reason
> why containers are more efficient than hardware virtualization is
> that with containers we can do over commit of resources, especially
> memory.  I keep seeing implementations of resource limiters that want
> to do things in a heavy handed way that break resource over commit.

Oh, sure.   Resource limiting is something that should be done only when there are other demands on the resource in question.   Put another way, it should be considered more of a resource guarantee than a resource limit.   (You will have at least 10% of the CPU, not at most 10% of the CPU.)

> 
> I don't know what concern you have security wise, but the problem that
> wants to be solved with user namespaces is something you hit much
> earlier than when you worry about sharing a kernel between mutually
> distrusting users.  Right now root inside a container is root rout
> outside of a container just like in a chroot jail.  Where this becomes a
> problem is that people change things like like
> /proc/sys/kernel/print-fatal-signals expecting it to be a setting local
> to their sand box when in fact the global setting and things start
> behaving weirdly for other users.  Running sysctl -a during bootup 
> has that problem in spades.

The moment you start caring about global sysctl settings is the moment I start wondering whether or not VM and separate kernel images is the better solution.   Do we really want to add so much complexity that we are multiplexing different sysctl settings across containers?   To my mind, that way lies madness, and in some cases, it simply can't be done from a semantics perspective.

> 
> With my sysadmin hat on I would not want to touch two untrusting groups
> of users on the same machine.  Because of the probability there is at
> least one security hole that can be found and exploited to allow
> privilege escalation.
> 
> With my kernel developer hat on I can't just say surrender to the
> idea that there will in fact be a privilege escalation bug that
> is easy to exploit.  The code has to be built and designed so that
> privilege escalation is difficult.  Otherwise we might as well
> assume if you visit a website an stealthy worm has taken over your
> computer.

Oh, I agree that we should try to stop privilege escalation attacks.  And it will be a grand and glorious fight, like Leonidas and his 300 men at the pass at Thermopylae.   :-)   Or it will be like Steve Jobs struggling against cancer.  It's a fight that you know that you're going to lose, but it's not about winning or losing but how much you accomplish and how you fight that counts.

Personally, though, if the issue is worries about visiting a website, the primary protection against that has got to be done  at the browser level (i.e., the process level sandboxing done by Chrome).

-- Ted
