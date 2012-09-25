From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 13/14] userns: On ia64 deal with current_uid and
	current_gid being kuid and kgid
Date: Tue, 25 Sep 2012 02:58:01 -0700
Message-ID: <87wqzipgpi.fsf@xmission.com>
References: <87k3vote43.fsf@xmission.com>
	<1348187330-6616-1-git-send-email-ebiederm@xmission.com>
	<1348187330-6616-13-git-send-email-ebiederm@xmission.com>
	<50617630.1050709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50617630.1050709-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Zhao Hongjiang's message of "Tue,
	25 Sep 2012 17:15:28 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On 2012-9-21 8:28, Eric W. Biederman wrote:
>> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> 
>> These ia64 uses of current_uid and current_gid slipped through the
>> cracks when I was converting everything to kuids and kgids convert
>> them now.
>> 
>> Cc: Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> Cc: Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

>> diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
>> index a199be1..37dd795 100644
>> --- a/arch/ia64/kernel/signal.c
>> +++ b/arch/ia64/kernel/signal.c
>> @@ -220,7 +220,7 @@ ia64_rt_sigreturn (struct sigscratch *scr)
>>  	si.si_errno = 0;
>>  	si.si_code = SI_KERNEL;
>>  	si.si_pid = task_pid_vnr(current);
>> -	si.si_uid = current_uid();
>> +	si.si_uid = from_kuid_munged(current_user_ns(), current_uid());
> Question: why use current_user_ns not the init_user_ns here?

Because the value is going to userspace and we want the userspace
value.

This is much less clear than I would like it.  In my ideal world we
would keep this value as a kuid_t right up until we perform the copy
to userspace.  Unfortunately I wasn't able to figure out to make
that happen.

However since this value is destined for user space there would
never be a reason to use &init_user_ns.  Values either stay
a kuid_t or are converted into the user namespace userspace needs.

Eric
