From: Ted Ts'o <tytso@mit.edu>
Subject: Re: Detecting if you are running in a container
Date: Mon, 10 Oct 2011 21:32:01 -0400
Message-ID: <20111011013201.GA7948@thunk.org>
References: <1317943022.1095.25.camel@mop>
 <20111007074904.GC16723@count0.beaverton.ibm.com>
 <20111007160113.GB14201@tango.0pointer.de>
 <m17h4g2jqy.fsf@fess.ebiederm.org>
 <20111010163140.GA22191@tango.0pointer.de>
 <m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Lennart Poettering <mzxreary@0pointer.de>, Matt Helsley <matthltc@us.ibm.com>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

On Mon, Oct 10, 2011 at 01:59:10PM -0700, Eric W. Biederman wrote:
> Lennart Poettering <mzxreary@0pointer.de> writes:
> 
> > To make a standard distribution run nicely in a Linux container you
> > usually have to make quite a number of modifications to it and disable
> > certain things from the boot process. Ideally however, one could simply
> > boot the same image on a real machine and in a container and would just
> > do the right thing, fully stateless. And for that you need to be able to
> > detect containers, and currently you can't.
> 
> I agree getting to the point where we can run a standard distribution
> unmodified in a container sounds like a reasonable goal.

Hmm, interesting.  It's not clear to me that running a full standard
distribution in a container is always going to be what everyone wants
to do.

The whole point of containers versus VM's is that containers are
lighter weight.  And one of the ways that containers can be lighter
weight is if you don't have to have N copies of udev, dbus, running in
each container/VM.

If you end up so much overhead to provide the desired security and/or
performance isolation, then it becomes fair to ask the question
whether you might as well pay a tad bit more and get even better
security and isolation by using a VM solution....

	     	       	  	     - Ted
