From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was Vpid:)
Date: Wed, 22 Jun 2011 17:39:38 -0700
Message-ID: <m1oc1pl6t1.fsf@fess.ebiederm.org>
References: <20110615145527.4016.70157.stgit@bahia.local>
	<BANLkTimSC_OSrbekhM=wd2Gie4np3Q4F5A@mail.gmail.com>
	<1308570316.8230.140.camel@bahia.local>
	<BANLkTiknqo0iKry7mjq+mc4iOWj_A_mrrw@mail.gmail.com>
	<m1ei2o9l7a.fsf@fess.ebiederm.org>
	<1308756565.2959.65.camel@bahia.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1308756565.2959.65.camel@bahia.local> (Greg Kurz's message of
	"Wed, 22 Jun 2011 17:29:25 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Kurz <gkurz@fr.ibm.com>
Cc: Bryan Donlan <bdonlan@gmail.com>, akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, serge@hallyn.com, daniel.lezcano@free.fr, oleg@redhat.com, xemul@openvz.org, Cedric Le Goater <clg@vnet.ibm.com>
List-Id: containers.vger.kernel.org

Greg Kurz <gkurz@fr.ibm.com> writes:

> On Mon, 2011-06-20 at 15:44 -0700, Eric W. Biederman wrote:
>> fd = open("/proc/self/", O_DIRECTORY);
>> ?
>> 
>> Doing something based on proc files seems like a reasonable direction to
>> head if we are working on a race free api.
>> 
>> I suspect all we need is a sigqueue file.
>> 
>
> Are you referring to Bryan's rt_sigqueueinfo_fd() syscall or to a
> new /proc/self/sigqueue file ?

I was suggesting implement rt_sigqueueinfo_fd as a proc file instead.

Getting a file descriptor api one way or another for delivering signals
sounds nice in principle.  I don't know if it is useful enough to
justify the cost of implementing and supporting it.

Eric
