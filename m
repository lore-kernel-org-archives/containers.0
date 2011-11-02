From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [lxc-devel] Detecting if you are running in a container
Date: Wed, 02 Nov 2011 12:08:19 +0400
Message-ID: <4EB0FA73.1020600@msgid.tls.msk.ru>
References: <1317943022.1095.25.camel@mop> <20111007074904.GC16723@count0.beaverton.ibm.com> <20111007160113.GB14201@tango.0pointer.de> <m17h4g2jqy.fsf@fess.ebiederm.org> <20111010163140.GA22191@tango.0pointer.de> <m1mxd8lg0x.fsf_-_@fess.ebiederm.org> <20111010214148.GB26510@tango.0pointer.de> <CAPXgP13npxh6UoEtXNiZ+Lhe_QxpO8-7r==WuUXDnNr+sHGXMw@mail.gmail.com> <4EB06D27.4020507@msgid.tls.msk.ru> <m17h3js8p1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m17h3js8p1.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Kay Sievers <kay.sievers@vrfy.org>, Lennart Poettering <mzxreary@0pointer.de>, greg@kroah.com, Paul Menage <paul@paulmenage.org>, linux-kernel@vger.kernel.org, david@fubar.dk, Linux Containers <lxc-devel@lists.sourceforge.net>, Linux Containers <containers@lists.osdl.org>, "Serge E. Hallyn" <serge@hallyn.com>, harald@redhat.com
List-Id: containers.vger.kernel.org

On 02.11.2011 03:51, Eric W. Biederman wrote:
[]
>> And having CAP_MKNOD in container may not be that bad either, while
>> cgroup device.permission is set correctly - some nodes may need to
>> be created still, even in an unprivileged containers.  Who filters
>> out CAP_MKNOD during container startup (I don't see it in the code,
>> which only removes CAP_SYS_BOOT, and even that due to current
>> limitation), and which evil things can be done if it is not filtered?
> 
> If you don't filter which device nodes you a process can read/write then
> that process can access any device on the system.  Steal the keyboard,
> the X display, access any filesystem, directly access memory.  Basically
> the process can escalate that permission to full control of the system
> without needing any kernel bugs to help it.

There's cap_mknod, and cgroup/devices.{allow,deny}.  Even with CAP_MKNOD,
container can not _use_ devices not allowed in the latter.  That's what
I'm talking about - there's more fine control exist than CAP_MKNOD.  And
my question was about this context - with proper cgroup-level device
control in place, what bad CAP_MKNOD have?

Thanks,

/mjt
