From: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: LXC PIDs, UIDs, and halt
Date: Tue, 20 Oct 2009 20:08:37 -0500
Message-ID: <68e6eac60910201808j7f276c6j418527b9397ae3d1@mail.gmail.com>
References: <68e6eac60910110930q74358967o19e3d0e88e111bd5@mail.gmail.com>
	<20091012150355.GA5783@us.ibm.com>
	<68e6eac60910191217s5d295e54ta6b0c528dce9ce55@mail.gmail.com>
	<20091019222445.GA16774@us.ibm.com>
	<68e6eac60910201804h3f243cdel5a437701bf9c00ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <68e6eac60910201804h3f243cdel5a437701bf9c00ac-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Tue, Oct 20, 2009 at 8:04 PM, Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
----< snip >---
> Ok, the issue is that what is stored in the file that keychain
> produces is based on PID
> When logging into a different PID namespace that file is considered
> stale, because there is not an agent at that pid, so the file is
> overwritten by keychain.
>
> I'd to modify the filename to have the current namespace name (passed
> in via environment variable) be part of it, so that the proper one is
> checked by keychain and sourced by my shell
>
> It would require a keychain change either way, whether I'd use an
> environment variable or something was done to the kernel to allow it
> to be retrieved.
>
> A lot of applications that base things off a PID stored in a file will
> have issues when multiple PID namespaces are in play, and where those
> files are in the same locations in each container.
>
> I'm not asking for any kernel help, an environment variable will suffice.
>
> I'll patch keychain, and once I've determined it works correctly, I'll
> see if the maintainers (The Funtoo folk) will accept the patch.
>
> -- Dwight
>

Ok, I think I can just use the --host option, no need to patch.
