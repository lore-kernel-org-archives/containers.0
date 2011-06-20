From: Greg Kurz <gkurz@fr.ibm.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was
 Vpid:)
Date: Mon, 20 Jun 2011 13:45:16 +0200
Message-ID: <1308570316.8230.140.camel@bahia.local>
References: <20110615145527.4016.70157.stgit@bahia.local>
	 <BANLkTimSC_OSrbekhM=wd2Gie4np3Q4F5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTimSC_OSrbekhM=wd2Gie4np3Q4F5A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Bryan Donlan <bdonlan@gmail.com>
Cc: akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, serge@hallyn.com, daniel.lezcano@free.fr, ebiederm@xmission.com, oleg@redhat.com, xemul@openvz.org, Cedric Le Goater <clg@vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Thu, 2011-06-16 at 13:54 -0400, Bryan Donlan wrote:
> On Wed, Jun 15, 2011 at 10:55, Greg Kurz <gkurz@fr.ibm.com> wrote:
> > Since pid namespaces were introduced, there's a recurring demand: how one
> > can correlate a pid from a child pid ns with a pid from a parent pid ns ?
> > The need arises in the LXC community when one wants to send a signal from
> > the host (aka. init_pid_ns context) to a container process for which one
> > only knows the pid inside the container.
> >
> > In the future, this should be achievable thanks to Eric Biederman's setns()
> > syscall but there's still some work to be done to support pid namespaces:
> >
> > https://lkml.org/lkml/2011/5/21/162
> >
> > As stated by Serge Hallyn in:
> >
> > http://sourceforge.net/mailarchive/message.php?msg_id=27424447
> >
> > "There is nothing that gives you a 100% guaranteed correct race-free
> > correspondence right now.  You can look under /proc/<pid>/root/proc/ to
> > see the pids valid in the container, and you can relate output of
> > lxc-ps --forest to ps --forest output.  But nothing under /proc that I
> > know of tells you "this task is the same as that task".  You can't
> > even look at /proc/<pid> inode numbers since they are different
> > filesystems for each proc mount."
> >
> > This patch adds a single line to /proc/self/status. Provided one has kept
> > track of its container tasks (with a cgroup like liblxc does for example),
> > he may correlate global pids and container pids. This is still racy but
> > definitely easier than what we have today.
> 
> Although getting the in-namespace PID is a useful thing, wouldn't a
> truly race-free API be preferable? Any access by PID has the race
> condition in which the target process could die, and its PID get
> recycled between retrieving the PID and doing something with it.

Well the PID is a racy construct when used by another task than the
parent... fortunately, most userland code can cope with it ! :)

> Perhaps a file-descriptor API would be better, such as something like
> this:
> 
> int openpid(int id, int flags);
> int rt_sigqueueinfo_fd(int process_fd, int sig, siginfo_t *info);
> int sigqueue_fd(int process_fd, int sig, const union sigval value); //
> glibc wrapper
> 

The race still exists: openpid() is being passed a PID... Only the
parent can legitimately know that this PID identifies a specific
unwaited child.

> The opened process FD could be passed across a unix domain socket to a
> process outside the namespace, which could then send signals without
> knowing the in-namespace PID. This same API can be easily extended to
> cover other syscalls which may require PIDs as well.

Indeed, the idea of not exposing a PID from another namespace sounds
nice.

-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
