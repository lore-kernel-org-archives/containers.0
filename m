From: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [DRAFT] Container mini-summit notes v0.01
Date: Thu, 06 Sep 2007 16:00:47 +0400
Message-ID: <46DFEBEF.3080603@sw.ru>
References: <46DE9E1C.6010309@fr.ibm.com> <46DEEBED.5010303@openvz.org>
	<46DFE2E3.20003@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46DFE2E3.20003-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
>>>  * possible direction for C/R user api
>>>    	    . checkpoint/restart syscalls
>>>            . C/R file systems 
>>>	      	  solves the set id issue 
>>>	      	  elegant but exposes too much the ABI
>>
>>I vote for the filesystem :) I'd add more details as we did on mini-summit.
>>
>>tasks
>> `- <pid1>
>>    `- <tid1>
>>       ...
>>       <tidN>
>>       files
>>        `- 1 -> /* made as a symlink */
>>           2 -> /* if socket point to net/ objects */
>>       memory
>>        `- <vma1> -> /* symlink to mm objects */
>>    <pid2>
>>    ...
>>    <pidN>
>>mm 
>>ipc
>>network
>>
>>and so on and so forth.
> 
> 
> We need to dig on this idea. RFC ?

1. resource interrelashionships are much more complicated then a tree.
   e.g. pid can be owned by a number of processes, threads, terminals, etc.
   So I'm not a fan of the idea.
2. exposing such a low-level information to the user-space can be undesirable:
   a) it allows to create non-GPL checkpointing
   b) significantly hits the performance of checkpoint/restore
   c) BTW, how do you plan to restore via filesystem? mkdir? create? :)

Thanks,
Kirill
