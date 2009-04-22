From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Network Namespace-1000 networks with Overlap Addresses
Date: Wed, 22 Apr 2009 03:57:13 -0700
Message-ID: <m11vrlvtva.fsf@fess.ebiederm.org>
References: <B2EBF6E450E65C4F8CFEE8947E1905600298E2FF@az33exm24.fsl.freescale.net>
	<20090414143712.GC6072@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090414143712.GC6072-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Tue\, 14 Apr 2009 09\:37\:12 -0500")
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
Cc: Krishna Vamsi-B22174 <avamsi-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Krishna Vamsi-B22174 (avamsi-KZfg59tc24xl57MIdRCFDg@public.gmane.org):
>> 
>> 
>> Hi,
>> 
>> I am a newbie  to this list.  Here is my use case , we have  Loadable
>> Kernel Module which applies security to
>> the packets arriving from 1000 networks with overlap addresses. There
>> are 3 different  user space process which handles 
>> control traffic  from these 1000 networks .   
>> 
>> Please let me know
>> 
>> 1)How to create a Network Namespace Object ?
>
> clone(CLONE_NEWNET)
>
>> 2)How to delete a Network Namespace Object ?
>
> exit
>
>> 3)Can these 3  user space process see all the Network Namespace objects
>> created in the kernel ?
>
> No, network namespaces are fully isolated.  A virtual nic can only exist
> in one network namespace, and physical nics can only exist in the
> initial network namespace.

Sockets can be passed between network namespaces if you set things up correctly.
At which point you can have 3 user space processes doing all of the work.

It can be a bit of a pain to have processes lying around just so you can
create a socket in another network namespace but the code works today
and isn't too bad.

>>  If so, how can they access these objects?
>> 4)How to group 2-3 interfaces under a particular Network Namespace ?
>
> I don't understand the question, but you pass a veth endpoint into a
> network namespace using
>
> 	/sbin/ip link set veth1 netns $pid_in_other_netns

yep.

Eric
