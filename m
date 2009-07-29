From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/6] Makes procs file writable to move all threads by tgid
	at once
Date: Tue, 28 Jul 2009 17:23:01 -0700
Message-ID: <2f86c2480907281723n7452c7f5l5a475e8120dccd83__3820.70582495562$1248827080$gmane$org@mail.gmail.com>
References: <20090724032033.2463.79256.stgit@hastromil.mtv.corp.google.com>
	<20090724032200.2463.82408.stgit@hastromil.mtv.corp.google.com>
	<20090724100220.GF11101@hawkmoon.kerlabs.com>
	<2f86c2480907241452m74c50975k522c5a43a62e8459@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2f86c2480907241452m74c50975k522c5a43a62e8459-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, menage
List-Id: containers.vger.kernel.org

On Fri, Jul 24, 2009 at 2:52 PM, Benjamin Blum<bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, Jul 24, 2009 at 3:02 AM, Louis Rilling<Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>=
 wrote:
>> On 23/07/09 20:22 -0700, Ben Blum wrote:
>>> @@ -408,6 +409,15 @@ You can attach the current shell task by echoing 0:
>>>
>>> =A0# echo 0 > tasks
>>>
>>> +The cgroup.procs file is useful for managing all tasks in a threadgrou=
p at
>>> +once. It works the same way as the tasks file, but moves all tasks in =
the
>>> +threadgroup with the specified tgid.
>>> +
>>> +Writing the pid of a task that's not the threadgroup leader (i.e., a p=
id
>>> +that isn't a tgid) is treated as invalid. Writing a '0' to cgroup.proc=
s will
>>> +attach the writing task and all tasks in its threadgroup, but is inval=
id if
>>> +the writing task is not the leader of the threadgroup.
>>> +
>>
>> This restriction sounds unfortunate and I'm not sure that there are good=
 reasons
>> for it (see below).
>
> Would it be preferable to allow any thread in a threadgroup to move
> the whole group to a new cgroup? Would that undermine the desired
> restriction of the tasks file in which a thread needs to have
> sufficient perms to move a thread that's not itself, or is the task
> file's restriction there undesirable in the case of threadgroups?

Still wondering on what to do about this. Noting that this restriction
approximately parallels the behaviour you'd get from using the tasks
file, I think it'd be safer to leave it like this then possibly in the
future lift the restriction, rather than make it currently lifted then
decide in the future that we want to re-impose it.

>>> + =A0 =A0 =A0* to move all tasks to the new cgroup. the only fail case =
henceforth
>>> + =A0 =A0 =A0* is if the threadgroup leader has PF_EXITING set (in whic=
h case all
>>> + =A0 =A0 =A0* the other threads get killed) - if other threads happen =
to be
>>
>> This statement is wrong. A thread group leader can have PF_EXITING (and =
even
>> become zombie) while other sub-threads continue their execution. For ins=
tance it
>> is perfectly valid for a thread group leader to call sys_exit(), and no =
other
>> thread will be affected.
>
> Is that the case? Then, what becomes of his task_struct when he's
> gone, since presumably all the sub-threads will need it. Does it just
> hang around?
>
> If so, would the desired behaviour be to proceed with moving all
> sub-threads if the leader is exiting? (That's not a very big change
> code-wise)
>

I've fixed this, and also implemented the rwsem as threadgroup-local.
If there's no more discussion on this version of the patch, I'll send
out the revised series soon.
