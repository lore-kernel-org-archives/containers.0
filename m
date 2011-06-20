From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was Vpid:)
Date: Mon, 20 Jun 2011 15:44:57 -0700
Message-ID: <m1ei2o9l7a.fsf@fess.ebiederm.org>
References: <20110615145527.4016.70157.stgit@bahia.local>
	<BANLkTimSC_OSrbekhM=wd2Gie4np3Q4F5A@mail.gmail.com>
	<1308570316.8230.140.camel@bahia.local>
	<BANLkTiknqo0iKry7mjq+mc4iOWj_A_mrrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTiknqo0iKry7mjq+mc4iOWj_A_mrrw@mail.gmail.com> (Bryan
	Donlan's message of "Mon, 20 Jun 2011 13:37:24 -0400")
Sender: linux-kernel-owner@vger.kernel.org
To: Bryan Donlan <bdonlan@gmail.com>
Cc: Greg Kurz <gkurz@fr.ibm.com>, akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, serge@hallyn.com, daniel.lezcano@free.fr, oleg@redhat.com, xemul@openvz.org, Cedric Le Goater <clg@vnet.ibm.com>
List-Id: containers.vger.kernel.org

Bryan Donlan <bdonlan@gmail.com> writes:

> On Mon, Jun 20, 2011 at 07:45, Greg Kurz <gkurz@fr.ibm.com> wrote:
>> On Thu, 2011-06-16 at 13:54 -0400, Bryan Donlan wrote:
>
>>> Although getting the in-namespace PID is a useful thing, wouldn't a
>>> truly race-free API be preferable? Any access by PID has the race
>>> condition in which the target process could die, and its PID get
>>> recycled between retrieving the PID and doing something with it.
>>
>> Well the PID is a racy construct when used by another task than the
>> parent... fortunately, most userland code can cope with it ! :)
>
> That doesn't mean we shouldn't try to fix the race! :)
>
>>> Perhaps a file-descriptor API would be better, such as something like
>>> this:
>>>
>>> int openpid(int id, int flags);
>>> int rt_sigqueueinfo_fd(int process_fd, int sig, siginfo_t *info);
>>> int sigqueue_fd(int process_fd, int sig, const union sigval value); //
>>> glibc wrapper
>>>
>>
>> The race still exists: openpid() is being passed a PID... Only the
>> parent can legitimately know that this PID identifies a specific
>> unwaited child.
>
> Yes, the idea would be either the parent process, or the target
> process itself would open the PID, then pass the resulting file
> descriptor to whatever process is actually doing the killing.
> Alternately, one could add additional calls to help identify whether
> the right process was opened (perhaps a call to get a directory handle
> to the corresponding /proc directory?)

fd = open("/proc/self/", O_DIRECTORY);
?

Doing something based on proc files seems like a reasonable direction to
head if we are working on a race free api.

I suspect all we need is a sigqueue file.

Eric
