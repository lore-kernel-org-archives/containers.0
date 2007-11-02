From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Masquerade sender information
Date: Fri, 02 Nov 2007 14:40:24 +0100
Message-ID: <472B28C8.8020302@fr.ibm.com>
References: <20071027190216.GB10397@us.ibm.com>
	<m1hck9ofcz.fsf@ebiederm.dsl.xmission.com>
	<20071101165026.GA25234@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071101165026.GA25234-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org writes:
>>
>>> From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>> Subject: [PATCH] Masquerade sender information
>>>
>>> With multiple pid namespaces, sender of a signal could be in an ancestor
>>> namespace of the receiver and so the sender will not have a valid 'pid_t'
>>> in the receiver's namespace.
>>>
>>> In this case, masquerade the 'siginfo' for the signal to pretend that the
>>> signal originated from the kernel.
>> At first glance this looks ok.  I think the only case where we can
>> be sending a signal from inside a pid namespace to something not
>> in a child pid namespace is if we are the kernel.  In which case
> 
> Are we now blocking F_SETOWN|F_SETSIG signals to outside our pid
> namespace?  mq_notify?  (I didn't think we were)

My understanding is that we're not blokcing and that a process killing 
another process in a sibling pid namespace will have a si_pid = 0.

C. 

> 
>> we also want si_pid = 0.
>>
>> If that holds this problem is easier then I was thinking it would
>> be.
>>
>> Eric
>>
