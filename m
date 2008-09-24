From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: An introduction to libvirt's LXC (LinuX Container) support
Date: Wed, 24 Sep 2008 11:53:07 -0500
Message-ID: <20080924165307.GA22376@us.ibm.com>
References: <20080917150635.GK27699@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080917150635.GK27699-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel P. Berrange (berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> This is a short^H^H^H^H^H long mail to introduce / walk-through some
> recent developments in libvirt to support native Linux hosted
> container virtualization using the kernel capabilities the people
> on this list have been adding in recent releases. We've been working
> on this for a few months now, but not really publicised it before
> now, and I figure the people working on container virt extensions
> for Linux might be interested in how it is being used.

Thanks for sending this.  Neat to see some healthy competition between
this and liblxc.  Personally I still just use ns_exec :) But libvirt
support for containers is important, and I like liblxc's being
lightweight, so I definately want to test both periodically.  Plus I
know that those starting to use liblxc immediately found new bugs in the
kernel code...  Ideally I'd like to be able to switch between libvirt
and liblxc with single config files though.

> For those who aren't familiar with libvirt, it provides a stable API
> for managing virtualization hosts and their guests. It started with
> a Xen driver, and over time has evolved to add support for QEMU, KVM,
> OpenVZ and most recently of all a driver we're calling "LXC" short
> for "LinuX Containers". The key is that no matter what hypervisor
> you are using, there is a consistent set of APIs, and standardized
> configuration format for userspace management applications in the
> host (and remote secure RPC to the host).
> 
> The LXC driver is the result of a combined effort from a number of
> people in the libvirt community, most notably Dave Leskovec contributed
> the original code, and Dan Smith now leads development along with my
> own contributions to its architecture to better integrate with libvirt.
> 
> We have a couple of goals in this work. Overall, libvirt wants to be
> the defacto standard, open source management API for all virtualization
> platforms and native Linux virtualization capabilities are a strong
> focus. The LXC driver is attempting to provide a general purpose
> management solution for two container virt use cases:
> 
>  - Application workload isolation
>  - Virtual private servers
> 
> In the first use case we want to provide the ability to run an
> application in primary host OS with partial restrictons on its
> resource / service access. It will still run with the same root
> directory as the host OS, but its filesystem namespace may have
> some additional private mount points present. It may have a
> private network namespace to restrict its connectivity, and it
> will ultimately have restrictions on its resource usage (eg
> memory, CPU time, CPU affinity, I/O bandwidth).
> 
> In the second use case, we want to provide completely virtualized
> operating system in the container (running the host kernel of
> course), akin to the capabilities of OpenVZ / Linux-VServer. The
> container will have a totally private root filesystem, private
> networking namespace, whatever other namespace isolation the
> kernel provides, and again resource restirctions. Some people
> like to think of this as 'a better chroot than chroot'.
> 
> In terms of technical implementation, at its core is direct usage 
> of the new clone() flags. By default all containers get created 
> with CLONE_NEWPID, CLONE_NEWNS, CLONE_NEWUTS, CLONE_NEWUSER, and
> CLONE_NEWIPC. If private network config was requested they also
> get CLONE_NEWNET.
> 
> For the workload isolation case, after creating the container we
> just add a number of filesystem mounts in the containers private
> FS namespace. In the VPS case, we'll do a pivot_root() onto the
> new root directory, and then add any extra filesystem mounts the
> container config requested.
> 
> The stdin/out/err of the process leader in the container is bound
> to the slave end of a Psuedo TTY, libvirt owning the master end
> so it can provide a virtual text console into the guest container.
> Once the basic container setup is complete, libvirt exec the so 
> called 'init' process. Things are thus setup such that when the 
> 'init' process exits, the container is terminated / cleaned up.
> 
> On the host side, the libvirt LXC driver creates what we call a
> 'controller' process for each container. This is done with a small
> binary /usr/libexec/libvirt_lxc. This is the process which owns the
> master end of the Pseduo-TTY, along with a second Pseduo-TTY pair.
> When the host admin wants to interact with the contain, they use
> the command 'virsh console CONTAINER-NAME'. The LXC controller
> process takes care of forwarding I/O between the two slave PTYs,
> one slave opened by virsh console, the other being the containers'
> stdin/out/err. If you kill the controller, then the container
> also dies. Basically you can think of the libvirt_lxc controller
> as serving the equivalent purpose to the 'qemu' command for full
> machine virtualization - it provides the interface between host
> and guest, in this case just the container setup, and access to
> text console - perhaps more in the future.
> 
> For networking, libvirt provides two core concepts
> 
>  - Shared physical device. A bridge containing one of your
>    physical network interfaces on the host, along with one or
>    more of the guest vnet interfaces. So the container appears
>    as if its directly on the LAN
> 
>  - Virtual network. A bridge containing only guest vnet
>    interfaces, and NO physical device from the host. IPtables
>    and forwarding provide routed (+ optionally NATed)
>    connectivity to the LAN for guests.
> 
> The latter use case is particularly useful for machines without
> a permanent wired ethernet - eg laptops, using wifi, as it lets
> guests talk to each other even when there's no active host network.
> Both of these network setups are fully supported in the LXC driver
> in precense of a suitably new host kernel.
> 
> That's a 100ft overview and the current functionality is working
> quite well from an architectural/technical point of view, but there
> is plenty more work we still need todo to provide an system which
> is mature enough for real world production deployment.
> 
>  - Integration with cgroups. Although I talked about resource
>    restrictions, we've not implemented any of this yet. In the
>    most immediate timeframe we want to use cgroups' device
>    ACL support to prevent the container having any ability to
>    access to device nodes other than the usual suspects of
>    /dev/{null,full,zero,console}, and possibly /dev/urandom.
>    The other important one is to provide a memory cap across
>    the entire container. CPU based resource control is lower
>    priority at the moment.
> 
>  - Efficient query of resource utilization. We need to be able
>    to get the cumulative CPU time of all the processes inside 
>    the container, without having to iterate over every PIDs'
>    /proc/$PID/stat file. I'm not sure how we'll do this yet..
>    We want to get this data this for all CPUs, and per-CPU.
> 
>  - devpts virtualization. libvirt currently just bind mount the
>    host's /dev/pts into the container. Clearly this isn't a
>    serious impl. We've been monitoring the devpts namespace
>    patches and these look like they will provide the capabilities
>    we need for the full virtual private server use case
> 
>  - network sysfs virtualization. libvirt can't currently use the
>    CLONE_NEWNET flag in most Linux distros, since current released
>    kernel has this capability conflicting with SYSFS in KConfig.
>    Again we're looking forward to seeing this addressed in next
>    kernel
> 
>  - UID/GID virtualization. While we spawn all containers as root,
>    applications inside the container may witch to unprivileged
>    UIDs. We don't (neccessarily) want users in the host with
>    equivalent UIDs to be able to kill processes inside the
>    container. It would also be desirable to allow unprivileged
>    users to create containers without needing root on the host,
>    but allowing them to be root & any other user inside their
>    container. I'm not aware if anyone's working on this kind of
>    thing yet ?

All of that is the goal of the user namespaces.  If you go through the
containers mailing list archives you can see where Eric Biederman and I
have been bouncing design ideas back and forth.  It'll be slow going
though.  I need to rebase a simple starting patchset on the
security-testing next branch before I can go any further.  Then I'll be
addressing making POSIX capabilities respect user namespaces as per
conversations with Eric.  That should address signaling.  Then perhaps a
next attempt at letting filesystems handle user namespaces correctly.

For now, though, note that you can stop tasks in different user
namespaces from signaling each other by putting them in different
pid namespaces and completely separating their filesystems.  You can
use capability bounding sets to stop root in a container from doing
certain things like mknod (in the absence of the devices cgroup).

> There're probably more things Dan Smith is thinking of but that
> list is a good starting point.
> 
> Finally, a 30 second overview of actually using LXC usage with
> libvirt to create a simple VPS using busybox in its root fs...
> 
>  - Create a simple chroot environment using busybox
> 
>     mkdir /root/mycontainer
>     mkdir /root/mycontainer/bin
>     mkdir /root/mycontainer/sbin
>     cp /sbin/busybox /root/mycontainer/sbin
>     for cmd in sh ls chdir chmod rm cat vi
>     do
>       ln -s /root/mycontainer/bin/$cmd ../sbin/busybox

ITYM ln -s ../sbin/busybox /root/mycontainer/bin/$cmd  ? :)

>     done
>     cat > /root/mycontainer/sbin/init <<EOF
>     #!/sbin/busybox
>     sh
>     EOF
> 
> 
>  - Create a simple libvirt configuration file for the
>    container, defining the root filesystem, the network
>    connection (bridged to br0 in this case), and the
>    path to the 'init' binary (defaults to /sbin/init if
>    omitted)
> 
>     # cat > mycontainer.xml <<EOF
>     <domain type='lxc'>
>       <name>mycontainer</name>
>       <memory>500000</memory>
>       <os>
>         <type>exe</type>
>         <init>/sbin/init</init>
>       </os>
>       <devices>
>         <filesystem type='mount'>
>           <source dir='/root/mycontainer'/>
>           <target dir='/'/>
>         </filesystem>
>         <interface type='bridge'>
>           <source network='br0'/>
>           <mac address='00:11:22:34:34:34'/>
>         </interface>
>         <console type='pty' />
>       </devices>
>     </domain>
>     EOF

You might want to consider an option to set up mounts
propagation automatically.  That way the host admin could look under
/root/mycontainer/proc, /root/mycontainer/sys, etc, and get meaningful
information.

>  - Load the configuration into libvirt
> 
>     # virsh --connect lxc:/// define mycontainer.xml

Alas, I'm getting:

  libvir: Domain Config error : internal error No <source> 'dev' attribute
  specified with <interface type='bridge'/>
  error: Failed to define domain from mycontainer.xml

(libvir is not my typo :)

As for the xml, I assume I'm supposed to use some gui and therefore not
care?  But it would be nice to have a simple cmdline interface to
create the .xmls.  Actually, some tools to convert between the liblxc
format and the libvirt lxc format would be nice  :)  (I know, I know,
"go write them" :)

The basic container creation code looks good.

thanks,
-serge

>     # virsh --connect lxc:/// list --inactive
>      Id Name                 State
>     ----------------------------------
>      -  mycontainer          shutdown
> 
> 
> 
>  - Start the VM and query some information about it
> 
>     # virsh --connect lxc:/// start mycontainer
>     # virsh --connect lxc:/// list
>      Id   Name                 State
>     ----------------------------------
>     28407 mycontainer          running
> 
>     # virsh --connect lxc:/// dominfo mycontainer
>     Id:             28407
>     Name:           mycontainer
>     UUID:           8369f1ac-7e46-e869-4ca5-759d51478066
>     OS Type:        exe
>     State:          running
>     CPU(s):         1
>     Max memory:     500000 kB
>     Used memory:    500000 kB
> 
> 
>    NB. the CPU/memory info here is not enforce yet.
> 
>  - Interact with the container
> 
>     # virsh --connect lxc:/// console mycontainer
> 
>    NB, Ctrl+] to exit when done
> 
>  - Query the live config - eg to discover what PTY its
>    console is connected to
> 
> 
>     # virsh --connect lxc:/// dumpxml mycontainer
>     <domain type='lxc' id='28407'>
>       <name>mycontainer</name>
>       <uuid>8369f1ac-7e46-e869-4ca5-759d51478066</uuid>
>       <memory>500000</memory>
>       <currentMemory>500000</currentMemory>
>       <vcpu>1</vcpu>
>       <os>
>         <type arch='i686'>exe</type>
>         <init>/sbin/init</init>
>       </os>
>       <clock offset='utc'/>
>       <on_poweroff>destroy</on_poweroff>
>       <on_reboot>restart</on_reboot>
>       <on_crash>destroy</on_crash>
>       <devices>
>         <filesystem type='mount'>
>           <source dir='/root/mycontainer'/>
>           <target dir='/'/>
>         </filesystem>
>         <console type='pty' tty='/dev/pts/22'>
>           <source path='/dev/pts/22'/>
>           <target port='0'/>
>         </console>
>       </devices>
>     </domain>
> 
>  - Shutdown the container
> 
>     # virsh --connect lxc:/// destroy mycontainer
> 
> There is lots more I could say, but hopefully this serves as
> a useful introduction to the LXC work in libvirt and how it
> is making use of the kernel's container based virtualization
> support. For those interested in finding out more, all the
> source is in the libvirt CVS repo, the files being those
> named  src/lxc_conf.c, src/lxc_container.c, src/lxc_controller.c
> and src/lxc_driver.c. 
> 
>    http://libvirt.org/downloads.html
> 
> or via the GIT mirror of our CVS repo
> 
>    git clone git://git.et.redhat.com/libvirt.git
> 
> Regards,
> Daniel
> -- 
> |: Red Hat, Engineering, London   -o-   http://people.redhat.com/berrange/ :|
> |: http://libvirt.org  -o-  http://virt-manager.org  -o-  http://ovirt.org :|
> |: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
> |: GnuPG: 7D3B9505  -o-  F3C9 553F A1DA 4AC2 5648 23C1 B3DF F742 7D3B 9505 :|
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
