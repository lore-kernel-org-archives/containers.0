From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: PROBLEM: Processes writing large files in memory-limited LXC
	container are killed by OOM
Date: Mon, 1 Jul 2013 10:21:50 -0500
Message-ID: <20130701152150.GA4078@sergelap>
References: <CAMcjixYa-mjo5TrxmtBkr0MOf+8r_iSeW5MF4c8nJKdp5m+RPA@mail.gmail.com>
	<20130625132432.GA4098@sergelap>
	<CAMcjixZtW0KdAmLXyDoGFqL2qh4aEgdGjBYJWrPESFMz0dvELw@mail.gmail.com>
	<CAC8teKXNof5PdU2dMz4iZ8tM=Dx=aZ0efxotDhdc-xopeK-+Xg@mail.gmail.com>
	<CAMcjixZdXWGezcVQPPo3M0yNBx4TtbiOoqYJQWvNbTyqULifUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAMcjixZdXWGezcVQPPo3M0yNBx4TtbiOoqYJQWvNbTyqULifUA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aaron Staley <aaron-ZNH+RosXeVlBDgjK7y7TUQ@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Aaron Staley (aaron-ZNH+RosXeVlBDgjK7y7TUQ@public.gmane.org):
> The behavior it fixes sounds similar to what I'm seeing. However, if I read
> the logs correctly, wasn't this committed into Linux 3.5? If so, wouldn't
> Linux 3.8.0-25-generic #37-Ubuntu SMP (where I can reproduce the problem)
> already have this fix?

Hi,

I've been trying to reproduce this in ubuntu raring, but couldn't.  I
started a shell as unprivileged user, and stuck it in a memory cgroup
with memory.limit_in_bytes set to 10M.  Did dd if=/dev/zero of=/tmp/xxx
bs=1M count=100M - it was slow, and memory.failcnt hit 1612526, but it
did in the end succeed.

kernel here is 3.8.0-23-generic #34-Ubuntu, slightly older than you.
Maybe you're onto a new regression?

-serge
