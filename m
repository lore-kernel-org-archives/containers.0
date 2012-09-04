From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Virtualizing /proc/sys/kernel/random/boot_id per container ?
Date: Tue, 4 Sep 2012 09:42:04 -0500
Message-ID: <20120904144204.GA14093@amd1>
References: <20120830211832.GA3297@redhat.com> <878vcwjabu.fsf@xmission.com>
	<20120831132536.GA24262@amd1> <504461F1.1090400@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <504461F1.1090400-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> On 08/31/2012 05:25 PM, Serge Hallyn wrote:
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> >>
> >>> One of the features that SystemD folks have asked us to fix in LXC, is
> >>> to make sure that /proc/sys/kernel/random/boot_id changes each time a
> >>> container is started.
> >>
> >> There may be a good reason for this.  Most of the time what I have seen
> >> of kernel requests from the direction of SystemD is that while there may
> >> be a real problem but usually their imagined solution is not a
> >> particularly good solution.  So a description of the problem is needed.
> >>
> >> Justifying something with just SystemD wants this is a good way to get
> >> a nack.
> >>
> >>> The current semantics are that this file produces a new random UUID each
> >>> time the host OS is booted. Obviously each time we start a container now,
> >>> they just see the host's random boot_id, so from a container's POV this
> >>> does not change each time it starts.
> >>
> >> That is correct.  As I recall the contract with boot_id is to provide
> >> a unique per boot value to assist in dealing with boots etc.  I seem
> >> to recall emacs uses the combination of hostname+boot_id to help
> >> generate unique lock files names.
> >>
> >> I would definitely need a refresher on how boot_id is used in practice
> >> by applications other than SystemD before I could suggest a good design.
> >>
> >> There is also a question of uptime.
> >>
> >>> There seems to be general agreement that, aside from the PID directories,
> >>> changes to data in  proc should be done by a FUSE filesystem overlay of
> >>> some kind.
> >>
> >> No.  I have yet to see a justification for using FUSE in containers on
> >> top of proc files.
> >>
> >> I have seen a lot of bad ideas suggested like hacking /proc/cpuinfo
> >> instead of providing a proper mechanism to tell applications how
> >> parallel they can/should be.
> > 
> > Should we be talking about a new set of library functions to gather info
> > like available memory and cpus, etc?  The library functions could internally
> > take into account the per-host procfiles, cgroup info, and, as the need
> > arises, new sources of information.
> > 
> 
> I think this makes a lot of sense.

Cool.  I can't do it today, but it might be worth starting a list (on wiki?)
of information userspace wants (uptime, cpuinfo, meminfo, etc) so we can come
up with a reasonable api.

-serge
