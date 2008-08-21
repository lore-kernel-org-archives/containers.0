From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: RFC: Attaching threads to cgroups is OK?
Date: Thu, 21 Aug 2008 09:02:04 +0530
Message-ID: <48ACE1B4.8010000@linux.vnet.ibm.com>
References: <48AAA296.8050802@oss.ntt.co.jp>
	<20080819202237.edd75933.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820.204832.131207708.taka@valinux.co.jp>
	<1219288081.28324.30.camel@sebastian.kern.oss.ntt.co.jp>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1219288081.28324.30.camel-xpvPi5bcW5X5OjGIXfuPlhrrLbDL3r4M6qtp775pBPw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?ISO-8859-1?Q?Fernando_Luis_V=E1zquez_Cao?= <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Fernando Luis V=E1zquez Cao wrote:
> On Wed, 2008-08-20 at 20:48 +0900, Hirokazu Takahashi wrote:
>> Hi,
>>
>>>> Tsuruta-san, how about your bio-cgroup's tracking concerning this?
>>>> If we want to use your tracking functions for each threads seperately, =

>>>> there seems to be a problem.
>>>> =3D=3D=3Dcf. mm_get_bio_cgroup()=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
>>>>            owner
>>>> mm_struct ----> task_struct ----> bio_cgroup
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>> In my understanding, the mm_struct of a thread is same as its parent's.
>>>> So, even if we attach the TIDs of some threads to different cgroups th=
e =

>>>> tracking always returns the same bio_cgroup -- its parent's group.
>>>> Do you have some policy about in which case we can use your tracking?
>>>>
>>> It's will be resitriction when io-controller reuse information of the o=
wner
>>> of memory. But if it's very clear who issues I/O (by tracking read/write
>>> syscall), we may have chance to record the issuer of I/O to page_cgroup
>>> struct. =

>> This might be slightly different topic though,
>> I've been thinking where we should add hooks to track I/O reqeust.
>> I think the following set of hooks is enough whether we are going to
>> support thread based cgroup or not.
>>
>>   Hook-1: called when allocating a page, where the memory controller
>> 	  already have a hoook.
>>   Hook-2: called when making a page in page-cache dirty.
>>
>> For anonymous pages, Hook-1 is enough to track any type of I/O request.
>> For pages in page-cache, Hook-1 is also enough for read I/O because
>> the I/O is issued just once right after allocting the page.
>> For write I/O requests to pages in page-cache, Hook-1 will be okay
>> in most cases but sometimes process in another cgroup may write
>> the pages. In this case, Hook-2 is needed to keep accurate to track
>> I/O requests.
> =

> This relative simplicity is what prompted me to say that we probably
> should try to disentangle the io tracking functionality from the memory
> controller a bit more (of course we still should reuse as much as we can
> from it). The rationale for this is that the existing I/O scheduler
> would benefit from proper io tracking capabilities too, so it'd be nice
> if we could have them even in non-cgroup-capable kernels.
> =


Hook 2 referred to in the mail above exist today in the form of task IO acc=
ounting.

> As an aside, when the IO context of a certain IO operation is known
> (synchronous IO comes to mind) I think it should be cashed in the
> resulting bio so that we can do without the expensive accesses to
> bio_cgroup once it enters the block layer.

Will this give you everything you need for accounting and control (from the
block layer?)

-- =

	Balbir
