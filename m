From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [RFC PATCH 0/9] Add container support for cgroup
Date: Wed, 19 Dec 2012 15:39:31 -0600
Message-ID: <20121219213931.GA14408__2660.04555528543$1355953204$gmane$org@sergelap>
References: <1355726615-15224-1-git-send-email-gaofeng@cn.fujitsu.com>
	<50CED2FD.1040509@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50CED2FD.1040509-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> On 12/17/2012 10:43 AM, Gao feng wrote:
> > Right now,if we mount cgroup in the container,we will get
> > host's cgroup informations and even we can change host's
> > cgroup in container.
> > 
> > So the resource controller of the container will lose
> > effectiveness.
> > 
> > This patchset try to add contianer support for cgroup.
> > the main idea is allocateing cgroup super-block for each
> > cgroup mounted in different pid namespace.
> > 
> > The top cgroup of container will share css with host.
> > When the cgroup being mounted in contianer,the tasks in
> > this container will be attached to this new mounted
> > hierarchy's top cgroup, And when unmounting cgroup in
> > container,these tasks will be attached back to host's cgroup.
> > 
> > Since the container can change the shared css through it's
> > cgroup subsystem files. patch 7/8 disable the write permission
> > of container's top cgroup files. In my TODO list, container
> > will have it's own css, this problem will disappear.
> > 
> > 
> > This patchset is sent as RFC,any comments are welcome.
> > Maybe this isn't the best solution, if you have better
> > solution,Please let me know.
> 
> 
> Question 1:
> 
> Any particular reason to have picked the pid namespace?
> 
> Maybe it is the right thing, since we are basically dealing with
> grouping of tasks.

Yes, but pid namespace is more about naming of tasks than grouping
of tasks (ignoring the reaper).  And the cgroup task files properly
translate pids.  I don't think this is good justification.

> OTOH, what you are doing sounds very much like
> a private mount, indicating that the mount namespace should be used.
> This needs to be well justified.

Agreed - though I prefer to avoid an existing ns at all.

> Also, "container support" can really mean a lot of things. I am still
> trying, while reading your patches, to figure out what exactly do you
> want to achieve. What it seems so far is that you want an unprivileged
> process living inside a namespace to manipulate the cgroup hierarchy and
> have its own copy of the cgroup tree, laid as it pleases. You also want
> to be able to write PIDs as seen by the containing namespace, and to
> have it somehow translated. Am I right?
> 
> For future submissions, could you make this clearer?

IMO, what we want is for a task to be able to say "from now on,
make my current cgroups the cgroup roots for myself and any newly
spawned children".  After that, the directory mounted using 'mount
-t cgroup' and output of /proc/self/cgroup should reflect the new
cgroups.  Access to existing mounts should not be affected - leave
that to the user-namespace-enhanced DAC checks and to proper container
setup (i.e. unmounting old cgroup mounts), and trust good cgroup
hierarchies to do the rest.

The current RFC makes clone(CLONE_NEWPID) the way to say "make my
current cgroup the cgroup root."  I think it would be simpler and
cleaner to use a new mount option, i.e. 'mount -t cgroup -o newroot'
to say 'make my current cgroup the cgroup root for myself and all
my new children."  The task->nsproxy could be enhanced with a pointer
to the new cgroupfs superblock (since I'm taking away the pidns as a
hint for finding the right cgroup root).

BTW I'm not sure what the current plan for allowed subsys compositions
is, but depending on that we may need to watch out for the container
being able DOS the host by making a bad composition.

-serge
