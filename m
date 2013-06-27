From: Aaron Staley <aaron-ZNH+RosXeVlBDgjK7y7TUQ@public.gmane.org>
Subject: Re: PROBLEM: Processes writing large files in memory-limited LXC
	container are killed by OOM
Date: Wed, 26 Jun 2013 22:19:51 -0700
Message-ID: <CAMcjixZdXWGezcVQPPo3M0yNBx4TtbiOoqYJQWvNbTyqULifUA@mail.gmail.com>
References: <CAMcjixYa-mjo5TrxmtBkr0MOf+8r_iSeW5MF4c8nJKdp5m+RPA@mail.gmail.com>
	<20130625132432.GA4098@sergelap>
	<CAMcjixZtW0KdAmLXyDoGFqL2qh4aEgdGjBYJWrPESFMz0dvELw@mail.gmail.com>
	<CAC8teKXNof5PdU2dMz4iZ8tM=Dx=aZ0efxotDhdc-xopeK-+Xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAC8teKXNof5PdU2dMz4iZ8tM=Dx=aZ0efxotDhdc-xopeK-+Xg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhu Yanhai <zhu.yanhai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

The behavior it fixes sounds similar to what I'm seeing. However, if I read
the logs correctly, wasn't this committed into Linux 3.5? If so, wouldn't
Linux 3.8.0-25-generic #37-Ubuntu SMP (where I can reproduce the problem)
already have this fix?

Thanks,
Aaron


On Wed, Jun 26, 2013 at 10:12 PM, Zhu Yanhai <zhu.yanhai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Hi,
> Please check this patch, it could fix your problem,
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=e62e384e9da8d9a0c599795464a7e76fd490931c
>
> --
> Thanks,
> Zhu Yanhai
>
>
> 2013/6/26 Aaron Staley <aaron-ZNH+RosXeVlBDgjK7y7TUQ@public.gmane.org>
>
>> Hi Serge,
>>
>> Thanks a lot. Would you know of any workarounds outside of forcing every
>> write to sync to disk (which kills performance)? Perhaps some settings in
>> the container I can set?  Unfortunately, modifying dirty_background_ratio
>>  and dirty_expire_centiseconds globally (/etc/sysctl.conf) as suggested by
>> the serverfault answer will not stop the OOM kills.
>>
>> Regards,
>> Aaron
>>
>>
>> On Tue, Jun 25, 2013 at 6:24 AM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
>> >wrote:
>>
>> > Quoting Aaron Staley (aaron-ZNH+RosXeVlBDgjK7y7TUQ@public.gmane.org):
>> > > This is better explained here:
>> > >
>> >
>> http://serverfault.com/questions/516074/why-are-applications-in-a-memory-limited-lxc-container-writing-large-files-to-di
>> > > (The
>> > > highest-voted answer believes this to be a kernel bug.)
>> >
>> > Yeah, sorry I haven't had time to look more into it, but I'm pretty
>> > that's the case.  When you sent the previous email I looked quickly at
>> > the dd source.  I had always assumed that dd looked at available memory
>> > and malloced as much as it thought it could - but looking at the source,
>> > it does not in fact do that.  So yes, I think the kernel is simply
>> > leaving it all in page cache and accounting that to the process which
>> > then gets OOMed.
>> >
>> > Instead, the kernel should be throttling the task while it waits for
>> > the page cache to be written to disk (since blkio might also be
>> > slowed down).
>> >
>> > -serge
>> >
>>
>>
>>
>> --
>> Aaron Staley
>> *PiCloud, Inc.*
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linuxfoundation.org/mailman/listinfo/containers
>>
>
>


-- 
Aaron Staley
*PiCloud, Inc.*
