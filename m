From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: Namespaces exhausted CLONE_XXX bits problem
Date: Tue, 15 Jan 2008 12:57:48 +0300
Message-ID: <478C839C.6010507@openvz.org>
References: <478B6764.6050300@openvz.org> <478B7549.2020000@fr.ibm.com>	
	<478B76C4.8050804@openvz.org> <478B7DB3.9050702@fr.ibm.com>	
	<20080114163246.GA31663@sergelap.austin.ibm.com>	
	<478B9345.30004@openvz.org>
	<20080114180748.GA2772@sergelap.austin.ibm.com>	
	<478BD5CD.7030607@cs.columbia.edu>
	<1200347674.22674.28.camel@localhost>
	<478C6E14.1050901@openvz.org> <478C7156.2090004@fr.ibm.com>
	<478C7493.8070405@openvz.org> <478C7F95.6050800@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <478C7F95.6050800-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
> Pavel Emelyanov wrote:
>> Cedric Le Goater wrote:
>>> Pavel Emelyanov wrote:
>>>> Dave Hansen wrote:
>>>>> On Mon, 2008-01-14 at 16:36 -0500, Oren Laadan wrote:
>>>>>> I second the concern of running out of 64 bits of flags. In fact, the
>>>>>> problem with the flags is likely to be valid outside our context, and
>>>>>> general to the linux kernel soon. Should we not discuss it there
>>>>>> too ? 
>>>>> It would be pretty easy to make a new one expandable:
>>>>>
>>>>> 	sys_newclone(int len, unsigned long *flags_array)
>>>>>
>>>>> Then you could give it a virtually unlimited number of "unsigned long"s
>>>>> pointed to by "flags_array".
>>>>>
>>>>> Plus, the old clone just becomes:
>>>>>
>>>>>         sys_oldclone(unsigned long flags)
>>>>>         {
>>>>>         	do_newclone(1, &flags);
>>>>>         }
>>>>>
>>>>> We could validate the flags array address in sys_newclone(), then call
>>>>> do_newclone().
>>>> Hmm. I have an idea how to make this w/o a new system call. This might
>>>> look wierd, but. Why not stopple the last bit with a CLONE_NEWCLONE and
>>>> consider the parent_tidptr/child_tidptr in this case as the pointer to 
>>>> an array of extra arguments/flargs?
>>> It's a bit hacky but it looks like a good idea to me !
>>>
>>> Shall we use parent_tidptr or child_tidptr to pass a extended array of 
>>> flags only ? if we could pass the pid of the task to be cloned, it would 
>>> be useful for c/r.
>> Yup. I think we can declare a
>>
>> struct new_clone_arg {
>> 	unsigned int size;
>> };
>>
>> and consider the xx_tidptr to be a pointer on it. After this we
>> may sen patches that add fields to this structure.
>>
>> E.g. first
>>
>>  struct new_clone_arg {
>>  	unsigned int size;
>> +	unsigned long new_flags;
>>  };
>>
>> to add flags for cloning new namespaces. Later
>>
>>  struct new_clone_arg {
>>  	unsigned int size;
>>  	unsigned long new_flags;
>> +	int desired_pid;
>>  };
>>
>> and each code that needs to access the extra argument would need
>> to check for new_clone_arg->size to be not less than the offset
>> of the field he need an access to. E.g. like this:
>>
>> #define clone_arg_has(arg, member)	({			\
>> 	struct new_clone_arg *__carg = arg;			\
>> 	(__carg->size >= offsetof(struct new_clone_arg, member) + \
>> 		sizeof(__carg->member)) })
>>
>> ...
>>
>> if (!clone_arg_has(arg, desired_pid))
>> 	return -EINVAL;
>>
>> This would keep the API always compatible.
> 
> Pavel, this is pretty neat. 

Thanks, but what to do with unshare()? Stop unsharing namespaces
is not an option, so we'll have to add a new sys_unshare2 system
call with similar technique for argument passing.

> I think we need to work on a patch now and send it to andrew and lkml@
> to have a larger audience.

OK, I'll try to prepare the one for clone() today. Hope it will
be ready to be sent tomorrow.

> I doesn't seem to be a really big patch and I wondering how I could help. 

I'll send it for pre-review before showing to people ;)

> We still have to prepare something for security_task_create()
> 
> Thanks !
> 
> C.

Thanks,
Pavel
