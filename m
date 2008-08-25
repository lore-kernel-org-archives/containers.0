From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/4] autofs4 - track uid and gid of last mount requester
Date: Mon, 25 Aug 2008 13:05:10 -0500
Message-ID: <20080825180510.GB665@us.ibm.com>
References: <20080807114002.4142.30417.stgit@web.messagingengine.com> <20080807114012.4142.83607.stgit@web.messagingengine.com> <20080807134650.a6a51f7d.akpm@linux-foundation.org> <20080807221242.GA27032@us.ibm.com> <1218167314.17093.79.camel@raven.themaw.net> <1218170643.17093.88.camel@raven.themaw.net> <20080808145824.GB10179@us.ibm.com> <1218261950.2994.37.camel@raven.themaw.net> <20080809133143.GA11490@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756503AbYHYSFt@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080809133143.GA11490@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Ian Kent <raven@themaw.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, autofs@linux.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue@us.ibm.com):
> Quoting Ian Kent (raven@themaw.net):
> > 
> > On Fri, 2008-08-08 at 09:58 -0500, Serge E. Hallyn wrote:
> > > Quoting Ian Kent (raven@themaw.net):
> > > > 
> > > > On Fri, 2008-08-08 at 11:48 +0800, Ian Kent wrote:
> > > > > > > 
> > > > > > > Please remind me again why autofs's use of current->uid and
> > > > > > > current->gid is not busted in the presence of PID namespaces, where
> > > > > > > these things are no longer system-wide unique?
> > > > > > 
> > > > > > I actually don't see what the autofs4_waitq->pid is used for.  It's
> > > > > > copied from current into wq->pid at autofs4_wait, and into a packet to
> > > > > > send to userspace (I assume) at autofs4_notify_daemon.
> > > > > > 
> > > > > > So as long as a daemon can serve multiple pid namespaces (which
> > > > > > doubtless it can), the pid could be confusing (or erroneous) for the
> > > > > > daemon.
> > > > > 
> > > > > Your point is well taken.
> > > > > 
> > > > > The pid is used purely for logging purposes to aid in debugging in user
> > > > > space. I'm not sure it is worth worrying about it too much as the daemon
> > > > > has no business interfering with user space processes it is not the
> > > > > owner of.
> > > > > 
> > > > > > 
> > > > > > If I'm remotely right about how the pid is being used, then the thing to
> > > > > > do would be to 
> > > > > > 	1. store the daemon's pid namespace  (would that belong in
> > > > > > 	the autofs_sb_info?)
> > > > >  
> > > > > Yep.
> > > > > 
> > > > > > 	2. store the task_pid(current) in the waitqueue
> > > > > > 	3. retrieve the pid_t for the waiting task in the daemon's
> > > > > > 	pid namespace, and put that into the packet at
> > > > > > 	autofs4_notify_daemon.
> > > > > > 
> > > > > > I realize this patch was about the *uids*, but the pids seem more
> > > > > > urgent.
> > > > > 
> > > > > OK, I get it.
> > > > > I'll have a go at doing this for completeness.
> > > > 
> > > > On second thoughts I'm not sure about this.
> > > > 
> > > > The pid that is logged needs to relate to a process in the name space of
> > > > the one that caused the mount to be done.
> > > > 
> > > > For example, suppose a GUI user finds mounts never expiring, then we get
> > > > a debug log to try and identify the culprit. So the pid should
> > > > correspond to a process that the user sees (So I guess in the namespace
> > > > of that user).
> > > > 
> > > > This is the only reason I added the pid to the request packet in the
> > > > first place.
> > > > 
> > > > Please correct me if my understanding of this is not right.
> > > 
> > > It's not wrong, but we just have to think through which value is the
> > > most useful.
> > > 
> > > Any process executing clone(CLONE_NEWPID) (with CAP_SYS_ADMIN) can start
> > > an application in a new pid namespace.  So imagine the user at the
> > > desktop clicking some button which runs an application in a new pid
> > > namespace.  Now if the user starts an xterm and runs ps -ef, the pid
> > > values he'll see for the tasks in that new namespace will not be the
> > > same as those which the application sees for itself, and not the same as
> > > those which, right now, autofs would report.
> > > 
> > > For instance, if I start a shell in a new pid namespace, then within the
> > > new pid namespace ps -ef gives me:
> > > 
> > > sh-3.2# ps -ef
> > > UID        PID  PPID  C STIME TTY          TIME CMD
> > > root         1     0  0 10:54 pts/1    00:00:00 /bin/sh
> > > root         5     1  0 10:54 pts/1    00:00:00 /bin/sleep 100
> > > root         6     1  0 10:54 pts/1    00:00:00 ps -ef
> > > 
> > > but from another shell as the same user, partial output of ps -ef
> > > gives me:
> > > 
> > > root      2877  2876  0 10:54 pts/1    00:00:00 /bin/sh
> > > root      2881  2877  0 10:54 pts/1    00:00:00 /bin/sleep 100
> > > 
> > > And so what we're trying to decide is whether autofs should send
> > > pid 5 or pid 2881 for a message about the "/bin/sleep 100" task.
> > > 
> > > In fact, if the user clicks that button twice, chances are both
> > > instances of the application will have the same pid values for each
> > > process in the application.  So now if autofs sends a message to the
> > > user about the application, the user cannot tell which process is at
> > > fault.
> > > 
> > > Autofs will be sending the user some message about 'process 5'.  The
> > > user won't know whether it means "the real" pid 5, [watchdog/0],
> > > pid 5 in the first instance of the application, or pid 5 in the
> > > second instance.
> > > 
> > > Now it's true that the user's xterm may still be in a different
> > > (descendent) pidns of the autofs daemon.  But we can't expect
> > > the autofs daemon to do pid_t translation for the user, so I
> > > think what we have to aim for is making sure that the values
> > > reported are unique within the pidns of the autofs daemon.  And
> > > that means sending back either the pid values in the autofs
> > > daemon's pid namespace, or using the top-level pid_ts, that is,
> > > the pid values in the init namespace, which will be unique
> > > on the whole system.
> > > 
> > > Sorry this turned out long-winded, I hope it makes sense.
> > > And if I'm just showing a misunderstanding of what you're doing,
> > > please do correct me :)
> > 
> > Yes, it's a bit tricky.
> > 
> > In reality this information is only logged when debug logging is enabled
> > and generally is only used by myself or others that maintain autofs. But
> > getting sensible logging is important so it's worth sorting this out.
> > 
> > I think it would be best to use the pid of the highest view namespace
> > which I think is the gist of what you said in the beginning. Then (at
> > some future time), if there was a user space API, the daemon could
> > report additional pid information related to subordinate pid namespaces.
> > I am assuming that, to be useful, an autofs daemon that is able to serve
> > multiple namespaces would be higher up in the tree. But the forgoing
> > description sounds like there's not a necessarily a hierarchic structure
> > to pid namespaces?
> 
> It is a simple tree, but of course if you have 3 autofs daemons in
> separate containers, and one on the main host, then the pid namespaces for
> each of the 3 container autofs daemons will be siblings, so they won't
> have meaningful translations for each others' pids, while pids in
> each container will have meaningful translations in the host system's
> pid namespace (the init_pid_ns).
> 
> > The other issue that comes up is, after storing (a reference to) the
> > daemon namespace in the super block info struct a "kill -9" on the
> > daemon would render the namespace invalid. At the moment, when this
> > happens the write on the kernel pipe fails causing the autofs mount to
> > become catatonic, but for the namespace aware case the namespace is now
> > invalid so we won't get that far. I could make the mount catatonic when
> 
> I figured you would grab a reference to the pid namespace, so it
> wouldn't go away until you released the superblock or registered a new
> daemon for it.
> 
> > I detect that the namespace has become invalid but I'm not sure how to
> > check it. Is there a way I can to do this? Would there be any issues
> > with namespace (pid) reuse for such a check?
> 
> I'm not sure what you mean - but struct pid is never reused so long
> as you have a reference to one.  So you could store
> get_pid(task_pid(autofs_daemon)) and check whether the autofs daemon's
> pid has changed that way, I suppose.  But grabbing a struct pid reference
> does not pin the pid_ns iirc.
> 
> Maybe you're right about just getting the top-level pid_nr.

After doing a quick test with your git tree, I find that I was wrong,
and task->pid is the global pid of the process, not the pid in its own
pid namespace.

So currently autofs sends a process id in the init_pid_ns.  This may
be meaningless in the autofs daemon's pid namespace, but since the
purpose is just for logging/debugging, having a global pid, which
uniquely identifies any task on the system, seems correct.

So in terms of pids no change is needed IMO.

thanks,
-serge
