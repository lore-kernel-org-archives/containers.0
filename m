From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by tgid
	at once
Date: Tue, 4 Aug 2009 15:14:59 -0400
Message-ID: <2f86c2480908041214r1f23c1b7q9a25b04e26c92a1a@mail.gmail.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
	<20090803175452.GA5481@us.ibm.com>
	<2f86c2480908031113y525b6cbdhe418b8a0364c7760@mail.gmail.com>
	<20090803185556.GA8469@us.ibm.com> <20090803194555.GA10158@us.ibm.com>
	<6599ad830908041148h6d3f3e9bxfef9f3eedec0ab6d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830908041148h6d3f3e9bxfef9f3eedec0ab6d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 4, 2009 at 2:48 PM, Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, Aug 3, 2009 at 12:45 PM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>>
>> This is probably a stupid idea, but... =A0what about having zero
>> overhead at clone(), and instead, at cgroup_task_migrate(),
>> dequeue_task()ing all of the affected threads for the duration of
>> the migrate?
>>
>
> Or a simpler alternative - rather than taking the thread group
> leader's rwsem in cgroup_fork(), always take current's rwsem. Then
> you're always locking a (probably?) local rwsem and minimizing the
> overhead. So not quite zero overhead in the fork path, but I'd be
> surprised if it was measurable. In cgroup_attach_proc() you then have
> to take the rwsem of every thread in the process. Kind of the
> equivalent of a per-threadgroup big-reader lock.

Hmm, the tasklist_lock section in fork() is entirely inside the
read-lock. Presumably then iterating the threadgroup list to take all
rwsems is safe from a race in which one thread escapes?
