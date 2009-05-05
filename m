From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 00/54] Kernel based checkpoint/restart
Date: Tue, 5 May 2009 08:49:20 -0500
Message-ID: <20090505134920.GB10136@us.ibm.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<20090429081815.GA1813@hawkmoon.kerlabs.com>
	<49F8D8FC.8010400@cs.columbia.edu> <49FEB01B.208@cs.columbia.edu>
	<20090504130108.GA21521@us.ibm.com>
	<20090505082057.GA11377@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090505082057.GA11377-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Matthieu =?iso-8859-1?Q?Fertr=E9?= <matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Alexey Dobriyan <adobriyan@g>
List-Id: containers.vger.kernel.org

Quoting Louis Rilling (Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org):
> On 04/05/09  8:01 -0500, Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> > > > I see one drawback with this approach if you allow checkpoint of
> > > > application that is not isolated in a container. In that case, you may
> > > > want to select which IPC objects to dump to not dump all the IPC objects
> > > > living in the system. Indeed, this is why we have chosen in Kerrighed to
> > > > checkpoint IPC objects independently of tasks, since we have no
> > > > container/namespaces support currently.
> > > 
> > > I assume that in this case it will be the application itself that
> > > will somehow tell the system which specific sysvipc objects (ids) it
> > > cares about.
> > > 
> > > (I'm not sure how would the system otherwise know what to dump and
> > > what to leave out).
> > > 
> > > I originally proposed the construct of cradvise() syscall to handle
> > > exactly those cases where the application would like to advise the
> > > kernel about certain resources. So, extending the previous example,
> > > a task may call something like:
> > > 
> > >    cradvise(CHECKPOINT_SYSVIPC_SHM, false);  /* generally skip shm */
> > >    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, true);  /* but include this */
> > > 
> > > or:
> > >    cradvise(CHECKPOINT_SYSVIPC_SHM, true);  /* generally include shm */
> > >    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, false);  /* but skip this */
> > > 
> > > Anyway, these are just examples of the concept and what sort of generic
> > > interface can be used to implement it; don't pick on the details...
> > > 
> > > Oren.
> > 
> > Oren, I have to be honest:  I could of course be wrong, but imo there
> > is 0 chance of such a bigger-and-uglier-than-ioctl syscall as cradvise
> > being accepted upstream.  There may be good uses for it, but I think
> > it's worthwhile thinking of ways around it whenever possible.
> > 
> > In this particular case, wouldn't it be better to do something like:
> > 
> > 	1. freeze + checkpoint full application + container (== C1)
> > 	2. continue application, which does a clone(CLONE_COPYIPC) (*1)
> > 	3. application removes all shms except the one to be
> > 	checkpointed
> > 	4. freeze + checkpoint application again ( == C2)
> > 	5. restart applicaiton from C1
> > 
> 
> Besides COW issues mentioned by Oren in his reply, this approach does not
> seem to provide the required flexibility. The point is to avoid checkpointing
> some IPC objects together with the application,

... avoided at step 3 ...

> but we still need those IPC
> objects, and the application still uses them.

... step 5 ...

> Moreover, on restart the
> administrator should be able to first install the required IPC objects, e.g.
> re-create them from scratch, or restore them from another checkpoint, and second
> restart the application, linking it to the previously
> re-created/restored/whatever SHMs.

Of course he can do that.

Anyway I'm not setting off to implement the clone(COPY_IPC)
functionality, and Oren might be right that cradvise would
be deemed different from ioctl.  I just thought I'd give a
warning, and (being a productive type :) give an alternative...

By the way, another alternative to all of the cr_advise()
stuff is to have userspace programs carve up your checkpoint
images.  It's been talked about before, but I believe Nathan
in particular is worried about what this says about kernel-user
API.

-serge
