From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Fri, 02 Mar 2012 12:23:14 +0100
Message-ID: <1330687394.11248.222.camel__37172.3044002012$1330687425$gmane$org@twins>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com> <20120222165714.GC4128@redhat.com>
	<1329990094.24994.64.camel@twins> <1330006399.11248.20.camel@twins>
	<4F4FAF89.3090706@redhat.com> <1330624986.11248.209.camel@twins>
	<4F50AA22.9080007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4F50AA22.9080007-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2012-03-02 at 12:08 +0100, Michal Schmidt wrote:
> And what exactly do you mean by booting? Obviously not booting into a 
> full desktop environment, because that requires a lot of features.

Nah, who needs that stuff anyway :-) Note that even my desktop and
laptop work fine without initrd, systemd and CONFIG_CGROUP nonsense. And
while they are bloated with useless crap like *Kit and others, simply
because I can't get myself to rebuild enough to get rid of the
dependencies, I utterly hate them being around.

> If on the other hand you are satisfied with booting into a getty with 
> not many services around, in this sense systemd will boot without 
> CONFIG_CGROUPS. 

Except that it waits a random amount of time, long enough for me to
think the machine didn't come back up and power cycle again. The random
delay is _waay_ longer than a regular reboot cycle and totally destroys
the usability.

> It's recommended not to do that and nobody actively 
> tests this setup, but at least systemd will not abort. So it can be used 
> to check if the kernel boots and to run some tests. 

So you don't recommend people use server type setups? Quality
engineering that!
