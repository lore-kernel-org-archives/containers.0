From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by tgid
	at once
Date: Tue, 4 Aug 2009 12:28:48 -0700
Message-ID: <6599ad830908041228w67bc6f7fh57e28f244e1923b3@mail.gmail.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
	<20090803175452.GA5481@us.ibm.com>
	<2f86c2480908031113y525b6cbdhe418b8a0364c7760@mail.gmail.com>
	<20090803185556.GA8469@us.ibm.com> <20090803194555.GA10158@us.ibm.com>
	<6599ad830908041148h6d3f3e9bxfef9f3eedec0ab6d@mail.gmail.com>
	<2f86c2480908041214r1f23c1b7q9a25b04e26c92a1a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2f86c2480908041214r1f23c1b7q9a25b04e26c92a1a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 4, 2009 at 12:14 PM, Benjamin Blum<bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>
> Hmm, the tasklist_lock section in fork() is entirely inside the
> read-lock. Presumably then iterating the threadgroup list to take all
> rwsems is safe from a race in which one thread escapes?
>

I think so - the write-side locking would be something like:

again:
  read_lock(&tasklist_lock);
  find first not-yet-locked task t
  while (t != group_leader) {
    if (!down_write_trylock(&t->threadgroup_stability_mutex)) {
      get_task_struct(t);
      read_unlock(&tasklist_lock);
      down_write(&t->threadgroup_stability_mutex);
      put_task_struct(t);
      goto again;
    }
    t = t->next_thread;
  }
  read_unlock(&tasklist_lock);

  Paul
