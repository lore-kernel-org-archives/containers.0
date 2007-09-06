From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [DRAFT] Container mini-summit notes v0.01
Date: Thu, 06 Sep 2007 13:22:11 +0200
Message-ID: <46DFE2E3.20003@fr.ibm.com>
References: <46DE9E1C.6010309@fr.ibm.com> <46DEEBED.5010303@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46DEEBED.5010303-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

>>   * possible direction for C/R user api
>>     	    . checkpoint/restart syscalls
>>             . C/R file systems 
>> 	      	  solves the set id issue 
>> 	      	  elegant but exposes too much the ABI
> 
> I vote for the filesystem :) I'd add more details as we did on mini-summit.
> 
> tasks
>  `- <pid1>
>     `- <tid1>
>        ...
>        <tidN>
>        files
>         `- 1 -> /* made as a symlink */
>            2 -> /* if socket point to net/ objects */
>        memory
>         `- <vma1> -> /* symlink to mm objects */
>     <pid2>
>     ...
>     <pidN>
> mm 
> ipc
> network
> 
> and so on and so forth.

We need to dig on this idea. RFC ?

C.
