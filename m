From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH 2/2] cgroups: make procs file writable
Date: Thu, 3 Jun 2010 16:48:10 +0200
Message-ID: <20100603144810.GB6284__48824.1512947299$1275576727$gmane$org@redhat.com>
References: <20100530013303.GC762@ghc01.ghc.andrew.cmu.edu>
	<20100531175242.GA14691@redhat.com>
	<20100531180446.GA16249@redhat.com>
	<AANLkTimcrX0TjzDMNJdubR92pAO4IPATbVpyvvVt0qIV@mail.gmail.com>
	<20100602140659.GA5324@redhat.com>
	<AANLkTin-T6ij3xf0ceGoCamwcoayxyf0GdAKY6yXDMVl@mail.gmail.com>
	<20100602202048.GB28663@redhat.com>
	<AANLkTimrJFiidM8BlUNvmzfapUAv8369R9PYnTscasEf@mail.gmail.com>
	<20100602205855.GA30039@redhat.com>
	<20100603044001.GA21006@ghc02.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100603044001.GA21006-jeg9jHBoDvuqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On 06/03, Ben Blum wrote:
>
> On Wed, Jun 02, 2010 at 10:58:55PM +0200, Oleg Nesterov wrote:
> > Hmm. The usage of ->thread_group in ->can_attach() methods doesn't
> > look safe to me... but currently bool threadgroup is always false.
>
> I recall putting a rcu_read_lock() around that part and being assured
> that made it safe. But I don't remember the details. Maybe taking
> tasklist_lock is necessary?

rcu_read_lock() is not enough, see another email I sent.

Once again.

	rcu_read_lock()
	list_for_each_rcu(tsk->thread_group)

assumes that at least tsk->thread_group->next can't point to nowhere,
this is not true. This memory can go away _before_ we take rcu lock.

Oleg.
