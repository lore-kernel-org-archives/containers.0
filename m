From: Lennart Poettering <mzerqung@0pointer.de>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Wed, 20 Jul 2011 22:28:32 +0200
Message-ID: <20110720202831.GA11395@tango.0pointer.de>
References: <20110720192029.GD2482@redhat.com>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
In-Reply-To: <20110720192029.GD2482@redhat.com>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: Jason Baron <jbaron@redhat.com>
Cc: fedora-devel-list@redhat.com, containers@lists.osdl.org, duffy@redhat.com, cg-manager-developers@lists.fedorahosted.org
List-Id: containers.vger.kernel.org

On Wed, 20.07.11 15:20, Jason Baron (jbaron@redhat.com) wrote:

Heya,

> The memory and cpu share controllers are currently supported (I simply haven't
> gotten to supporting other controllers yet). One can add/delete cgroups, change
> configuration parameters, and see which processes are currently associated
> with each cgroup. There is also a 'usage' view, which displays graphically the
> real-time usage statistics. The cgroup configuration can then be saved
> into /etc/cgconfig.conf using the 'save' menubar button.

How does it write that file? Does the UI run as root? That's not really
desirable. It's not secure and it is cumbersome to mix applications
running as differnt users on the same session and one the same X
screen (since they cannot communicate with dbus, and so on).

> Right now, the gui assumes that the various hierarchies are mounted separately,
> but that the cpu and cpuacct are co-mounted. Its my understanding that this
> is consistent with how systemd is doing things. So that's great.

In F15 we mount all controllers enabled in the kernel separately. In F16
we'll optionally mount some of them together, and we'll probably ship a
default of mounting cpu and cpuacct together if they are both enabled.

> Currently, the gui saves its state using cgconfig.conf, and cgrules.conf. It
> will display what libvirtd and systemd are doing, but will not save the state
> for any of the cgroups that are created by libvirt or systemd. So, it
> basically ignores these directories as far as persistent configuration. Thus,
> it should not conflict with what systemd or libvirtd are doing.

Quite frankly, I think cgrulesd is a really bad idea, since it applies
control group limits after a process is already running. This is
necessarily racy (and adds quite a burden too, since you ask for
notifications on each exec()). I'd claim that cgrulesd is broken by
design and cannot be fixed.

> Thus, various privaleged consumers could make 'configuration requests' to a
> common API, basically asking what's my configuration data. If there is already
> data the consumer can proceed assigning tasks to those cgroups. Otherwise, it
> can create a new request, which may or may not be allowed based upon the
> available resources on the system. And each consumer can handle what it wants
> to do in this case, which could potentially include tweaking the global
> configuration.

systemd is the first process of the OS after the initrd finished. At
that time no other process is running, and that means it is not
practical to have systemd talk to any other daemon to get the most basic
of its functionality working.

systemd is and will always have to maintain its own hierarchy
independently of everybody else.

In fact I think running som arbitration daemon which clients talk to to
get a group created is a bad idea anyway: this makes things needless
complex and fragile. If the main reason to do such a thing is to get
events when the cgroup configuration changes then I'd much rather see
changes made to the kernel so that we can get notifications when groups
are created or removed. That could be done via netlink. Another option
would be to hook cgroupfs up with fanotify.

One of the nicer things of cgroups is that an "mkdir" is sufficient to
create a group and an "echo $PID > $GROUP/tasks" to add a process to
it. If you add complex systems on top of that which you need to talk to
instead of trivial "mkdirs" and "open()+write()" you make cgroups much
less attractive.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
