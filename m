From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Wed, 18 Apr 2012 10:10:54 +0200
Message-ID: <CAFTL4hxXT+hXWEnKop84JQ8ieHX4e=otpHnXYxdxaPgsiZYCiw__29714.8167308935$1334736667$gmane$org@mail.gmail.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<20120412010745.GE1787@cmpxchg.org>
	<20120412145507.GC11455@somewhere.redhat.com>
	<4F87042A.2000902@parallels.com>
	<20120412165922.GA12484@somewhere.redhat.com>
	<20120417151753.GB32402@google.com>
	<20120418065430.GB25568@somewhere>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120418065430.GB25568@somewhere>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

2012/4/18 Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> On Tue, Apr 17, 2012 at 08:17:53AM -0700, Tejun Heo wrote:
>> Hello, Frederic.
>>
>> On Thu, Apr 12, 2012 at 06:59:27PM +0200, Frederic Weisbecker wrote:
>> > I want:
>> >
>> > a) to prevent the forkbomb from going far enough to DDOS the machine
>> > b) to be able to kill that forkbomb once detected, in one go without r=
ace
>> > against concurrent forks.
>> >
>> > I think a) can work just fine with kernel stack limiting. I also need
>> > to be notified about the fact we reached the limit. And b) should
>> > be feasible with the help of the cgroup freezer.
>>
>> kmem allocation fail after reaching the limit which in turn should
>> fail task creation. =A0Isn't that the same effect as the task_counter as
>> implemented?
>
> That's it.
>
>>
>> > > Is there anything for which you need to know exactly the number of
>> > > processes?
>> >
>> > No that's really about prevent/kill forkbomb as far as I'm concerned.
>>
>> Hmm... so, accounting overhead aside, if the only purpose is
>> preventing the whole machine being brought down by a fork bomb, kmem
>> limiting is enough, right?
>
> I think so yeah.

But this needs to be a well defined kind of kmem I think. Relying on
kernel memory
alone is too general to just protect against forkbombs. Kernel stack,
OTOH, should be
a good criteria.

But now I'm worrying, do you think this kmem.kernel_stack limitation
is going to be useful
for other kind of usecase?
