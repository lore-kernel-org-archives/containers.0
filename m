From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] Add a 'trigger' callback on struct cftype.
Date: Thu, 13 Mar 2008 12:37:45 +0300
Message-ID: <47D8F5E9.5000203@openvz.org>
References: <47D6A36F.2080706@openvz.org>	
	<6599ad830803110900j7d47bd6eqf8747bdb704c9226@mail.gmail.com>	
	<47D6AF98.4030204@openvz.org>
	<6599ad830803110916i1bbc7c7an2412c0facb3496ef@mail.gmail.com>
	<47D6B19A.3080906@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47D6B19A.3080906-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Paul Menage wrote:
>> On Tue, Mar 11, 2008 at 9:13 AM, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
>>> --- a/include/linux/cgroup.h
>>>  +++ b/include/linux/cgroup.h
>>>  @@ -243,7 +243,7 @@ struct cftype {
>>>
>>>          */
>>>         int (*write_s64) (struct cgroup *cgrp, struct cftype *cft, s64 val);
>>>
>>>  -       void (*trigger) (struct cgroup *cgrp, unsigned int event);
>>>  +       int (*trigger) (struct cgroup *cgrp, unsigned int event);
>> To be more name-compatible with the other read_X/write_X functions,
>> how about write_void rather than trigger?
> 
> Because it's not a write actually, this is just some kick-up which came
> from the user space. And the fact, that it is triggered via the sys_write
> is just a VFS-based API constraints. Besides, if we ever have a binary 
> API with cgroups, this trigger can be triggered :) via some other system
> call, rather than write.

So, Paul, do you have any more objections to the patch? If no, I will
prepare the set for Andrew, all the more so, I noticed, that there's
no ability to reset the failcounter, which is required and can be easily
implemented with the triggers.

>> Paul
>>
> 
> 
