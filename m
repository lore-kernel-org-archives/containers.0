From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Why does devices cgroup check for CAP_SYS_ADMIN explicitly?
Date: Tue, 6 Nov 2012 11:31:04 -0600
Message-ID: <20121106173104.GA27990__41719.3154608414$1352223096$gmane$org@sergelap>
References: <20121106023845.GI19354@mtj.dyndns.org>
	<877gpzrlir.fsf@xmission.com> <20121106150131.GA14640@sergelap>
	<20121106150639.GB30069@mtj.dyndns.org>
	<871ug6rbio.fsf@xmission.com>
	<20121106154320.GE30069@mtj.dyndns.org>
	<87sj8mogpp.fsf@xmission.com>
	<20121106165246.GF30069@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121106165246.GF30069-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
> Hello, Eric.
> 
> On Tue, Nov 06, 2012 at 08:10:10AM -0800, Eric W. Biederman wrote:
> > mknod is gated by the vfs with a capability call.
> > 
> > open does not perform the CAP_MKNOD check.
> > 
> > Since the device cgroup prevents opening of device nodes adding
> > permission to access a new device node (update_access) is roughly
> > equivalent to mknod when the device cgroup does not exist.
> 
> I think that's a jump.
> 
> > To preserve the notion that only a privileged user can grant access to
> > device nodes we need a capability check.  Especially since the device
> > cgroup is designed to limit processes with uid == 0.
> > 
> > Without a capability check a process with CAP_DAC_OVERRIDE can go
> > shopping for a device control group that happens to have the device it
> > wants to use.
> > 
> > Similary without a capability check a process with CAP_DAD_OVERRIDE can
> > add or remove any device node into a device control group.
> > 
> > I don't see how the device control group can limit uid == 0 with the
> > device control group without making the operations require a capability
> > you don't give to ever user who has uid == 0.
> 
> devices cgroup adds to restrictions what a group of tasks can do.
> Access to cgroup configuration is gated by cgroup core (currently by
> VFS permissions) and that's it.  I really don't want each controller
> to develop its own permission checks.  If a controller can't live with
> that, it probably shouldn't be a cgroup controller.  So, if you think
> the CAP check is needed for cgroup in general (and can justify it),
> please feel free to move it to cgroup core; otherwise, the CAP check
> is going away from devices and if devices can't live with that, it
> probably shouldn't have been a cgroup controller from the beginning.

We can't generally require a capability to move tasks between cgroups,
as that will break currently intended uses.  I can create two cgroups,
chown them to serge, and let serge move between them.

-serge
