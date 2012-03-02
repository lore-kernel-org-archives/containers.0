From: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Fri, 02 Mar 2012 12:08:18 +0100
Message-ID: <4F50AA22.9080007@redhat.com>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com>
	<20120222165714.GC4128@redhat.com>
	<1329990094.24994.64.camel@twins>
	<1330006399.11248.20.camel@twins> <4F4FAF89.3090706@redhat.com>
	<1330624986.11248.209.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1330624986.11248.209.camel@twins>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 03/01/2012 07:03 PM, Peter Zijlstra wrote:
> On Thu, 2012-03-01 at 18:19 +0100, Michal Schmidt wrote:
>> Dne 23.2.2012 15:13, Peter Zijlstra napsal:
>>> My utter disregard for cgroups comes from having to actually implement a
>>> controller for them, its a frigging nightmare. The systemd retards
>>> mandating all this nonsense for booting a machine is completely bonghit
>>> inspired and hasn't made me feel any better about it.
>>
>> systemd requires only CONFIG_CGROUPS=y. It does not need any controllers.
>
> And that makes it better how?

Because it is not involved in the controllers nightmare you have.
systemd does not require "all this nonsense".

>> The insults are entirely unnecessary.
>
> I think not, booting a machine should depend on the smallest possible
> subset of features. Doing anything else is completely bonkers.

Your disagreement does not justify calling the people on the other side 
retards.

Your statement about the smallest feature subset could use some 
clarification. Should we make sure everything works fine without, say, 
CONFIG_UNIX?
And what exactly do you mean by booting? Obviously not booting into a 
full desktop environment, because that requires a lot of features.
If on the other hand you are satisfied with booting into a getty with 
not many services around, in this sense systemd will boot without 
CONFIG_CGROUPS. It's recommended not to do that and nobody actively 
tests this setup, but at least systemd will not abort. So it can be used 
to check if the kernel boots and to run some tests.

Michal
