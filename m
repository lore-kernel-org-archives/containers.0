From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 9/15] Move alloc_pid() after the namespace is cloned
Date: Mon, 30 Jul 2007 10:17:10 +0400
Message-ID: <46AD8266.8050802@openvz.org>
References: <46A8B37B.6050108@openvz.org> <46A8B531.3050602@openvz.org>
	<20070727151238.GA336@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070727151238.GA336-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov wrote:
> On 07/26, Pavel Emelyanov wrote:
>> This is a fix for Sukadev's patch that moved the alloc_pid() call from
>> do_fork() into copy_process().
> 
> ... and this patch changes almost every line from Sukadev's patch.

It does. My bad :( I have reviewed Suka's patch badly and was sure it
puts the alloc_pid() right where we need this.

> Sorry gents, but isn't it better to ask Andrew to drop that patch
> (which is quite useless by itself), and send a new one which incorporates
> all necessary changes? Imho, it would be much easier to understand.

Hm... Maybe it's better to ask him to fold these patches together?

>> @@ -1406,7 +1422,13 @@ long do_fork(unsigned long clone_flags,
>> 	if (!IS_ERR(p)) {
>> 		struct completion vfork;
>>
>> -		nr = pid_nr(task_pid(p));
>> +		/*
>> +		 * this is enough to call pid_nr_ns here, but this if
>> +		 * improves optimisation of regular fork()
>> +		 */
>> +		nr = (clone_flags & CLONE_NEWPID) ?
>> +			task_pid_nr_ns(p, current->nsproxy->pid_ns) :
>> +				task_pid_vnr(p);
> 
> Shouldn't we do the same for CLONE_PARENT_SETTID in copy_process() ?
> Otherwise *parent_tidptr may have a wrong value which doesn't match
> to what fork() returns.

Oops. We should. Thanks :)

> Oleg.

Thanks,
Pavel
