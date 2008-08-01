From: Vivek Kashyap <kashyapv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Where to find the user space bits to use container infrastructure
Date: Fri, 1 Aug 2008 00:14:47 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0808010012530.6044@IBM-8DE7FFDE2AB>
References: <20080730140604.GE16373@redhat.com> <489077EA.9050205@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <489077EA.9050205-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 30 Jul 2008, Benjamin Thery wrote:

> Vivek Goyal wrote:
>> Hi All,
>>
>> I thought of playing with containers but I can't find any instructions
>> or any user space bits which tell me how to setup and launch containers.

See libvirt's lxc driver  (libvirt.org).

vivek k
>>
>> Any pointers will help...
>
> If you want to play with network namespaces, you can have a look at the
> howto there:
> http://lxc.sourceforge.net/network/configuration.php
>
> Also, in the -lxc tarball, there're a bunch of programs to unshare
> namespaces (ns_exec):
>
> Tarballs: http://lxc.sourceforge.net/patches/2.6.26/2.6.26-rc8-mm1-lxc1/
>
> See:
> http://lxc.sourceforge.net/patches/2.6.26/2.6.26-rc8-mm1-lxc1/broken-out/utils/
>
> Benjamin
>
>>
>> Thanks
>> Vivek
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linux-foundation.org/mailman/listinfo/containers
>>
>>
>
>
> -- 
> B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D
>
>    http://www.bull.com
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
>

__

Vivek Kashyap
Linux Technology Center, IBM
