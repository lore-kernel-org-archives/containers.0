From: Jason Baron <jbaron@redhat.com>
Subject: new cg-manager gui tool for managin cgroups
Date: Wed, 20 Jul 2011 15:20:30 -0400
Message-ID: <20110720192029.GD2482@redhat.com>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
Content-Disposition: inline
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: fedora-devel-list@redhat.com, containers@lists.osdl.org, cg-manager-developers@lists.fedorahosted.org
Cc: duffy@redhat.com
List-Id: containers.vger.kernel.org

Hi,

I've been working on a new gui tool for managing and monitoring cgroups, called
'cg-manager'. I'm hoping to get people interested in contributing to this
project, as well as to add to the conversation about how cgroups should
be configured and incorporated into distros.

 * Intro

I've created a Fedora hosted page for the project, including a screen shot at:

https://fedorahosted.org/cg-manager/

To build and run, it's:

$ git clone git://git.fedorahosted.org/cg-manager.git
$ make
$ sudo ./cg-gui

I've also setup a mailing list to discuss the gui at:

https://fedorahosted.org/mailman/listinfo/cg-manager-developers

Currently, I assume the root user, but I hope to relax that assumption in
future versions. The program is still quite rough, but its been fairly stable
for me. Its a GTK 2.0 based application, written in C (to interface with
libcgroup as much as possible).

 * Brief summary of current functionality:

There are two top-level panes (which can be switched b/w using toggle buttons).
The first one centers around cgroup controllers, and the second one is about
configuring cgroup rules.

The memory and cpu share controllers are currently supported (I simply haven't
gotten to supporting other controllers yet). One can add/delete cgroups, change
configuration parameters, and see which processes are currently associated
with each cgroup. There is also a 'usage' view, which displays graphically the
real-time usage statistics. The cgroup configuration can then be saved
into /etc/cgconfig.conf using the 'save' menubar button.

The rules view allows for the creation of rules, such as this process for this
user goes into this cgroup. One can view rules by user and by process name. One
can also save the rules configuration into /etc/cgrules.conf.

I've also introduced the concept of a 'logical' cgroup, which is incorporated
into the cgroup pane and the rules pane. Basically, it allows you to group at
most one cgroup from each hierarchy into a logical group. And then you can
create rules that assign processes to that logical group.

 * Future direction:

I've been working Mairin Duffy on what the UI look and feel should eventually
look like...Right now, I have a lot of the elements from Mairin's mockups in
my UI, but its certainly not quite as polished. Mock-ups can be found at:

http://mairin.wordpress.com/2011/05/13/ideas-for-a-cgroups-ui/

 * Integration with Fedora/systemd:

Right now, the gui assumes that the various hierarchies are mounted separately,
but that the cpu and cpuacct are co-mounted. Its my understanding that this
is consistent with how systemd is doing things. So that's great.

Currently, the gui saves its state using cgconfig.conf, and cgrules.conf. It
will display what libvirtd and systemd are doing, but will not save the state
for any of the cgroups that are created by libvirt or systemd. So, it
basically ignores these directories as far as persistent configuration. Thus,
it should not conflict with what systemd or libvirtd are doing.

However, I think we need to discuss how we envision cgroup configuration
working longer term. The current consumers out of the box, that I'm aware of
are libvirt and systemd. Currently, these consumers manage cgroups as they see
fit. However, since they are managing shared resources, I think there probably
is an argument to be made that its useful, to have some sort of global view
of things, to understand how resources are being allocated, and thus a global
way of configuring cgroups (as opposed to each new consumer doing its own
thing).

Thus, various privaleged consumers could make 'configuration requests' to a
common API, basically asking what's my configuration data. If there is already
data the consumer can proceed assigning tasks to those cgroups. Otherwise, it
can create a new request, which may or may not be allowed based upon the
available resources on the system. And each consumer can handle what it wants
to do in this case, which could potentially include tweaking the global
configuration.

So for example, in the case of systemd, it continues to have the default
configuration that it currently has, but if the user has gone in and tweaked
the global configuration, that configuration may be re-assigned once we're far
enough along in the boot process to read what that configuration is.

Thanks,

-Jason

-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
