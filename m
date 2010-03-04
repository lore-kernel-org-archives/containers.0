From: "Kumar L Srikanth-B22348" <B22348-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Bringing up LXC container from virsh command prompt.
Date: Thu, 4 Mar 2010 11:52:32 +0530
Message-ID: <402621A7D69DDA458D0E12F070D1E55F715740@zin33exm29.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Reddy B Veera-B22347 <veera.reddy-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,
I am new to libvirt virsh console.
Currently I am working on Linux Containers(LXC). After lot of
exploration, I am able to create a Linux Container(fedora12) with the
help of 
lxc-tools(lxc-create, lxc-start, ...etc). I am able to start that
container and use it's console. I am able to assign an IP address to the
container, 
by creating a bridge in the host machine and assigning it to the
container.
Here, my goal is to bring up this container(fedora12) through libvirt
virsh command prompt. For that I created a domain with the following XML
file:
 
[vm1_fedora_container.xml]
<domain type='lxc' id='1'>
  <name>vm1_fedora</name>
    <memory>500000</memory>
      <os>
          <type>exe</type>
          <init>/bin/bash</init>
      </os>
      <vcpu>1</vcpu>
      <clock offset='utc'/>
      <on_poweroff>destroy</on_poweroff>
      <on_reboot>restart</on_reboot>
      <on_crash>destroy</on_crash>
      <devices>
        <emulator>/usr/libexec/libvirt_lxc</emulator>      
        <filesystem type='mount'>
          <source dir='/root/lxc/fedora12'/>    /*This is the rootfs
directory for my linux container(fedora12)*/
          <target dir='/'/>  /* I mounted it to '/' directory in the
Domain. */
        </filesystem>
<console type='pty' />
      </devices>
</domain>
 
I executed the following virsh commands:
# virsh --connect lxc:/// define vm1_fedora_container.xml
Domain vm1_fedora defined from /root/lxc_devel/fedora.xml
 
# virsh --connect lxc:/// list --all
 Id Name                 State
----------------------------------
  - vm1_fedora           shut off
 
# virsh --connect lxc:/// start vm1_fedora
Domain vm1_fedora started
 
# virsh --connect lxc:/// list --all
 Id Name                 State
----------------------------------
7805 vm1_fedora           running
 
# virsh --connect lxc:/// console vm1_fedora
Connected to domain vm1_fedora
Escape character is ^]
[root@localhost /]#
 

I am able to view the console of my container(fedora12), but when I
execute 'ifconfig' in that console, I am getting the following error:
bash: ifconfig: command not found
 
When I execute the same 'ifconfig' command through lxc-tools (like
lxc_start -n fedora12 /bin/bash), I am able to get the assigned IP
address.
Can you please suggest me where did I go wrong?
 
Regards,
Srikanth.
