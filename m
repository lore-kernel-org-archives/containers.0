From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Remove READ_IMPLIES_EXEC during restart
Date: Tue, 14 Apr 2009 02:05:00 -0400
Message-ID: <49E4278C.3060500@cs.columbia.edu>
References: <1239039694-22332-1-git-send-email-danms@us.ibm.com>	<20090406181748.GA24751@us.ibm.com>
	<49E42646.4040703@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49E42646.4040703-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Oren Laadan wrote:
> 
> Serge E. Hallyn wrote:
>> Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>>> On s390, all tasks have READ_IMPLIES_EXEC set in current->personality,
>>> which causes the restart process to map things like the stack and heap as
>>> executable.  During the restart process, remove this bit and restore the
>>> original personality afterwards.
>>>
>>> This seems a little ugly, but I don't know that there's a better place for
>>> it.
>> Well imo the only other thing to do would be to do the same thing but
>> just around the main restart_memory function.
>>
> 
> I second that. Added.
> 

In fact, if elsewhere we restore current->personality of the task,
then unless we move it to cr_read_mm(), it will overwrite it :(

Oren.
