From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][v4][PATCH 7/7]: Define clone_extended() syscall
Date: Thu, 06 Aug 2009 12:05:53 -0400
Message-ID: <4A7AFF61.8050802@librato.com>
References: <20090806061056.GA1044@us.ibm.com>
	<20090806062505.GG5619@us.ibm.com>
	<20090806133847.GA28392@us.ibm.com> <4A7AF8AD.4070805@librato.com>
	<20090806155520.GA904@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090806155520.GA904-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>>
>> Serge E. Hallyn wrote:
>>> Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>>>> Subject: [RFC][v4][PATCH 7/7]: Define clone_extended() syscall
>>>>
>>>> Container restart requires that a task have the same pid it had when it was
>>>> checkpointed. When containers are nested the tasks within the containers
>>>> exist in multiple pid namespaces and hence have multiple pids to specify
>>>> during restart.
>>>>
>>>> This patch defines, a new system call, clone_extended() which is like clone(),
>>>> but takes a new 'pid_set' parameter.  This parameter lets caller choose
>>>> specific pid numbers for the child process, in the process's active and
>>>> ancestor pid namespaces. (Descendant pid namespaces in general don't matter
>>>> since processes don't have pids in them anyway, but see comments in
>>>> copy_target_pids() regarding CLONE_NEWPID).
>>>>
>>>> Unlike clone(), however, clone_extended() needs CAP_SYS_ADMIN, at least for
>>>> now, to prevent unprivileged processes from misusing this interface.
>>> It only needs that when specifying pids.
>>>
>>>> While the main motivation for this interface is the need to let a process
>>>> choose its 'pid numbers', the clone_extended() interface uses 64-bit clone
>>>> flags.  The 'higher' portion of the clone flags are unused and are only
>>>> included to preclude yet another version of clone when a new clone flag is
>>>> needed. 
>>>>
>>>> ===== Interface:
>>>>
>>>> Compared to clone(), clone_extended() needs to pass in three more pieces
>>>> of information:
>>>>
>>>> 	- additional 32-bit of clone_flags
>>>> 	- number of pids in the set
>>>> 	- user buffer containing the list of pids.
>>>>
>>>> But since clone() already takes 5 parameters and some (all ?) architectures
>>>> are restricted to 6 parameters to a system-call, additional data-structures
>>>> (and copy_from_user()) are needed.
>>>>
>>>> The proposed interface for clone_extended() is:
>>>>
>>>> 	struct clone_tid_info {
>>>> 		void *parent_tid; 	/* parent_tid_ptr parameter */
>>>> 		void *child_tid; 	/* child_tid_ptr parameter */
>>>> 	};
>>>>
>>>> 	struct pid_set {
>>>> 		int num_pids;
>>>> 		pid_t *pids;
>>>> 	};
>>>>
>>>> 	int clone_extended(int flags_low, int flags_high, void *child_stack,
>>>> 			void *unused, struct clone_tid_info *tid_ptrs,
>>>> 			struct pid_set *pid_setp);
>>> I was thinking additional flags would be passed in the (renamed)
>>> struct pid_set.
>> Yes.
>>
>> But maybe in (renamed) 'struct clone_info' instead of 'struct pid_set' ?
>>
>> I vaguely recall a strong preference to not require copy-from-user
>> during a fast-path clone, because it may hurt performance.
>>
>> *If* this is the case, then maybe place extra flags among the
>> "base" args, or at least a CLONE_EXTRA would indicate that more
>> arguments need to be pulled from user-space ?
> 
> Wouldn't passing NULL for struct clone_info suffice?

:o

Actually, I misread the original prototype, and I prefer Suka's
current suggestion.

Oren.

> 
>> Do you intend to get feedback from LKML too ?
>>
>> Oren.
