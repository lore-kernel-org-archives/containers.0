From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Network Namespace-1000 networks with Overlap Addresses
Date: Tue, 14 Apr 2009 09:37:12 -0500
Message-ID: <20090414143712.GC6072@us.ibm.com>
References: <B2EBF6E450E65C4F8CFEE8947E1905600298E2FF@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <B2EBF6E450E65C4F8CFEE8947E1905600298E2FF-ofAVchDyotZeePcQ0jRo1pjmvxFtTJ+o0e7PPNI6Mm0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Krishna Vamsi-B22174 <avamsi-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Krishna Vamsi-B22174 (avamsi-KZfg59tc24xl57MIdRCFDg@public.gmane.org):
> 
> 
> Hi,
> 
> I am a newbie  to this list.  Here is my use case , we have  Loadable
> Kernel Module which applies security to
> the packets arriving from 1000 networks with overlap addresses. There
> are 3 different  user space process which handles 
> control traffic  from these 1000 networks .   
> 
> Please let me know
> 
> 1)How to create a Network Namespace Object ?

clone(CLONE_NEWNET)

> 2)How to delete a Network Namespace Object ?

exit

> 3)Can these 3  user space process see all the Network Namespace objects
> created in the kernel ?

No, network namespaces are fully isolated.  A virtual nic can only exist
in one network namespace, and physical nics can only exist in the
initial network namespace.

>  If so, how can they access these objects?
> 4)How to group 2-3 interfaces under a particular Network Namespace ?

I don't understand the question, but you pass a veth endpoint into a
network namespace using

	/sbin/ip link set veth1 netns $pid_in_other_netns

> Is there any patch available to achieve the above use case ?

You can use liblxc (available from lxc.sf.net) or libvirt-lxc
(libvirt.org).

-serge
