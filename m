From: Babu N <babu.neelam-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: Network Namespace-1000 networks with Overlap Addresses
Date: Thu, 23 Apr 2009 15:18:47 +0530
Message-ID: <200904230943.n3N9h6Cs023035@az33smr01.freescale.net>
References: <B2EBF6E450E65C4F8CFEE8947E1905600298E2FF@az33exm24.fsl.freescale.net>
	<20090414143712.GC6072@us.ibm.com>
	<m11vrlvtva.fsf@fess.ebiederm.org>
	<200904230820.n3N8KgXW027602@az33smr01.freescale.net>
	<49F02947.3060602@fr.ibm.com> <49F02DB6.8020309@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49F02DB6.8020309-GANU6spQydw@public.gmane.org>
References: <B2EBF6E450E65C4F8CFEE8947E1905600298E2FF-ofAVchDyotZeePcQ0jRo1pjmvxFtTJ+o0e7PPNI6Mm0@public.gmane.org>
	<20090414143712.GC6072-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
	<m11vrlvtva.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
	<200904230820.n3N8KgXW027602-/sMIUUHvcVm7KQohPwX1u+lZC/4ptaCc@public.gmane.org>
	<49F02947.3060602-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> <49F02DB6.8020309-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Krishna Vamsi-B22174 <avamsi-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Daniel,

Thanks for the response.
Its not enabled by default in ubuntu 8.10. But I have recompiled as 
per the instructions in 
http://lxc.sourceforge.net/network/configuration.php and found NEWNET 
giving error in the re-compiled kernel.
Your reply clarifies this.

Thanks again.


- Babu


At 02:28 PM 4/23/2009, Daniel Lezcano wrote:
>Daniel Lezcano wrote:
>>Babu N wrote:
>>
>>>Hi,
>>>
>>>I am finding that a unshare call with CLONE_NEWNET is giving error 
>>>in ubuntu 8.10 (kernet version 2.6.27).
>>>The man page here 
>>>(http://manpages.courier-mta.org/htmlman2/clone.2.html) states 
>>>that CLONE_NEWNET implementation is not yet complete, but probably 
>>>will be mostly complete by about Linux 2.6.28.
>>>Is there way I can use CLONE_NEWNET successfully in 2.6.27 ?
>>>
>>>
>>No, in 2.6.27 the netns code is not complete and buggy.
>>You have to use the 2.6.29 kernel version.
>>
>>   -- Daniel
>>
>
>By the way, you can ask Tim Gardner, Cc'ing the ubuntu kernel team 
>if the net_ns is enabled in the 2.6.29 kernel version and, if not, 
>if it is possible to enable it.
>
>Thanks
>  -- Daniel
