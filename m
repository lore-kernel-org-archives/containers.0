From: Kuniyasu Suzaki <k.suzaki-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>
Subject: Re: BMC (Bare-Metal Container) is relased
Date: Tue, 20 Dec 2016 12:03:34 +0900
Message-ID: <20161220.120334.220534096.k.suzaki@aist.go.jp>
References: <877f6w5v50.fsf@xmission.com>
	<20161219.190450.77957768.k.suzaki@aist.go.jp>
	<1482162675.2348.11.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1482162675.2348.11.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bmc-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org


From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: BMC (Bare-Metal Container) is relased
Date: Mon, 19 Dec 2016 07:51:15 -0800

> On Mon, 2016-12-19 at 19:04 +0900, Kuniyasu Suzaki wrote:
>> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> Subject: Re: BMC (Bare-Metal Container) is relased
>> Date: Mon, 19 Dec 2016 18:46:03 +1300
>> 
>> For exmaple, DPDK requires "igb_uio" and "rte_kni" kernel modules,
>> but some kernels offered as a part of Linux Distribution do not
>> include them.
> 
> That makes it a Distribution problem not a kernel problem, really. 
>  Constainers is OS virtualization, so if the OS doesn't provide a
> feature, it can't be virtualized.
> 
> The problem for those distributions is that the features you want
> inside the container aren't available in bare metal instances either,
> which means if they're really a need, the distro eventually provides
> them or suffers in the market place.  This tends to force all distros
> to supporting all useful features meaning the kernel configuration
> problem is mostly a theoretical one.

Yes. DPDK on a container is just an example which does not run on a normal Linux distributions.
It is not kernel problem, but it is caused by the mismatch between application and kernel.

THP (Transparent Huge Pages) and HTT (Hyper Threading Technology) are better examples for Bare-Metal Container.
They work system-wide and affects all applications, but some applications want to turn off.
It is system centric architecture we call, and all applications must follow the decision.

On the other hand, BMC tries to offer a suitable kernel for an application on a remote machine.
We call this application centric architecture.

I guess same problem may cause on other container technologies.
  VMware's "vSphere Integrated Containers"   https://www.vmware.com/products/vsphere/integrated-containers.html   
  Joyent's "Triton"                          https://www.joyent.com/triton                          

>> So, the container on these kernels can not run DPDK. Forthermore the
>> normal setting of Transparet Huge Pages caused problems on some DB
>> applications.
> 
> The THP problem might be more interesting, but your paper mentions it
> in passing as hearsay (cloudera said this about RHEL 6.2) ... is there
> any more recent data about it (RHEL 6.2 is 2.6.32 based, which is now a
> seven year old kernel)?

You can confirm the problem using "parallel".
   https://github.com/rust-lang/rust/issues/36705

I have made a Docker image. Please try on your machine.
--------------------------------------------------------------------
On the Host Linux
$ sudo echo never > /sys/kernel/mm/transparent_hugepage/enabled
or 
$ sudo echo always > /sys/kernel/mm/transparent_hugepage/enabled

Run parallel on Docker.
$ docker run -it suzaki/rust-parallel bash
# export PATH=$PATH:/root/.cargo/bin
# time seq 1 10000 | parallel echo > /dev/null
--------------------------------------------------------------------
Thank you.

-----------
Kuni Suzaki

> James
> 
>> BMC try to apply suitable Linux kernel for a container image.
>> These cases are reported on my paper published at IEEE Conference on
>> High Performance Computing and Communications (HPCC) 2016.
>> The paper and slide are downloadable.
>>    Paper PDF: 
>> https://staff.aist.go.jp/k.suzaki/HPCC16-BareMetalContainer.pdf
>>    Slide PDF: http://www.slideshare.net/suzaki/baremetal-container-pr
>> esented-at-hpcc2016
>> 
>> Thank you.
>> 
>> ------
>> Kuni Suzaki
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linuxfoundation.org/mailman/listinfo/containers
>> 
> 
