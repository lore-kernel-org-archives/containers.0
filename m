From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Network Namespace-1000 networks with Overlap Addresses
Date: Thu, 23 Apr 2009 10:58:30 +0200
Message-ID: <49F02DB6.8020309@free.fr>
References: <B2EBF6E450E65C4F8CFEE8947E1905600298E2FF@az33exm24.fsl.freescale.net>	<20090414143712.GC6072@us.ibm.com>	<m11vrlvtva.fsf@fess.ebiederm.org>	<200904230820.n3N8KgXW027602@az33smr01.freescale.net>
	<49F02947.3060602@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49F02947.3060602-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Krishna Vamsi-B22174 <avamsi-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> Babu N wrote:
>   
>> Hi,
>>
>> I am finding that a unshare call with CLONE_NEWNET is giving error in 
>> ubuntu 8.10 (kernet version 2.6.27).
>> The man page here 
>> (http://manpages.courier-mta.org/htmlman2/clone.2.html) states that 
>> CLONE_NEWNET implementation is not yet complete, but probably will be 
>> mostly complete by about Linux 2.6.28.
>> Is there way I can use CLONE_NEWNET successfully in 2.6.27 ?
>>   
>>     
> No, in 2.6.27 the netns code is not complete and buggy.
> You have to use the 2.6.29 kernel version.
>
>   -- Daniel
>   

By the way, you can ask Tim Gardner, Cc'ing the ubuntu kernel team if 
the net_ns is enabled in the 2.6.29 kernel version and, if not, if it is 
possible to enable it.

Thanks
  -- Daniel
