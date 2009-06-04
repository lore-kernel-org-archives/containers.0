From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/4] cgroup freezer: Fix buggy resume test for tasks	frozen
	with cgroup freezer
Date: Thu, 04 Jun 2009 08:55:17 +0800
Message-ID: <4A271B75.7090607@cn.fujitsu.com>
References: <cover.1244019829.git.matthltc@us.ibm.com>	<91260d5797bcf233ca54c7b41da8278e99b4ca66.1244019829.git.matthltc@us.ibm.com>
	<20090603160551.GB7848@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090603160551.GB7848-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> -int cgroup_frozen(struct task_struct *task)
>> +int cgroup_freezing_or_frozen(struct task_struct *task)
>>  {
>>  	struct freezer *freezer;
>>  	enum freezer_state state;
>>
>>  	task_lock(task);
>>  	freezer = task_freezer(task);
>> -	state = freezer->state;
>> +	if (!freezer->css.cgroup->parent)
>> +		state = CGROUP_THAWED; /* root cgroup can't be frozen */
>> +	else
>> +		state = freezer->state;
> 
> Why do you have to add this special-casing now?  I thought
> we were already preventing freezing the root cgroup, so
> freezer->state should be sane in that case anyway?
> 

Yeah, IIRC top_freezer->state is alwasy CGROUP_THAWED, so this
check is redundant.

>>  	task_unlock(task);
>>
>> -	return state == CGROUP_FROZEN;
>> +	return (state == CGROUP_FREEZING) || (state == CGROUP_FROZEN);
>>  }
