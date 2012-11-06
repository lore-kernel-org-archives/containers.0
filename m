From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Why does devices cgroup check for CAP_SYS_ADMIN explicitly?
Date: Tue, 6 Nov 2012 09:30:32 -0600
Message-ID: <20121106153032.GB18218__20874.0238952034$1352215868$gmane$org@sergelap>
References: <20121106023845.GI19354@mtj.dyndns.org>
	<877gpzrlir.fsf@xmission.com> <20121106150131.GA14640@sergelap>
	<20121106150639.GB30069@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121106150639.GB30069-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> Hello, Serge.
> 
> On Tue, Nov 06, 2012 at 09:01:32AM -0600, Serge Hallyn wrote:
> > More practically, lacking user namespaces you can create a full (i.e.
> > ubuntu) container that doesn't have CAP_SYS_ADMIN, but not one without
> > root.  So this allows you to prevent containers from bypassing devices
> > cgroup restrictions set by the parent.  (In reality we are not using
> > that in ubuntu - we grant CAP_SYS_ADMIN and use apparmor to restrict -
> > but other distros do.)
> 
> Do you even mount cgroupfs in containers?  If you just bind-mount
> cgroupfs verbatim in containers, I don't think that's gonna work very
> well.  If not, all this doesn't make any difference for containers.

I don't know if those who restrict CAP_SYS_ADMIN do so or not.  We by
default do not.

(It's not relevant for this discussion as again we use apparmor to deny
writes, but we *do* optionally bind mount cgroups into the containers,
mounting /sys/fs/cgroup/$cgroup/lxc/$containername/$containername.real
on the host to /sys/fs/cgroup/$cgroup in the container for each cgroup.)

> So, you don't really have any actual use case for the explicit CAP_*
> checks, right?

No, especially since we will now have user namespaces.

We will want to be able to strictly enforce hierarchical limits - i.e.
allow uid 100000 (which is uid 0 in the container) to change cgroup
settings, but never exceed limits set on the parent directory.  IIUC
you are working toward anyway with the general hierarchy work? (thanks
for that).

-serge
