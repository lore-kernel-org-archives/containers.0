From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Fri, 20 Mar 2009 15:40:36 -0500
Message-ID: <20090320204036.GB14879@us.ibm.com>
References: <878wn353mf.fsf@caffeine.danplanet.com> <49C1175F.9060600@free.fr>
	<49C1506C.1080500@google.com> <m1bprye5io.fsf@fess.ebiederm.org>
	<49C195CF.1080506@google.com> <m1ab7icodl.fsf@fess.ebiederm.org>
	<49C1A52D.4000503@google.com> <m1iqm6xkc7.fsf@fess.ebiederm.org>
	<20090320172616.GA7203@us.ibm.com> <49C3F3C0.30100@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49C3F3C0.30100-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Mike Waychison (mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn wrote:
>> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>>> Ok.  I see what you are trying to accomplish with this and honestly I
>>> think it is silly.
>>>
>>> We should start the threads we need in the kernel, and if we need to
>>> run clone_pid fine.  I am not comfortable exporting clone_with_pid to
>>> user space.
>>
>> Even if we create the task tree in userspace, I don't see why we
>> can't have the parent of each nested pid_ns pass CLONE_NEWPID to
>> clone_with_pid() instead of doing clone first and then unsharing
>> the pidns?
>>
>> As for clone_with_pid(), I don't particularly like the semantics,
>> but as was discussed over IRC, we could have clone_with_pid()
>> return -EINVAL unless it is called while it is called from a task
>> inside a restarting container.  (and -EPERM if setting a pid in
>> a pid_ns which was not created as part of the container)  Eric
>> do you dislike that any less?
>
> Wouldn't this mean the kernel would have to track which namespaces are  
> part of a restart and which aren't?   Seems a little kludgy to me.

Well it could do that, which would be trivial since it knows the
hierarchy, and knows which ns the init process of the whole restarted
container is.

Or, we can just, as I suggested before, tag the pid_ns with the
uid of the task which created it.  Then a restart can theoritically
specify a pid_t in a clone_with_pid() for a pid_ns pre-existing to
the restart, but it can still only do it for pid namespaces which it
"owns."

Whatever we do, we just need to make sure that an unprivileged task
can't manipulate a checkpoint image so as to pick an id in the
init_pid_ns, as that can be perceived as potentially exacerbating
vulnerabilities in poorly written userspace programs as Linus
mentioned.

-serge
