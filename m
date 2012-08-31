From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Virtualizing /proc/sys/kernel/random/boot_id per container ?
Date: Thu, 30 Aug 2012 17:18:06 -0700
Message-ID: <874nnjhq2p.fsf@xmission.com>
References: <20120830211832.GA3297@redhat.com> <878vcwjabu.fsf@xmission.com>
	<20120830232239.GE9226@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120830232239.GE9226-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Daniel P. Berrange's message
	of "Thu, 30 Aug 2012 16:22:39 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

"Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Thu, Aug 30, 2012 at 03:15:17PM -0700, Eric W. Biederman wrote:
>> "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > One of the features that SystemD folks have asked us to fix in LXC, is
>> > to make sure that /proc/sys/kernel/random/boot_id changes each time a
>> > container is started.
>> 
>> There may be a good reason for this.  Most of the time what I have seen
>> of kernel requests from the direction of SystemD is that while there may
>> be a real problem but usually their imagined solution is not a
>> particularly good solution.  So a description of the problem is needed.
>> 
>> Justifying something with just SystemD wants this is a good way to get
>> a nack.
>> 
>> > The current semantics are that this file produces a new random UUID each
>> > time the host OS is booted. Obviously each time we start a container now,
>> > they just see the host's random boot_id, so from a container's POV this
>> > does not change each time it starts.
>> 
>> That is correct.  As I recall the contract with boot_id is to provide
>> a unique per boot value to assist in dealing with boots etc.  I seem
>> to recall emacs uses the combination of hostname+boot_id to help
>> generate unique lock files names.
>> 
>> I would definitely need a refresher on how boot_id is used in practice
>> by applications other than SystemD before I could suggest a good design.
>
> This post seems to describe what emacs wants boot_id for:
>
>   http://marc.info/?l=linux-kernel&m=93613053109494&w=2
>
> With this info, I think emacs inside a container would expect the boot_id
> to change each time the container is started, so they can detect stale
> locks from an emacs instance in a previous boot of the container.

Thanks that patch does clarify the original purpose.

Unfortunately the lines of communication were crossed because emacs
24.1 most certainly does not use /proc/sys/kernel/random/boot_id.

Eric
