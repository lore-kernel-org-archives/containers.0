From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: Detecting if you are running in a container
Date: Wed, 12 Oct 2011 18:59:07 +0200
Message-ID: <CAPXgP13npxh6UoEtXNiZ+Lhe_QxpO8-7r==WuUXDnNr+sHGXMw@mail.gmail.com>
References: <1317943022.1095.25.camel@mop> <20111007074904.GC16723@count0.beaverton.ibm.com>
 <20111007160113.GB14201@tango.0pointer.de> <m17h4g2jqy.fsf@fess.ebiederm.org>
 <20111010163140.GA22191@tango.0pointer.de> <m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
 <20111010214148.GB26510@tango.0pointer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111010214148.GB26510@tango.0pointer.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Lennart Poettering <mzxreary@0pointer.de>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Matt Helsley <matthltc@us.ibm.com>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

On Mon, Oct 10, 2011 at 23:41, Lennart Poettering <mzxreary@0pointer.de=
> wrote:
> On Mon, 10.10.11 13:59, Eric W. Biederman (ebiederm@xmission.com) wro=
te:

>> - udev. =C2=A0All of the kernel interfaces for udev should be suppor=
ted in
>> =C2=A0 current kernels. =C2=A0However I believe udev is useless beca=
use container
>> =C2=A0 start drops CAP_MKNOD so we can't do evil things. =C2=A0So I =
would
>> =C2=A0 recommend basing the startup of udev on presence of CAP_MKNOD=
=2E
>
> Using CAP_MKNOD as test here is indeed a good idea. I'll make sure ud=
ev
> in a systemd world makes use of that.

Done.

http://git.kernel.org/?p=3Dlinux/hotplug/udev.git;a=3Dcommitdiff;h=3D93=
71e6f3e04b03692c23e392fdf005a08ccf1edb

Thanks,
Kay
