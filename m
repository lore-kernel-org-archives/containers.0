From: Kuniyasu Suzaki <k.suzaki-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>
Subject: Re: BMC (Bare-Metal Container) is relased
Date: Wed, 14 Dec 2016 22:53:01 +0900
Message-ID: <20161214.225301.410988067.k.suzaki@aist.go.jp>
References: <TYXPR01MB08135B40DAAE84338AC9F7A7BDBB0@TYXPR01MB0813.jpnprd01.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <TYXPR01MB08135B40DAAE84338AC9F7A7BDBB0-enDngAEzY3pxg4pWkbNFRncolHNk5qUtvxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: bmc-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org
List-Id: containers.vger.kernel.org


I made a presentation of BMC at HPCC (IEEE Conference on High Performance Computing and Communications) 2016.
   http://www.swinflow.org/confs/2016/hpcc/
The title is "Bare-Metal Container --- Direct execution of a container image on a remote machine with an optimized kernel ---".
The slide is opened at slideshare.
   http://www.slideshare.net/suzaki/baremetal-container-presented-at-hpcc2016
   Original HP: http://www.itri.aist.go.jp/cpc/research/bmc/

BMC is resemble to VMware's "vSphere Integrated Containers" and Joyent's "Triton", but 
BMC is designed to customize Linux kernel for an application in a Docker image.
   VMware's "vSphere Integrated Containers"  http://www.vmware.com/products/vsphere/integrated-containers.html
   Jyoent's "Triton"  https://www.joyent.com/triton

BMC runs a Docker image with a customized kernel on a bare-metal remote machine using remote machine management technology (WakeupOnLan, Intel AMT, or IPMI) and network bootloader "iPXE".
BMC can solve the container's (Docker's) problem which is caused by Linux kernel.

If you are interesed in, please try.

-----------
Kuni Suzaki

From: 須崎有康 <k.suzaki-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>
Subject: BMC (Bare-Metal Container) is relased
Date: Fri, 11 Nov 2016 15:54:13 +0900

> Hello,
> 
> We released BMC (Bare-Metal Container) which runs a container (Docker)
> image with a suitable Linux kernel on a remote physical machine.
> BMC allows to change the kernel and its settings for the container
> (Docker) image. As a result, the application extracts the full
> performance of the physical machine.
> 
> A pre-built BMC image using DIND (Docker in Docker) technique is
> offered. Users can avid burdensome setting up (ex. Apache CGI, etc).
> We strongly recommend new users to try this pre-built version.
> 
> Pre-built BMC Doceker Image https://hub.docker.com/r/baremetalcontainer/bmc/
> Source Code: https://github.com/baremetalcontainer/bmc
> Official HP: http://www.itri.aist.go.jp/cpc/research/bmc/
> 
> BMC is exhibited at the Super Computing 2016 (AIST booth 1709) held at
> Salt Lake City next week (Nov/14-17).
>   http://sc16.supercomputing.org
> 
> The detail of BMC will be presented at IEEE HPCC (High Performance
> Computing and Communication) 2016 (Dec/12-14) held at Sydney.
>   http://www.swinflow.org/confs/2016/hpcc/
> 
> -----------
> Kuni Suzaki
