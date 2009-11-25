From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH RFC] powerpc: catch 32/64bit mix
Date: Wed, 25 Nov 2009 15:32:40 -0500
Message-ID: <4B0D9468.3050606@cs.columbia.edu>
References: <20091125162250.GA9034@us.ibm.com>
	<4B0D7F96.6050100@cs.columbia.edu>
	<20091125191617.GA11814@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091125191617.GA11814-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> I can't recall a convincing reason why restore_{thread,cpu}() should
>> run so late, or in particular after restore_task_objs().
>>
>> I think the original motivation was to avoid the point-of-no-return
>> at a very early stage. However this is only useful for self-restart.
>>
>> If we ever want self-restart to fail gracefully should something go
>> wrong, we should be prepared to undo any changes to the process -
>> on the error path. While not beyond reach, it isn't a top priority.
>>
>> Does calling restore_{thread,cpu}() earlier solve the problem ?
> 
> Yes, it does.
> 
>> BTW, this is also relevant for x86-64...
> 
> and also 31-bit s390

Excellent. Then I'll change the order for v19-rc2.

Thanks,

Oren.
