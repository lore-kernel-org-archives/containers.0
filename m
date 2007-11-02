From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Masquerade sender information
Date: Fri, 02 Nov 2007 15:05:48 +0100
Message-ID: <472B2EBC.3010504@fr.ibm.com>
References: <20071027190216.GB10397@us.ibm.com>
	<m1mytxewb0.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1mytxewb0.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org writes:
> 
>> +static void masquerade_sender(struct task_struct *t, struct sigqueue *q)
>> +{
>> +       /*
>> +        * If the sender does not have a pid_t in the receiver's active
>> +        * pid namespace, set si_pid to 0 and pretend signal originated
>> +        * from the kernel.
>> +        */
>> +       if (!pid_ns_equal(t)) {
>> +               q->info.si_pid = 0;
>> +               q->info.si_uid = 0;
>> +               q->info.si_code = SI_KERNEL;
>> +       }
>> +}
> 
> It looks like we are hooked in the right place.  However the way we
> are handling this appears wrong.
> 
> First.  If we have an si_code that does not use si_pid then we should
> not be changing si_pid, because the structure is a union and that field
> is not always a pid value.
> 
> 
> My gut feel says the code should be something like:
> 
> switch (q->info->si_code & __SI_MASK) {
> case __SI_KILL:
> case __SI_CHILD:
> case __SI_RT:
> case __MESQ:
>        q->info->si_pid = task_pid_nr_ns(current, t->nsproxy->pid_ns);
>        break;
> }

IMHO, it should be 

	q->info->si_pid = 0.

we're trying to cover the case where the sender does not have a pid_t in 
the receiver's active pid namespace.

C.
