From: Jason Baron <jbaron@redhat.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Thu, 21 Jul 2011 10:20:54 -0400
Message-ID: <20110721142053.GA2454@redhat.com>
References: <20110720192029.GD2482@redhat.com>
	<20110720202831.GA11395@tango.0pointer.de>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110720202831.GA11395@tango.0pointer.de>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: mzerqung@0pointer.de
Cc: fedora-devel-list@redhat.com, cg-manager-developers@lists.fedorahosted.org, dwalsh@redhat.com, duffy@redhat.com, containers@lists.osdl.org
List-Id: containers.vger.kernel.org


Hi,

On Wed, Jul 20, 2011 at 10:28:32PM +0200, Lennart Poettering wrote:
> On Wed, 20.07.11 15:20, Jason Baron (jbaron@redhat.com) wrote:
> 
> Heya,
> 
> > The memory and cpu share controllers are currently supported (I simply haven't
> > gotten to supporting other controllers yet). One can add/delete cgroups, change
> > configuration parameters, and see which processes are currently associated
> > with each cgroup. There is also a 'usage' view, which displays graphically the
> > real-time usage statistics. The cgroup configuration can then be saved
> > into /etc/cgconfig.conf using the 'save' menubar button.
> 
> How does it write that file? Does the UI run as root? That's not really
> desirable. It's not secure and it is cumbersome to mix applications
> running as differnt users on the same session and one the same X
> screen (since they cannot communicate with dbus, and so on).

Right, as Dan Walsh, mentioned I need to separate this into two parts -
the front end UI and a backend communicating via DBUS. This is had been
a todo item.

> 
> > Right now, the gui assumes that the various hierarchies are mounted separately,
> > but that the cpu and cpuacct are co-mounted. Its my understanding that this
> > is consistent with how systemd is doing things. So that's great.
> 
> In F15 we mount all controllers enabled in the kernel separately. In F16
> we'll optionally mount some of them together, and we'll probably ship a
> default of mounting cpu and cpuacct together if they are both enabled.
> 
> > Currently, the gui saves its state using cgconfig.conf, and cgrules.conf. It
> > will display what libvirtd and systemd are doing, but will not save the state
> > for any of the cgroups that are created by libvirt or systemd. So, it
> > basically ignores these directories as far as persistent configuration. Thus,
> > it should not conflict with what systemd or libvirtd are doing.
> 
> Quite frankly, I think cgrulesd is a really bad idea, since it applies
> control group limits after a process is already running. This is
> necessarily racy (and adds quite a burden too, since you ask for
> notifications on each exec()). I'd claim that cgrulesd is broken by
> design and cannot be fixed.

I'm not going to claim that cgrulesd is perfect, but in the case where
you have untrusted users, you can start their login session in a
cgroup, and they can't break out of it. I agree it can be racy in the
case where you want to then further limit that user at run-time (fork
vs. re-assignment race). Another point, is that the current situation
can be no worse then the current unconstrained (no cgroup) case,
especially when you take into account the fact that system services or
'trusted services' are going to be properly assigned. Perhaps, the
authors of cgrulesd can further comment on this issue... 


> 
> > Thus, various privaleged consumers could make 'configuration requests' to a
> > common API, basically asking what's my configuration data. If there is already
> > data the consumer can proceed assigning tasks to those cgroups. Otherwise, it
> > can create a new request, which may or may not be allowed based upon the
> > available resources on the system. And each consumer can handle what it wants
> > to do in this case, which could potentially include tweaking the global
> > configuration.
> 
> systemd is the first process of the OS after the initrd finished. At
> that time no other process is running, and that means it is not
> practical to have systemd talk to any other daemon to get the most basic
> of its functionality working.
> 
> systemd is and will always have to maintain its own hierarchy
> independently of everybody else.

My suggestion here was that systemd starts its own hierarchy in some
default way, and then once configuration info is available it can move
processes around as required (in most cases there would probably be no
movement since we don't expect most users to override the defaults). 
Doesn't it have to do this now, if the user requests some sort of
customized cgroup configuration?

> 
> In fact I think running som arbitration daemon which clients talk to to
> get a group created is a bad idea anyway: this makes things needless
> complex and fragile. If the main reason to do such a thing is to get
> events when the cgroup configuration changes then I'd much rather see
> changes made to the kernel so that we can get notifications when groups
> are created or removed. That could be done via netlink. Another option
> would be to hook cgroupfs up with fanotify.
> 

The main point of the arbitration daemon is to help users configure
their system in a consistent way. For example, if systemd wants to
use cpuset to assign certain service to say cpu 1, and libvirtd also
wants to assign a virtual machine to cpu 1, it would be nice to allow
the user to know there might be a conflict and either adjust his
settings or continue anyway. I think it would also be nice to see the
overall system configuration and performance in a single place - hence
this tool. I'm interested in an integrated administration experience. If
I can only go to #n separate tools to configure things, to understand
how they interact, I think we're adding complexity on the administrator.

> 
> One of the nicer things of cgroups is that an "mkdir" is sufficient to
> create a group and an "echo $PID > $GROUP/tasks" to add a process to
> it. If you add complex systems on top of that which you need to talk to
> instead of trivial "mkdirs" and "open()+write()" you make cgroups much
> less attractive.
> 

The arbitration daemon tells you abut cgroup assignments, it doesn't
necessarily carry out the assignments. So I'm not suggesting that we
take away any of the above trivial operations.

thanks,

-Jason
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
