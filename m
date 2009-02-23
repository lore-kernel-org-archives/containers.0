From: Paul Menage <menage@google.com>
Subject: Re: [RFC] [PATCH] cgroup: accounting and limitation of disk quota
Date: Mon, 23 Feb 2009 00:09:54 -0800
Message-ID: <6599ad830902230009mbfe7ddkf40f183c4a61a81a@mail.gmail.com>
References: <d95d44a20902220437m2fb7af08y8c71fe275fe06a57@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754254AbZBWIKS@vger.kernel.org>
In-Reply-To: <d95d44a20902220437m2fb7af08y8c71fe275fe06a57@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: anqin <anqin.qin@gmail.com>
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Rolando Martins <rolando.martins@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Hi An,

On Sun, Feb 22, 2009 at 4:37 AM, anqin <anqin.qin@gmail.com> wrote:
> The patch presents a cgroup subsystem to control the usage of disk quota.

Thanks for sending this patch.

My overall feeling is that disk quotas aren't really something that
you want to control at a cgroup level (i.e. associating a limit with a
specific set of processes), they're something that you want to control
at the directory hierarchy level (i.e. associate a limit with this
directory and all its children).

In the case of a virtual server these may well be the same thing - a
process in the virtual server can't touch any files outside the
virtual server's filespace, and stuff outside the virtual server will
be well-behaved and won't touch files inside the virtual server's
filespace.

But for systems that are doing resource isolation without
virtualization, this isn't necessarily still the case. A process may
have access to multiple areas of the disk with independent quotas.

E.g. I work on a job control system where each job has some private
disk space, and may share a common pool of disk space with some
related jobs on the same machine, for data that's shared between
multiple jobs.

In this case, there are separate disk quotas for the per-job private
areas and the shared area, so this cgroup-based approach wouldn't be
much use there. Something like Neil Brown's "tree quota" proposal from
way back in 2001 seemed much more useful for this kind of isolation.
The proposal was that you could associate a "tree id" with an inode,
and then that inode and all its children were accounted against the
quota of that tree id. The arguments against it were (AFAIR) mostly
about the non-determinism issues that could arise if a single inode
were hard-linked into multiple trees - essentially, the first time it
was accessed from either tree it would become part of that tree, even
though it was reachable (and modifiable) from the other tree. But as
long as root doesn't do anything silly, this isn't really an issue,
and similar issues arise with this cgroup-based approach - if a
process outside a virtual server moves a file into that virtual
server's filespace without updating the usage correctly (which AFAICS
can't be done atomically?) then the quota stats will be off.

More specific comments on this patch:

- it would make more sense to integrate with the existing DQUOT_XXX
macros rather than have to update every filesystem to include
references to cgroup quotas as well as regular quotas.

- disk_cgroup_read_stats() should be a read_map() handler, and
disk_cgroup_read_quota() should be a read_u64() handler.

- why do you have the checks and EPERM returns in disk_cgroup_create()
? cgroupfs already does permission checking.

Paul
