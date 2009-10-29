From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC PATCH 11/17] define function to print error messages to
	user log
Date: Thu, 29 Oct 2009 12:02:40 -0400
Message-ID: <4AE9BCA0.6090209@librato.com>
References: <1256683587-23961-1-git-send-email-serge@us.ibm.com>
	<1256683587-23961-12-git-send-email-serge@us.ibm.com>
	<20091028181415.GB14023@count0.beaverton.ibm.com>
	<20091028205424.GA27394@us.ibm.com> <4AE8BCB5.4030406@librato.com>
	<20091028221208.GA30227@us.ibm.com> <4AE8C639.6090105@librato.com>
	<20091029001223.GA1463@us.ibm.com> <4AE8E578.4030300@librato.com>
	<20091029042304.GA9005@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091029042304.GA9005-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>>
>> Serge E. Hallyn wrote:
>>> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>>>> Serge E. Hallyn wrote:
>>>>> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>>>>>> Serge E. Hallyn wrote:
>>>>>>> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>>>>>>>>> @@ -401,6 +409,9 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
>>>>>>>>>  		case 'E':
>>>>>>>>>  			len += sprintf(format+len, "[%s]", "err %d");
>>>>>>>>>  			break;
>>>>>>>>> +		case 'C': /* count of bytes read/written to checkpoint image */
>>>>>>>>> +			len += sprintf(format+len, "[%s]", "pos %d");
>>>>>>>>> +			break;
>>>>>>>> Instead we could always output ckpt->total and then we wouldn't need %(C). I
>>>>>>>> suspect it's such a useful piece of information that it'll be repeated
>>>>>>>> in many/all format strings eventually.
>>>>>>> Yes, likewise %(T).  If that's what we want to do.
>>>>>> I agree. For the cases when there is not task, can put "none"
>>>>>>
>>>>>>> Should we discuss here what we want an entry to look like?  For both
>>>>>>> ckpt_write_err (to the checkpoint image) and ckpt_error()?
>>>>>>>
>>>>>> Yes please !
>>>>> Actually %T isn't the current task, right, so it shouldn't always be prepended?
>>>>> It actually is only meaningful during checkpoint_task(), collect_objs(), and
>>>>> __tree_count_tasks?
>>>>>
>>>>> Ok, so how about:
>>>>>
>>>>> 	1. ckpt_write_err() always also calls ckpt_error() (which in turn calls
>>>>> 		ckpt_debug).  Avoid duplication which exists in several places
>>>>> 		right now.
>>>>> 	2. We always prepend:
>>>>>
>>>>> 		[current->pid]:[ctx->root_pid]:[ctx->active_pid]:[ctx->errno][ctx->total]
>>>>>
>>>>> 	The %(X) expansions if specified come whereever they are in the fmt
>>>>> 	string (which is what's happening now with my patchset).
>>>> So somewhere should set ctx->errno during a checkpoint.
>>>>
>>>> I suppose active_pid is for restart, but it's redundant isn't it ?
>>>> (it's always active_pid) - is it the different between top-level pid-ns
>>>> and "current" pid-ns ?
>>> No, I figured it would be meaningful for instance in places like
>>> wait_task_active().
>> Perhaps then leave it out of the default printing, and have the
>> specific debug messages there write it explicitly.
> 
> Ok, so then current suggested format looks like:
> 
> [current->pid]:[ctx->errno]:[ctx->total]
> 
> Though is ctx->errno helpful even in restart?  Or should we assume we'll
> figure that out through the msg in restore_notify_error()?
> 
> Maybe do:
> [current->pid]=[task_pid_vnr(current)]:[ctx->total]

I think errno is only helpful if an error occured.

So it should definitely be a part of the default msg given by
ckpt_error(), but not otherwise.

Oren.
