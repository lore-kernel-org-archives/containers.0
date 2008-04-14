From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Control Groups Roadmap ideas
Date: Mon, 14 Apr 2008 08:03:57 -0700
Message-ID: <6599ad830804140803p2a97c96mbc24f73e1a687aee@mail.gmail.com>
References: <6599ad830804081414x7be75d2fte5b500a7f81df40c@mail.gmail.com>
	<20080411144836.GA6468@sergelap.cust.hotspot.t-mobile.com>
	<6599ad830804132224h4b958891i101c6e068ea15f55@mail.gmail.com>
	<20080414141119.GA11019@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080414141119.GA11019-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Apr 14, 2008 at 7:11 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
>  then all tasks are mapped under /containers.  If login does a
>  clone(CLONE_NEWNS) for hallyn's login to give him a private /tmp,
>  then hallyn ends up under /containers/node_xyz, but we don't want him
>  to be virtualized under there.  So I assume we'd want a virt.lock file
>  or something like that so, that when I create a container, my
>  start_container script can echo 1 > /containers/node_abc/virt.lock

Yes, something like that.

>
>  I assume the container will also have to remount a fresh copy of the
>  cgroup composition so it can have the dentry for /containers/node_abc
>  as the root dentry for /containers?

Yes.

Paul
