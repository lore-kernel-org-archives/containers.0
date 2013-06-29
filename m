From: Lennart Poettering <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Sat, 29 Jun 2013 03:48:16 +0200
Message-ID: <51CE3CE0.9010506@redhat.com>
References: <CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<1372311907.5871.78.camel@marge.simpson.net>
	<20130627180143.GD5599@mtj.dyndns.org>
	<1372391198.5989.110.camel@marge.simpson.net>
	<20130628040930.GC2500@htj.dyndns.org>
	<1372394950.5989.128.camel@marge.simpson.net>
	<20130628050138.GD2500@htj.dyndns.org>
	<20130628150513.GD5125@dhcp22.suse.cz>
	<CAAAKZwtqYe-c0bfkgHFbzsOKVHifjTwkqcpci=uS1JwqS9TJHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAAAKZwtqYe-c0bfkgHFbzsOKVHifjTwkqcpci=uS1JwqS9TJHQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Cc: jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 28.06.2013 20:53, Tim Hockin wrote:

> a single-agent, we should make a kick-ass implementation that is
> flexible and scalable, and full-featured enough to not require
> divergence at the lowest layer of the stack.  Then build systemd on
> top of that. Let systemd offer more features and policies and
> "semantic" APIs.

Well, what if systemd is already kick-ass? I mean, if you have a problem 
with systemd, then that's your own problem, but I really don't think why 
I should bother?

I for sure am not going to make the PID 1 a client of another daemon. 
That's just wrong. If you have a daemon that is both conceptually the 
manager of another service and the client of that other service, then 
that's bad design and you will easily run into deadlocks and such. Just 
think about it: if you have some external daemon for managing cgroups, 
and you need cgroups for running external daemons, how are you going to 
start the external daemon for managing cgroups? Sure, you can hack 
around this, make that daemon special, and magic, and stuff -- or you 
can just not do such nonsense. There's no reason to repeat the fuckup 
that cgroup became in kernelspace a second time, but this time in 
userspace, with multiple manager daemons all with different and slightly 
incompatible definitions what a unit to manage actualy is...

We want to run fewer, simpler things on our systems, we want to reuse as 
much of the code as we can. You don't achieve that by running yet 
another daemon that does worse what systemd can anyway do simpler, 
easier and better.

The least you could grant us is to have a look at the final APIs we will 
have to offer before you already imply that systemd cannot be a valid 
implementation of any API people could ever agree on.

Lennart
