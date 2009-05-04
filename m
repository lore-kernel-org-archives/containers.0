From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 00/54] Kernel based checkpoint/restart
Date: Mon, 4 May 2009 08:01:08 -0500
Message-ID: <20090504130108.GA21521@us.ibm.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<20090429081815.GA1813@hawkmoon.kerlabs.com>
	<49F8D8FC.8010400@cs.columbia.edu> <49FEB01B.208@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49FEB01B.208-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Matthieu =?iso-8859-1?Q?Fertr=E9?= <matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> > I see one drawback with this approach if you allow checkpoint of
> > application that is not isolated in a container. In that case, you may
> > want to select which IPC objects to dump to not dump all the IPC objects
> > living in the system. Indeed, this is why we have chosen in Kerrighed to
> > checkpoint IPC objects independently of tasks, since we have no
> > container/namespaces support currently.
> 
> I assume that in this case it will be the application itself that
> will somehow tell the system which specific sysvipc objects (ids) it
> cares about.
> 
> (I'm not sure how would the system otherwise know what to dump and
> what to leave out).
> 
> I originally proposed the construct of cradvise() syscall to handle
> exactly those cases where the application would like to advise the
> kernel about certain resources. So, extending the previous example,
> a task may call something like:
> 
>    cradvise(CHECKPOINT_SYSVIPC_SHM, false);  /* generally skip shm */
>    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, true);  /* but include this */
> 
> or:
>    cradvise(CHECKPOINT_SYSVIPC_SHM, true);  /* generally include shm */
>    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, false);  /* but skip this */
> 
> Anyway, these are just examples of the concept and what sort of generic
> interface can be used to implement it; don't pick on the details...
> 
> Oren.

Oren, I have to be honest:  I could of course be wrong, but imo there
is 0 chance of such a bigger-and-uglier-than-ioctl syscall as cradvise
being accepted upstream.  There may be good uses for it, but I think
it's worthwhile thinking of ways around it whenever possible.

In this particular case, wouldn't it be better to do something like:

	1. freeze + checkpoint full application + container (== C1)
	2. continue application, which does a clone(CLONE_COPYIPC) (*1)
	3. application removes all shms except the one to be
	checkpointed
	4. freeze + checkpoint application again ( == C2)
	5. restart applicaiton from C1

This requires an ability to clone an ipc namespace while copying its
contents, but that seems more viable upstream, and more generally
useful, than yet another use for cradvise().

-serge
