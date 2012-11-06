From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Why does devices cgroup check for CAP_SYS_ADMIN explicitly?
Date: Tue, 6 Nov 2012 09:01:32 -0600
Message-ID: <20121106150131.GA14640__18420.5629201189$1352214122$gmane$org@sergelap>
References: <20121106023845.GI19354@mtj.dyndns.org>
	<877gpzrlir.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <877gpzrlir.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
> 
> > Hello, guys.
> >
> > Why doesn't it follow the usual security enforced by cgroupfs
> > permissions?  Why is the explicit check necessary?
> 
> An almost more interesting question is why is cgroup one of the last
> pieces of code not using capabilities and instead lets you attach to any
> process simply if your uid == 0.
> 
> I don't know the history but the device cgroup testing for CAP_SYS_ADMIN
> makes a naive sort of sense to me.

Right, it's possible to run a daemon with uid 0 but restricted
capabilities (enforced by bounding set) for all its children, but
not possible to run a non-uid-0 daemon with some capabilities
across execs.  (Of course that can be worked around with privileged
helpers or to an extent inherited capabilities.)  Capabilities make
sense for the cgroup controls.

In other words, any code which equates uid 0 with posession of a
capability is taking away from the usefulness of capabilities
everywhere.

More practically, lacking user namespaces you can create a full (i.e.
ubuntu) container that doesn't have CAP_SYS_ADMIN, but not one without
root.  So this allows you to prevent containers from bypassing devices
cgroup restrictions set by the parent.  (In reality we are not using
that in ubuntu - we grant CAP_SYS_ADMIN and use apparmor to restrict -
but other distros do.)

-serge
