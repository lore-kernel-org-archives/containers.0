From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 2/2] cgroups: make procs file writable
Date: Tue, 3 Aug 2010 21:46:29 -0700
Message-ID: <AANLkTikxYHOCbuh=6R43BjzZ5QCA2kfTpt7h_ZrEbNoU__37464.2399409369$1280897224$gmane$org@mail.gmail.com>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100730235902.GC22644@ghc17.ghc.andrew.cmu.edu>
	<20100804100811.199d73ba.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikMofFGHSwF2QrdcAsit+hU6ihndhK5cod8duwS@mail.gmail.com>
	<20100804043849.GC11950@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100804043849.GC11950-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 3, 2010 at 9:38 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
>
> rcu_read_lock();
> for_each_subsys(...) {
> =A0 =A0 =A0 =A0can_attach(...);
> }
> rcu_read_unlock();

Sorry, I was misreading this, and didn't notice that it was already
inside an "if (threadgroup) {}" test.

>
> Which forces all can_attaches to not sleep. So by dropping
> rcu_read_lock(), we allow the possibility of the exec race I described
> in my last email, and therefore we have to check each time we re-acquire
> rcu_read to iterate thread_group.

Agreed.

>
> Yeah, it is not pretty. I call it "double-double-toil-and-trouble-check
> locking". But it is safe.

As a cleanup, I'd be inclined to have a wrapper in cgroup.c, something like

cgroup_can_attach_threadgroup(struct cgroup_subsys *ss, struct cgroup
*cg, struct task_struct *leader, int (*cb)(struct task_struct *t,
struct cgroup *cg))

which handles the RCU section, checking threadgroup_leader(), and
looping through each thread. The the subsystem just has to define a
callback which will be called for each thread.

Paul
