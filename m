From: Ying Han <yinghan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2009 kernel summit preparation for 'containers end-game'
	discussion
Date: Tue, 6 Oct 2009 11:54:49 -0700
Message-ID: <604427e00910061154q7cc10804w3b2b6cd1c217aa3a@mail.gmail.com>
References: <20091006155637.GA14761@us.ibm.com>
	<604427e00910060953l2d14fa8ci3923320dfaeb6490@mail.gmail.com>
	<20091006182154.GB18694@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091006182154.GB18694-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Oct 6, 2009 at 11:21 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> Wow, detailed notes - thanks, I'm still looking through them.  If you don't
> mind, I'll use a link to the archive of this email
> (
> https://lists.linux-foundation.org/pipermail/containers/2009-October/021227.html
> )
> in the final summary.
>
> Sure. The archive works with me.   :)

--Ying

thanks,
> -serge
>
> Quoting Ying Han (yinghan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> > On Tue, Oct 6, 2009 at 8:56 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> wrote:
> > > Hi,
> > >
> > > the kernel summit is rapidly approaching. One of the agenda
> > > items is 'the containers end-game and how do we get there.'
> > > As of now I don't yet know who will be there to represent the
> > > containers community in that discussion.  I hope there is
> > > someone planning on that?  In the hopes that there is, here is
> > > a summary of the info I gathered in June, in case that is
> > > helpful.  If it doesn't look like anyone will be attending
> > > ksummit representing containers, then I'll send the final
> > > version of this info to the ksummit mailing list so that someone
> > > can stand in.
> > >
> > > 1. There will be an IO controller minisummit before KS.  I
> > > trust someone (Balbir?) will be sending meeting notes to
> > > the cgroup list, so that highlights can be mentioned at KS?
> > >
> > > 2. There was a checkpoint/restart BOF plus talk at plumber's.
> > > Notes on the BOF are here:
> > >
> >
> https://lists.linux-foundation.org/pipermail/containers/2009-September/020915.html
> > >
> > > 3. There was an OOM notification talk or BOF at plumber's.
> > > Dave or Balbir, are there any notes about that meeting?
> > Serge:
> > Here are some notes I took from Dave's OOM talk:
> >
> > Change the OOM killer's policy.
> >
> > The current goal of OOM killer is to kill a rogue memory hogging task
> which
> > will lead to future memory freeing, and allow the system or container to
> > resume normal operation. Under OOM condition, kernel scans the tasklist
> of
> > the system or container and scores each task based on heuristic
> mechanism.
> > The task with highest score is picked to kill. Also kernel provides
> > /proc/pid/oom_adj API for adding user policy on top of the score, it
> allows
> > admin to tune the "badness" on task basis.
> >
> > Linux Theory: A free page is a wasted page of RAM and Linux will always
> fill
> > up memory with disk caches. When we time stamp the running time of an
> > application, we normally follow the sequence "flush cache - time - run
> app -
> > time - flush cache". So being OOM is normal and it is not a bug.
> >
> > Linux-mm has a list descripting the possible OOM conditions.
> > http://linux-mm.org/OOM
> >
> > User Perspectives:
> > High Performance Computing: I will take as much memory can be given,
> Please
> > tell me how much memory that is. In these systems, swapping is the devil.
> >
> > Enterprise: Applications do their own memory management.If the system
> gets
> > lowmem, I want the the kernel to tell me, and I will give some of mine
> back.
> > Memory notification system brings up lots of attention. Couple of
> proposals
> > have been posted in linux-mm and none of them seems fulfill all the
> > requirements.
> >
> > Desktop: This is the OOM designed for. When OpenOffice/Firefox flows up,
> > please just kill it quickly, i will reopen it in a minute. Besides,
> Please
> > don't kill sshd.
> >
> > Memory Reclaim
> > If no free memory, we scan the LRU and try to free pages. Recent issues
> on
> > page reclaim focuses on scalability. In 1991 with 4M of DRAM, We have
> 1024
> > pages to scan. In 2009 with 4G of DRAM, we have1048576 pages to scan. The
> > increasing of the memory size makes reclaim job harder and harder.
> >
> > Beat the LRU into shape
> > * Never run out of memory, never reclaim and never look at the LRU.
> > * Use large size pagesize. IBM uses 64k page instead of 4k page. "IBM
> uses
> > 64K page, more on the kernel issue change than userpace change if they
> use
> > libc"
> > * Keep troublesome pages off the LRU lists including unreclaimable pages
> > (anon, mlock, shm, slab, dirty pages)
> > and Hugetlbfs which are not counted on RSS.
> > * Split up the LRU lists. It includes the NUMA implementation as well as
> the
> > unevictable patch from Rik (~2.6.28)
> > What is next:
> >
> > Having the OOM killer always pick the "right" application to kill is a
> tough
> > problem and it has been the hot topic in upstream with several patches
> > posted. Notification system has lots of attention during the talk, here
> are
> > the summary of current posted patches:
> >
> > Linux killed Kenny, bastard!
> > Evgeniy Polyakov posted the patch early this year. What the patch does is
> to
> > provide an API that admin can specify the oom victim by the process name.
> > No one likes the patch in linux-mm. The argument is on the current
> mechanism
> > of caculating "badness score" which is way complex for admin to determin
> > which task to kill. Alan Cox simply answered the question: "its
> > always heuristic", and he also pointed out "What you actually need is
> > notifiers to work on /proc. In fact containers are probably the right way
> to
> > do it".
> >
> > Cgroup based OOM killer controller
> > Nikanth Karthikesan re-posted the patch which adding the cgroup support.
> The
> > patch added an adjustable value "oom.victim" for each oom cgroup. The OOM
> > killer would kill all the processes in a cgruop with a higher oom.victim
> > value before killing a process in a cgroup with lower oom.victim value.
> > Among those tasks with the same oom.victim value, the usual "badness"
> > heuristics would be applied.
> > It is one step further which takes use of the cgroup hireachy for the OOM
> > killer subsystem. However, the same question had been raised "What is the
> > difference between oom_adj and this oom.victim to user?". Nikanth
> answered
> > to that question "Using this oom.victim users can specify the exact order
> to
> > kill processes.". Another word, oom_adj works as a hint to the kernel
> while
> > oom_victim gives strict order.
> >
> > Per-cgroup OOM handler
> > Ying Han posted the google in-house patch into linux-mm which defers the
> OOM
> > kill decisions to userspace. It allows userspace to respond the OOM by
> > adding nodes, dropping caches, elevating memcg limit or sending signal.
> An
> > alternative is to use /dev/mem_notify which David Rientjes proposed in
> > linux-mm. The idea is similar, instead of waiting on oom_await, userspace
> > can poll the information during lowmem condition and respond
> > correspondingly.
> >
> > Vladislav Buzov posted the patch which extends the memcg by adding the
> > notification system on system lowmem condition. The feedbacks looks
> > promising this time, Although there still lots of changes needs to be
> done.
> > Discussions focused on the implementation of the notification mechanism.
> > Balbir Singh mentioned the cgroupstats - a genetlink based mechanism for
> > event delivery and request/respondse applications. Paul Menage proposed
> > couple of options including new ioctl on cgroup files, new syscall and
> new
> > per-cgroup file.
> >
> > --Ying Han
> >
> > >
> > > 4. The actual title of the KS discussion is 'containers end-game'.
> > > The containers-specific info I gathered in June was mainly about
> > > additional resources which we might containerize.  I expect that
> > > will be useful in helping the KS community decide how far down
> > > the containerization path they are willing to go - i.e. whether
> > > we want to call what we have good enough and say you must use kvm
> > > for anything more, whether we want to be able to provide all the
> > > features of a full VM with containers, or something in between,
> > > say targetting specific uses (perhaps only expand on cooperative
> > > resource management containers).  With that in mind, here are
> > > some items that were mentioned in June as candidates for
> > > more containerization work
> > >
> > >        1. Cpu hard limits, memory soft limits (Balbir)
> > >        2. Large pages, mlock, shared page accounting (Balbir)
> > >        3. Oom notification (Balbir - was anything decided on this
> > >                at plumber's?)
> > >        4. There is agreement on getting rid of the ns cgroup,
> > >                provided that:
> > >                a. user namespaces can provide container confinement
> > >                guarantees
> > >                b. a compatibility flag is created to clone parent
> > >                cgroup when creating a new cgroup (Paul and Daniel)
> > >        5. Poweroff/reboot handling in containers (Daniel)
> > >        6. Full user namespaces to segragate uids in different
> > >                containers and confine root users in containers, i.e.
> > >                with respect to file systems like cgroupfs.
> > >        7. Checkpoint/restart (c/r) will want time virtualization
> (Daniel)
> > >        8. C/r will want inode virtualization (Daniel)
> > >        9. Sunrpc containerization (required to allow multiple
> > >                containers separate NFS client access to the same
> server)
> > >        10. Sysfs tagging, support for physical netifs to migrate
> > >                network namespaces, and /sys/class/net virtualization
> > >
> > > Again the point of this list isn't to ask for discussion about
> > > whether or how to implement each at this KS, but rather to give
> > > an idea of how much work is left to do.  Though let the discussion
> > > lead where it may of course.
> > >
> > > I don't have it here, but maybe it would also be useful to
> > > have a list ready of things we can do today with containerization?
> > > Both with upstream, and with under-development patchsets.
> > >
> > > I also hope that someone will take notes on the ksummit
> > > discussion to send to the containers and cgroup lists.
> > > I expect there will be a good LWN writeup, but a more
> > > containers-focused set of notes will probably be useful
> > > too.
> > >
> > > thanks,
> > > -serge
> > > _______________________________________________
> > > Containers mailing list
> > > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > > https://lists.linux-foundation.org/mailman/listinfo/containers
> > >
>
