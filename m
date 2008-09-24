From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: An introduction to libvirt's LXC (LinuX Container) support
Date: Wed, 24 Sep 2008 18:27:31 +0100
Message-ID: <20080924172731.GF30137@redhat.com>
References: <20080917150635.GK27699@redhat.com>
	<20080924165307.GA22376@us.ibm.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080924165307.GA22376-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Sep 24, 2008 at 11:53:07AM -0500, Serge E. Hallyn wrote:
> Quoting Daniel P. Berrange (berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> > This is a short^H^H^H^H^H long mail to introduce / walk-through some
> >  - Create a simple chroot environment using busybox
> > 
> >     mkdir /root/mycontainer
> >     mkdir /root/mycontainer/bin
> >     mkdir /root/mycontainer/sbin
> >     cp /sbin/busybox /root/mycontainer/sbin
> >     for cmd in sh ls chdir chmod rm cat vi
> >     do
> >       ln -s /root/mycontainer/bin/$cmd ../sbin/busybox
> 
> ITYM ln -s ../sbin/busybox /root/mycontainer/bin/$cmd  ? :)

Yes, clearly :-)

> >  - Create a simple libvirt configuration file for the
> >    container, defining the root filesystem, the network
> >    connection (bridged to br0 in this case), and the
> >    path to the 'init' binary (defaults to /sbin/init if
> >    omitted)
> > 
> >     # cat > mycontainer.xml <<EOF
> >     <domain type='lxc'>
> >       <name>mycontainer</name>
> >       <memory>500000</memory>
> >       <os>
> >         <type>exe</type>
> >         <init>/sbin/init</init>
> >       </os>
> >       <devices>
> >         <filesystem type='mount'>
> >           <source dir='/root/mycontainer'/>
> >           <target dir='/'/>
> >         </filesystem>
> >         <interface type='bridge'>
> >           <source network='br0'/>
> >           <mac address='00:11:22:34:34:34'/>
> >         </interface>
> >         <console type='pty' />
> >       </devices>
> >     </domain>
> >     EOF
> 
> You might want to consider an option to set up mounts
> propagation automatically.  That way the host admin could look under
> /root/mycontainer/proc, /root/mycontainer/sys, etc, and get meaningful
> information.
> 
> >  - Load the configuration into libvirt
> > 
> >     # virsh --connect lxc:/// define mycontainer.xml
> 
> Alas, I'm getting:
> 
>   libvir: Domain Config error : internal error No <source> 'dev' attribute
>   specified with <interface type='bridge'/>
>   error: Failed to define domain from mycontainer.xml
> 
> (libvir is not my typo :)

Several typos :-)

The error message is complaining about the lack of the 'dev' attribute
when it should have been complaining about the the 'bridge' attribute,
and the example I gave is wrong too. In my example XML, change
the interface block to:

         <interface type='bridge'>
           <source bridge='br0'/>
           <mac address='00:11:22:34:34:34'/>
         </interface>


Daniel
-- 
|: Red Hat, Engineering, London   -o-   http://people.redhat.com/berrange/ :|
|: http://libvirt.org  -o-  http://virt-manager.org  -o-  http://ovirt.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: GnuPG: 7D3B9505  -o-  F3C9 553F A1DA 4AC2 5648 23C1 B3DF F742 7D3B 9505 :|
