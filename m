From: Guenter Roeck <groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Fri, 9 Jan 2009 09:43:35 -0800
Message-ID: <20090109174334.GA4526@redback.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	<20090107180752.GA19153@us.ibm.com>
	<20090107191536.GA15159@megiteam.pl>
	<20090107193234.GA22625@us.ibm.com>
	<87priwifnu.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87priwifnu.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

I have tried something similar, only with CLONE_FILES|CLONE_FS|CLONE_VM|CLONE_NEWNET,
and actually creating a virtual interface and controlling socket or thread in each new
network namespace. This scales to a couple of thousand interfaces, though interface creation
takes a long time if more than 1,000 interfaces or so are created.

Problems I have seen are
- name hash in kernel is bad. A test program with similar names (eg eth0 to eth1000)
  shows that only every 17th bucket or so is used at all.
- current sysfs implementation doesn't scale to thousands of interfaces.
  Sequential search through file names, especially using strcmp, doesn't work well
  if there are thousands of entries in a directory.
- Using sockets to control network namespaces starts to fail after a couple hundred 
  namespaces and attached interfaces are created. There is no error message, only 
  the socket<->interface/namespace relationship isn't always created. Some interfaces
  stay in the initial network namespace.
- the idea of attaching/associating network namespaces with sockets and/or threads
  doesn't really work well unless used strictly for virtualization. For other
  applications (eg per-customer network namespaces in switches) one can not really
  afford to "loose" a network namespace just because a controlling process dies.

I can send you the code if you like.

Guenter

On Fri, Jan 09, 2009 at 08:54:13AM -0800, Dan Smith wrote:
> SH> Does anyone else (Eric? Pavel?) have experience with hundreds or
> SH> thousands of network namespaces?
> 
> I just gave it a shot on linux-next-20090108 with the following test
> case:
> 
>   int flags = CLONE_NEWPID|CLONE_NEWNS|CLONE_NEWUTS|CLONE_NEWUSER \
>                   | CLONE_NEWIPC|SIGCHLD|CLONE_NEWNET;
> 
>   int clone_child(void *data)
>   {
>           printf("Child %i\n", (int)data);
>           sleep(30);
>           exit(0);
>   }
> 
>   int main(int argc, char **argv)
>   {
>           int i;
> 
>           for (i = 0; i < 100; i++) {
>                   char *stack;
>                   unsigned int stacksize = getpagesize() * 4;
> 
>                   stack = malloc(stacksize);
>                   if (stack == NULL) {
>                           printf("Failed to allocate %i\n", stacksize);
>                           return 1;
>                   }
> 
>                   printf("Clone %i\n", i);
>                   clone(clone_child, stack + stacksize, flags, (void*)i);
>           }
> 
>           sleep(40);
>   }
> 
> The loop runs to completion, but only 18 children ever print their
> message.  After the test completes, doing something else (like
> bringing up a man page) consistently results in this panic:
> 
>   BUG: unable to handle kernel paging request at 00c85788
>   IP: [<c0252af8>] rb_insert_color+0x28/0x100
>   Oops: 0000 [#1] SMP
>   last sysfs file: /sys/devices/pci0000:00/0000:00:01.1/host0/target0:0:1/0:0:1:0/block/sr0/size
>   Modules linked in: ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc nfs lockd nfs_acl auth_rpcgss sunrpc af_packet ipv6 binfmt_misc dm_mirror dm_region_hash dm_log dm_multipath scsi_dh dm_mod uinput virtio_balloon virtio_net evbug evdev pcspkr virtio_pci virtio_ring virtio i2c_piix4 i2c_core sr_mod cdrom sg thermal button processor ata_generic pata_acpi piix ide_core sd_mod crc_t10dif ext3 jbd mbcache
> 
>   Pid: 2865, comm: man Not tainted (2.6.28-next-20090108 #5)
>   EIP: 0060:[<c0252af8>] EFLAGS: 00010202 CPU: 0
>   EIP is at rb_insert_color+0x28/0x100
>   EAX: c8578088 EBX: c8578088 ECX: c8578090 EDX: 00c85780
>   ESI: c8578088 EDI: 00c85780 EBP: cd93be28 ESP: cd93be14
>    DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
>   Process man (pid: 2865, ti=cd93a000 task=cb75bd90 task.ti=cd93a000)
>   Stack:
>    cb56cc00 c8578087 c857807f c8578088 c857809f cd93be40 d0afe76d cb56cc00
>    c8ccb00c 0001fe43 cf785f00 cd93be74 d0b04f79 c8ccb00c 0000000c 00000000
>    cf7e0e28 c845d180 c8ccbff8 00000001 00000000 cb56cc00 cf7e0e28 cf7e0e28
>   Call Trace:
>    [<d0afe76d>] ? ext3_htree_store_dirent+0xbd/0x110 [ext3]
>    [<d0b04f79>] ? htree_dirblock_to_tree+0x109/0x180 [ext3]
>    [<d0b07a11>] ? ext3_htree_fill_tree+0x61/0x210 [ext3]
>    [<c01b77e3>] ? nameidata_to_filp+0x53/0x70
>    [<d0afe684>] ? ext3_readdir+0x6d4/0x700 [ext3]
>    [<d0afe532>] ? ext3_readdir+0x582/0x700 [ext3]
>    [<c01bc8b4>] ? cp_new_stat64+0xe4/0x100
>    [<c01c6690>] ? filldir+0x0/0xd0
>    [<c01bcd52>] ? sys_fstat64+0x22/0x30
>    [<c01c68c8>] ? vfs_readdir+0x88/0xa0
>    [<c01c6690>] ? filldir+0x0/0xd0
>    [<c01c69f8>] ? sys_getdents+0x68/0xb0
>    [<c0103762>] ? syscall_call+0x7/0xb
>   Code: 8d 76 00 55 89 e5 57 56 53 83 ec 08 89 45 f0 89 55 ec 90 8b 55 f0 8b 02 89 c3 83 e3 fc 74 3c 8b 13 f6 c2 01 75 35 89 d7 83 e7 fc <8b> 77 08 39 de 74 59 85 f6 74 35 8b 06 a8 01 75 2f 83 c8 01 89
>   EIP: [<c0252af8>] rb_insert_color+0x28/0x100 SS:ESP 0068:cd93be14
>   ---[ end trace 5af0fea6439f26a1 ]---
> 
> --
> Dan Smith
> IBM Linux Technology Center
> email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
