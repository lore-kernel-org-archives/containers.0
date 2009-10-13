From: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: LXC PIDs, UIDs, and halt
Date: Tue, 13 Oct 2009 00:06:10 -0500
Message-ID: <68e6eac60910122206i7c39fca0u52ab037748217336@mail.gmail.com>
References: <68e6eac60910110930q74358967o19e3d0e88e111bd5@mail.gmail.com>
	<20091012150355.GA5783@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091012150355.GA5783-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Oct 12, 2009 at 10:03 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> Quoting Dwight Schauer (dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> > 4) In a opensuse container when I execute "halt" it is not just the
> > container that halts, but the controlling host as well that shuts down.
>
> Make sure that the container is launched with CAP_SYS_BOOT removed from
> the capability bounding set.
>

Ok, well it turns out any container can halt the whole system.

If I do:
  capsh --drop="cap_sys_boot" -- -c "lxc-start -n arch-test0"
Then do a halt within the container, the halt still works.
A "reboot" within a container does not reboot the controlling host, the
container runs the shutdown scripts and then idles.

However, if on the controlling host I do:
  capsh --drop="cap_kill" -c "bash --login -i"
Then the subsequent shell can't use kill which I have verified.

Well, these performed on the controlling host:
  capsh --drop="cap_sys_boot" -- -c "halt"
  capsh --drop="cap_sys_boot" -- -c "reboot"

Still halt and reboot my system.

So I know that capabilities are working, I just have not figured out yet how
to prevent containers from being able to halt the controlling host (short of
simply not executing "halt" within a container or renaming/removing "halt"
and "shutdown" but then "init 0" would still work).

CAP_SYS_BOOT seems to control reboot, which has not been an issue, I've not
gotten a container to reboot the controlling host.


Dwight
