From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: BMC (Bare-Metal Container) is relased
Date: Tue, 20 Dec 2016 16:57:32 +1300
Message-ID: <87bmw7fe1f.fsf@xmission.com>
References: <877f6w5v50.fsf@xmission.com>
	<20161219.190450.77957768.k.suzaki@aist.go.jp>
	<1482162675.2348.11.camel@HansenPartnership.com>
	<20161220.120334.220534096.k.suzaki@aist.go.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161220.120334.220534096.k.suzaki-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org> (Kuniyasu
	Suzaki's message of "Tue, 20 Dec 2016 12:03:34 +0900")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kuniyasu Suzaki <k.suzaki-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org>
Cc: James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bmc-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org
List-Id: containers.vger.kernel.org

Kuniyasu Suzaki <k.suzaki-XSdjUN4cZ6fPDbFq/vQRIQ@public.gmane.org> writes:

> From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
> Subject: Re: BMC (Bare-Metal Container) is relased
> Date: Mon, 19 Dec 2016 07:51:15 -0800
>
>> On Mon, 2016-12-19 at 19:04 +0900, Kuniyasu Suzaki wrote:
>>> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>> Subject: Re: BMC (Bare-Metal Container) is relased
>>> Date: Mon, 19 Dec 2016 18:46:03 +1300
>>> 
>>> For exmaple, DPDK requires "igb_uio" and "rte_kni" kernel modules,
>>> but some kernels offered as a part of Linux Distribution do not
>>> include them.
>> 
>> That makes it a Distribution problem not a kernel problem, really. 
>>  Constainers is OS virtualization, so if the OS doesn't provide a
>> feature, it can't be virtualized.
>> 
>> The problem for those distributions is that the features you want
>> inside the container aren't available in bare metal instances either,
>> which means if they're really a need, the distro eventually provides
>> them or suffers in the market place.  This tends to force all distros
>> to supporting all useful features meaning the kernel configuration
>> problem is mostly a theoretical one.
>
> Yes. DPDK on a container is just an example which does not run on a
> normal Linux distributions.  It is not kernel problem, but it is
> caused by the mismatch between application and kernel.
>
> THP (Transparent Huge Pages) and HTT (Hyper Threading Technology) are
> better examples for Bare-Metal Container.  They work system-wide and
> affects all applications, but some applications want to turn off.  It
> is system centric architecture we call, and all applications must
> follow the decision.
>
> On the other hand, BMC tries to offer a suitable kernel for an
> application on a remote machine. We call this application centric
> architecture.

In the past I have always seen this sort of problem handled as a
property to the scheduler, and a declaration that a certain job needs
certain properties.

Eric
