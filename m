From: =?ISO-8859-1?Q?Fernando_Luis_V=E1zquez_Cao?=
 <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: Block I/O tracking (was Re: [PATCH 3/9] bio-cgroup controller)
Date: Fri, 17 Apr 2009 20:27:25 +0900
Message-ID: <49E8679D.8010405__19119.4115359851$1239968491$gmane$org@oss.ntt.co.jp>
References: <1239740480-28125-4-git-send-email-righi.andrea@gmail.com>	<49E7E037.9080004@oss.ntt.co.jp>	<20090417112433.085ed604.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417.162201.183038478.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090417.162201.183038478.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Ryo Tsuruta wrote:
> Hi,
> =

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Date: Fri, 17 Apr 2009 11:24:33 +0900
> =

>> On Fri, 17 Apr 2009 10:49:43 +0900
>> Takuya Yoshikawa <yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org> wrote:
>>
>>> Hi,
>>>
>>> I have a few question.
>>>    - I have not yet fully understood how your controller are using
>>>      bio_cgroup. If my view is wrong please tell me.
>>>
>>> o In my view, bio_cgroup's implementation strongly depends on
>>>    page_cgoup's. Could you explain for what purpose does this
>>>    functionality itself should be implemented as cgroup subsystem?
>>>    Using page_cgoup and implementing tracking APIs is not enough?
>> I'll definitely do "Nack" to add full bio-cgroup members to page_cgroup.
>> Now, page_cgroup is 40bytes(in 64bit arch.) And all of them are allocate=
d at
>> boot time as memmap. (and add member to struct page is much harder ;)
>>
>> IIUC, feature for "tracking bio" is just necesary for pages for I/O.
>> So, I think it's much better to add misc. information to struct bio not =
to the page.
>> But, if people want to add "small hint" to struct page or struct page_cg=
roup
>> for tracking buffered I/O, I'll give you help as much as I can.
>> Maybe using "unused bits" in page_cgroup->flags is a choice with no over=
head.
> =

> In the case where the bio-cgroup data is allocated dynamically,
>    - Sometimes quite a large amount of memory get marked dirty.
>      In this case it requires more kernel memory than that of the
>      current implementation.
>    - The operation is expansive due to memory allocations and exclusive
>      controls by such as spinlocks.
> =

> In the case where the bio-cgroup data is allocated by delayed allocation, =

>   - It makes the operation complicated and expensive, because
>     sometimes a bio has to be created in the context of other
>     processes, such as aio and swap-out operation.
> =

> I'd prefer a simple and lightweight implementation. bio-cgroup only
> needs 4bytes unlike memory controller. The reason why bio-cgroup chose
> this approach is to minimize the overhead.

Elaborating on Yoshikawa-san's comment, I would like to propose a
generic I/O tracking mechanism that is not tied to all the cgroup
paraphernalia. This approach has several advantages:

- By using this functionality, existing I/O schedulers (well, some
relatively minor changes would be needed) would be able to schedule
buffered I/O properly.

- The amount of memory consumed to do the tracking could be
optimized according to the kernel configuration (do we really
need struct page_cgroup when the cgroup memory controller or all
of the cgroup infrastructure has been configured out?).

The I/O tracking functionality would look something like the following:

- Create an API to acquire the I/O context of a certain page, which is
cgroup independent. For discussion purposes, I will assume that the
I/O context of a page is the io_context of the task that dirtied the
page (this can be changed if deemed necessary, though).

- When cgroups are not being used, pages would be tracked using a
pfn-indexed array of struct io_context (=E0 la memcg's array of
struct page_cgroup).

- When cgroups are activated but the memory controller is not, we
would have a pfn-indexed array of struct blkio_cgroup, which would
have both a pointer to the corresponding io_context of the page and a
reference to the cgroup it belongs to (most likely using css_id). The
API offered by the I/O tracking mechanism would be extended so that
the kernel can easily obtain not only the per-task io_context but also
the cgroup a certain page belongs to. Please notice that by doing this
we have all the information we need to schedule buffered I/O both at
the cgroup-level and the task-level. From the memory usage point of
view, memory controller-specific bits would be gone and to top it all
we save one indirection level (since struct page_cgroup would be out
of the picture).

- When the memory controller is active we would have the
pfn-indexed array of struct page_cgroup we have know plus a
reference to the corresponding cgroup and io_context (yes, I
still want to do proper scheduling of buffered I/O within a
cgroup).

- Finally, since bio entering the block layer can generate additional
bios it is necessary to pass the I/O context information of original
bio down to the new bios. For that stacking devices such as dm and
those of that ilk will have to be modified. To improve performance I/O
context information would be cached in bios (to achieve this we have
to ensure that all bios that enter the block layer have the right I/O
context information attached to it).

Yoshikawa-san and myself have been working on a patch-set that
implements just this and we have reached that point where the kernel
does not panic right after booting:), so we will be sending patches soon
(hopefully this weekend).

Any thoughts?

Regards,

Fernando
