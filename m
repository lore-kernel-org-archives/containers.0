From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH] Make access to taks's nsproxy liter
Date: Thu, 09 Aug 2007 12:17:08 +0400
Message-ID: <46BACD84.8090508@openvz.org>
References: <46B9E321.6070602@openvz.org>	<m1ps1yc7mp.fsf@ebiederm.dsl.xmission.com>	<46BABDE9.6090508@openvz.org>
	<m13aytb0j0.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m13aytb0j0.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
> 
>> Eric W. Biederman wrote:
>>> Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
>>>
>>>> When someone wants to deal with some other taks's namespaces
>>>> it has to lock the task and then to get the desired namespace
>>>> if the one exists. This is slow on read-only paths and may be
>>>> impossible in some cases.
>>>>
>>>> E.g. Oleg recently noticed a race between unshare() and the
>>>> (just sent for review) pid namespaces - when the task notifies
>>>> the parent it has to know the parent's namespace, but taking
>>>> the task_lock() is impossible there - the code is under write
>>>> locked tasklist lock.
>>>>
>>>> On the other hand switching the namespace on task (daemonize)
>>>> and releasing the namespace (after the last task exit) is rather
>>>> rare operation and we can sacrifice its speed to solve the
>>>> issues above.
>>>
>>> Looks pretty decent but we need to clearly say what lock
>>> you have to have to assign to the nsproxy pointer.
>> no locks - only current is allowed to change its nsproxy!
> 
> Exactly.  Just need a comment or something to make that clear.

Oh! Ok, I will add it. Thanks.

> Eric
> 
