From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: RFC: Attaching threads to cgroups is OK?
Date: Fri, 12 Sep 2008 14:57:09 -0400
Message-ID: <20080912185709.GA24801__22500.7199369886$1221246063$gmane$org@redhat.com>
References: <48AAA296.8050802@oss.ntt.co.jp>
	<20080819202237.edd75933.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820.204832.131207708.taka@valinux.co.jp>
	<1219288081.28324.30.camel@sebastian.kern.oss.ntt.co.jp>
	<48ACE1B4.8010000@linux.vnet.ibm.com>
	<1219296306.28324.82.camel@sebastian.kern.oss.ntt.co.jp>
	<20080822185527.GD27964@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080822185527.GD27964-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fernando Luis =?iso-8859-1?Q?V=E1zquez?= Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Aug 22, 2008 at 02:55:27PM -0400, Vivek Goyal wrote:
> On Thu, Aug 21, 2008 at 02:25:06PM +0900, Fernando Luis V=E1zquez Cao wro=
te:
> > Hi Balbir,
> > =

> > On Thu, 2008-08-21 at 09:02 +0530, Balbir Singh wrote:
> > > Fernando Luis V=E1zquez Cao wrote:
> > > > On Wed, 2008-08-20 at 20:48 +0900, Hirokazu Takahashi wrote:
> > > >> Hi,
> > > >>
> > > >>>> Tsuruta-san, how about your bio-cgroup's tracking concerning thi=
s?
> > > >>>> If we want to use your tracking functions for each threads seper=
ately, =

> > > >>>> there seems to be a problem.
> > > >>>> =3D=3D=3Dcf. mm_get_bio_cgroup()=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > >>>>            owner
> > > >>>> mm_struct ----> task_struct ----> bio_cgroup
> > > >>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > >>>> In my understanding, the mm_struct of a thread is same as its pa=
rent's.
> > > >>>> So, even if we attach the TIDs of some threads to different cgro=
ups the =

> > > >>>> tracking always returns the same bio_cgroup -- its parent's grou=
p.
> > > >>>> Do you have some policy about in which case we can use your trac=
king?
> > > >>>>
> > > >>> It's will be resitriction when io-controller reuse information of=
 the owner
> > > >>> of memory. But if it's very clear who issues I/O (by tracking rea=
d/write
> > > >>> syscall), we may have chance to record the issuer of I/O to page_=
cgroup
> > > >>> struct. =

> > > >> This might be slightly different topic though,
> > > >> I've been thinking where we should add hooks to track I/O reqeust.
> > > >> I think the following set of hooks is enough whether we are going =
to
> > > >> support thread based cgroup or not.
> > > >>
> > > >>   Hook-1: called when allocating a page, where the memory controll=
er
> > > >> 	  already have a hoook.
> > > >>   Hook-2: called when making a page in page-cache dirty.
> > > >>
> > > >> For anonymous pages, Hook-1 is enough to track any type of I/O req=
uest.
> > > >> For pages in page-cache, Hook-1 is also enough for read I/O because
> > > >> the I/O is issued just once right after allocting the page.
> > > >> For write I/O requests to pages in page-cache, Hook-1 will be okay
> > > >> in most cases but sometimes process in another cgroup may write
> > > >> the pages. In this case, Hook-2 is needed to keep accurate to track
> > > >> I/O requests.
> > > > =

> > > > This relative simplicity is what prompted me to say that we probably
> > > > should try to disentangle the io tracking functionality from the me=
mory
> > > > controller a bit more (of course we still should reuse as much as w=
e can
> > > > from it). The rationale for this is that the existing I/O scheduler
> > > > would benefit from proper io tracking capabilities too, so it'd be =
nice
> > > > if we could have them even in non-cgroup-capable kernels.
> > > > =

> > > =

> > > Hook 2 referred to in the mail above exist today in the form of task =
IO accounting.
> > Yup.
> > =

> > > > As an aside, when the IO context of a certain IO operation is known
> > > > (synchronous IO comes to mind) I think it should be cashed in the
> > > > resulting bio so that we can do without the expensive accesses to
> > > > bio_cgroup once it enters the block layer.
> > > =

> > > Will this give you everything you need for accounting and control (fr=
om the
> > > block layer?)
> > =

> > Well, it depends on what you are trying to achieve.
> > =

> > Current IO schedulers such as CFQ only care about the io_context when
> > scheduling requests. When a new request comes in CFQ assumes that it was
> > originated in the context of the current task, which obviously does not
> > hold true for buffered IO and aio. This problem could be solved by using
> > bio-cgroup for IO tracking, but accessing the io context information is
> > somewhat expensive: =

> > =

> > page->page_cgroup->bio_cgroup->io_context.
> > =

> > If at the time of building a bio we know its io context (i.e. the
> > context of the task or cgroup that generated that bio) I think we should
> > store it in the bio itself, too. With this scheme, whenever the kernel
> > needs to know the io_context of a particular block IO operation the
> > kernel would first try to retrieve its io_context directly from the bio,
> > and, if not available there, would resort to the slow path (accessing it
> > through bio_cgroup). My gut feeling is that elevator-based IO resource
> > controllers would benefit from such an approach, too.
> > =

> =

> Hi Fernando,
> =

> Had a question.
> =

> IIUC, at the time of submtting the bio, io_context will be known only for =

> synchronous request. For asynchronous request it will not be known
> (ex. writing the dirty pages back to disk) and one shall have to take
> the longer path (bio-cgroup thing) to ascertain the io_context associated
> with a request.
> =

> If that's the case, than it looks like we shall have to always traverse t=
he
> longer path in case of asynchronous IO. By putting the io_context pointer
> in bio, we will just shift the time of pointer traversal. (From CFQ to hi=
gher
> layers).
> =

> So probably it is not worth while to put io_context pointer in bio? Am I
> missing something?
> =


Hi Fernando,

I thought you did not get a chance to reply to this mail until today I found
your reply on virtualization list archive. (I am not on the virtualization
list). I am assuming that by mistake you just replied to virutalization list
or mail got lost somewhere.

https://lists.linux-foundation.org/pipermail/virtualization/2008-August/011=
588.html

Anyway, now I understand little better the issue at hand. Because cfq
retrieves the io_context information from the "current" and that can be
problematic in case of any software entitiy above elevator which buffers
the bio's and does some processing and then releases it to elevator. Two
cases come to my mind.

- Any stacked device driver
- I am also running into issues while I am putting all the requests on =

  an rb-tree (per request queue) before releasing them to elevator. I
  try to control the requests on this rb-tree based on cgroup weights and
  then release it to elevator. But I realized that cfq will get the wrong
  io_context information because of request buffering.

It then probably makes sense to put io_context information in bio and
let cfq retrieve it from bio instead of current. This way we will be able
to decouple the assumption that bio belongs to the thread submitting it
to cfq and will allow us to trap request and do processing and then sumit
to cfq without loosing io_context information.

Any kind of cgroup mechanism will also need to map a bio to the respective
cgroup. Because io_context is contained in task_struct, one can retrieve
bio->io_context and then task_struct from it and then find the cgroup
information and account the bio appropriately. But this assumes that
task_struct is still around but that might not be the case..... Any ideas?

Or may be we can go bio->page->pc_page->bio_cgroup->cgroup_id route but
that would not work very well in the case when stacked devices try to
replicate the bio. As you said memory of new bio will belong to some
kernel thread and accounting will not be proper.

That leaves me thinking...

Thanks
Vivek =
