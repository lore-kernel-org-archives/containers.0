From: Kuniyasu Suzaki <k.suzaki-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>
Subject: Re: BMC (Bare-Metal Container) is relased
Date: Mon, 19 Dec 2016 19:04:50 +0900
Message-ID: <20161219.190450.77957768.k.suzaki@aist.go.jp>
References: <TYXPR01MB08135B40DAAE84338AC9F7A7BDBB0@TYXPR01MB0813.jpnprd01.prod.outlook.com>
	<20161214.225301.410988067.k.suzaki@aist.go.jp>
	<877f6w5v50.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877f6w5v50.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bmc-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org
List-Id: containers.vger.kernel.org


From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: Re: BMC (Bare-Metal Container) is relased
Date: Mon, 19 Dec 2016 18:46:03 +1300

> BMC is a very unfortunately name in your context as it typically refers
> to basboard management controller.

Yes, we know.
We hope Bare-Metal Container grews up more famous than Baseboard Management Controller.

> Kuniyasu Suzaki <k.suzaki-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org> writes:
>> BMC can solve the container's (Docker's) problem which is caused by
>> Linux kernel.
> 
> Which problem is that?

For exmaple, DPDK requires "igb_uio" and "rte_kni" kernel modules, but some kernels offered as a part of Linux Distribution do not include them.
So, the container on these kernels can not run DPDK. Forthermore the normal setting of Transparet Huge Pages caused problems on some DB applications.
BMC try to apply suitable Linux kernel for a container image.
These cases are reported on my paper published at IEEE Conference on High Performance Computing and Communications (HPCC) 2016.
The paper and slide are downloadable.
   Paper PDF: https://staff.aist.go.jp/k.suzaki/HPCC16-BareMetalContainer.pdf
   Slide PDF: http://www.slideshare.net/suzaki/baremetal-container-presented-at-hpcc2016

Thank you.

------
Kuni Suzaki
