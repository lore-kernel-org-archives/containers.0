From: Greg Kurz <gkurz@fr.ibm.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was
 Vpid:)
Date: Wed, 22 Jun 2011 17:29:25 +0200
Message-ID: <1308756565.2959.65.camel@bahia.local>
References: <20110615145527.4016.70157.stgit@bahia.local>
	 <BANLkTimSC_OSrbekhM=wd2Gie4np3Q4F5A@mail.gmail.com>
	 <1308570316.8230.140.camel@bahia.local>
	 <BANLkTiknqo0iKry7mjq+mc4iOWj_A_mrrw@mail.gmail.com>
	 <m1ei2o9l7a.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1ei2o9l7a.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Bryan Donlan <bdonlan@gmail.com>, akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, serge@hallyn.com, daniel.lezcano@free.fr, oleg@redhat.com, xemul@openvz.org, Cedric Le Goater <clg@vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Mon, 2011-06-20 at 15:44 -0700, Eric W. Biederman wrote:
> Bryan Donlan <bdonlan@gmail.com> writes:
> 
> > On Mon, Jun 20, 2011 at 07:45, Greg Kurz <gkurz@fr.ibm.com> wrote:
> >> On Thu, 2011-06-16 at 13:54 -0400, Bryan Donlan wrote:
> >
> >>> Although getting the in-namespace PID is a useful thing, wouldn't a
> >>> truly race-free API be preferable? Any access by PID has the race
> >>> condition in which the target process could die, and its PID get
> >>> recycled between retrieving the PID and doing something with it.
> >>
> >> Well the PID is a racy construct when used by another task than the
> >> parent... fortunately, most userland code can cope with it ! :)
> >
> > That doesn't mean we shouldn't try to fix the race! :)
> >
> >>> Perhaps a file-descriptor API would be better, such as something like
> >>> this:
> >>>
> >>> int openpid(int id, int flags);
> >>> int rt_sigqueueinfo_fd(int process_fd, int sig, siginfo_t *info);
> >>> int sigqueue_fd(int process_fd, int sig, const union sigval value); //
> >>> glibc wrapper
> >>>
> >>
> >> The race still exists: openpid() is being passed a PID... Only the
> >> parent can legitimately know that this PID identifies a specific
> >> unwaited child.
> >
> > Yes, the idea would be either the parent process, or the target
> > process itself would open the PID, then pass the resulting file
> > descriptor to whatever process is actually doing the killing.
> > Alternately, one could add additional calls to help identify whether
> > the right process was opened (perhaps a call to get a directory handle
> > to the corresponding /proc directory?)
> 
> fd = open("/proc/self/", O_DIRECTORY);
> ?
> 
> Doing something based on proc files seems like a reasonable direction to
> head if we are working on a race free api.
> 
> I suspect all we need is a sigqueue file.
> 

Are you referring to Bryan's rt_sigqueueinfo_fd() syscall or to a
new /proc/self/sigqueue file ?

-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
