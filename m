From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Detecting if you are running in a container
Date: Mon, 10 Oct 2011 23:54:39 -0700
Message-ID: <m1lisshvbk.fsf@fess.ebiederm.org>
References: <1317943022.1095.25.camel@mop>
	<20111007074904.GC16723@count0.beaverton.ibm.com>
	<20111007160113.GB14201@tango.0pointer.de>
	<m17h4g2jqy.fsf@fess.ebiederm.org>
	<20111010163140.GA22191@tango.0pointer.de>
	<m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
	<20111010214148.GB26510@tango.0pointer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111010214148.GB26510@tango.0pointer.de> (Lennart Poettering's
	message of "Mon, 10 Oct 2011 23:41:48 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Lennart Poettering <mzxreary@0pointer.de>
Cc: Matt Helsley <matthltc@us.ibm.com>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

Lennart Poettering <mzxreary@0pointer.de> writes:

> On Mon, 10.10.11 13:59, Eric W. Biederman (ebiederm@xmission.com) wrote:

>> My list of things that still have work left to do looks like:
>> - cgroups.  It is not safe to create a new hierarchies with groups
>>   that are in existing hierarchies.  So cgroups don't work.
>
> Well, for systemd they actually work quite fine since systemd will
> always place its own cgroups below the cgroup it is started in. cgroups
> hence make these things nicely stackable.
>
> In fact, most folks involved in cgroups userspace have agreed to these
> rules now:
>
> http://www.freedesktop.org/wiki/Software/systemd/PaxControlGroups

Wow.   Are cgroups really that complicated to use?  A list of rules
a page long on what you have to do to make them useful and non-conflict.
Something seems off.  Perhaps we need a rule don't mount multiple
controllers in the same hierarchy.

Eric
